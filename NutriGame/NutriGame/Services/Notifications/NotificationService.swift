//
//  NotificationService.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import UserNotifications
import FirebaseMessaging

// MARK: - Notification Service
@MainActor
final class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()

    @Published var isAuthorized = false
    @Published var fcmToken: String?

    private let notificationCenter = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        notificationCenter.delegate = self
        Messaging.messaging().delegate = self
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            let granted = try await notificationCenter.requestAuthorization(options: options)
            await MainActor.run {
                self.isAuthorized = granted
            }

            if granted {
                await registerForRemoteNotifications()
            }

            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        await MainActor.run {
            self.isAuthorized = settings.authorizationStatus == .authorized
        }
    }

    private func registerForRemoteNotifications() async {
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    // MARK: - FCM Token Management

    func getFCMToken() async -> String? {
        do {
            let token = try await Messaging.messaging().token()
            await MainActor.run {
                self.fcmToken = token
            }
            return token
        } catch {
            print("Error getting FCM token: \(error)")
            return nil
        }
    }

    func updateFCMToken(for userId: String) async {
        guard let token = await getFCMToken() else { return }

        do {
            try await UserService.shared.updateFCMToken(userId: userId, token: token)
        } catch {
            print("Error updating FCM token: \(error)")
        }
    }

    // MARK: - Badge Management

    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    func setBadge(_ count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count)
    }

    // MARK: - Handle Notification Response

    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo

        guard let type = userInfo["type"] as? String else { return }

        switch type {
        case "mission_reminder":
            if let missionType = userInfo["missionType"] as? String {
                NotificationCenter.default.post(
                    name: .openMission,
                    object: nil,
                    userInfo: ["missionType": missionType]
                )
            }
        case "daily_summary", "daily_bonus":
            NotificationCenter.default.post(name: .openHome, object: nil)
        case "streak_warning":
            NotificationCenter.default.post(name: .openMissions, object: nil)
        case "weekly_winner":
            NotificationCenter.default.post(name: .openRanking, object: nil)
        case "level_up":
            NotificationCenter.default.post(name: .openProfile, object: nil)
        default:
            break
        }

        clearBadge()
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // Show notification even when app is in foreground
        return [.banner, .sound, .badge]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        await MainActor.run {
            handleNotificationResponse(response)
        }
    }
}

// MARK: - MessagingDelegate
extension NotificationService: MessagingDelegate {
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }

        Task { @MainActor in
            self.fcmToken = token
            // Save token to UserDefaults for offline access
            UserDefaults.standard.set(token, forKey: "fcmToken")
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let openHome = Notification.Name("openHome")
    static let openMissions = Notification.Name("openMissions")
    static let openMission = Notification.Name("openMission")
    static let openRanking = Notification.Name("openRanking")
    static let openProfile = Notification.Name("openProfile")
}
