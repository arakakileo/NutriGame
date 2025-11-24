//
//  Constants.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation

enum Constants {
    // MARK: - App Info
    enum App {
        static let name = "NutriGame"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // MARK: - Firebase Collections
    enum FirestoreCollection {
        static let users = "users"
        static let squads = "squads"
        static let missions = "missions"
        static let weeklyRankings = "weeklyRankings"
        static let premiumPlans = "premiumPlans"
    }

    // MARK: - Storage Paths
    enum StoragePath {
        static let avatars = "avatars"
        static let missionPhotos = "mission_photos"
    }

    // MARK: - XP Values
    enum XP {
        static let missionWithPhoto = 50
        static let waterPerGlass = 10
        static let dailyBonus = 100
        static let maxDailyXP = 400
        static let maxWaterGlasses = 5
    }

    // MARK: - Squad
    enum Squad {
        static let codeLength = 6
        static let defaultMaxMembers = 100
    }

    // MARK: - Image
    enum Image {
        static let compressionQuality: CGFloat = 0.7
        static let maxDimension: CGFloat = 1080
        static let maxFileSizeBytes = 500_000 // 500KB
    }

    // MARK: - Notification Times (in hours, 24h format)
    enum NotificationTime {
        static let breakfast = 9
        static let lunch = 13
        static let dinner = 19
        static let reminder = 21
        static let streakWarning = 21.5 // 21:30
    }

    // MARK: - UserDefaults Keys
    enum UserDefaultsKey {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let lastNotificationDate = "lastNotificationDate"
        static let notificationsEnabled = "notificationsEnabled"
    }

    // MARK: - Validation
    enum Validation {
        static let minNameLength = 2
        static let maxNameLength = 50
        static let minPasswordLength = 6
    }

    // MARK: - Pagination
    enum Pagination {
        static let rankingPageSize = 50
        static let galleryPageSize = 30
    }

    // MARK: - Animation
    enum Animation {
        static let xpGain: Double = 0.3
        static let levelUp: Double = 1.5
        static let missionComplete: Double = 0.25
        static let streakPulse: Double = 0.5
        static let progressBar: Double = 0.4
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let fcmTokenReceived = Notification.Name("FCMToken")
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
    static let squadDidChange = Notification.Name("squadDidChange")
    static let missionCompleted = Notification.Name("missionCompleted")
}
