//
//  NotificationScheduler.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import UserNotifications

// MARK: - Local Notification Scheduler
/// Schedules local notifications as a backup when push notifications are unavailable
final class NotificationScheduler {
    static let shared = NotificationScheduler()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Schedule Daily Reminders

    func scheduleAllDailyReminders() {
        // Clear existing scheduled notifications
        cancelAllScheduledNotifications()

        // Schedule new ones
        scheduleBreakfastReminder()
        scheduleLunchReminder()
        scheduleDinnerReminder()
        scheduleDailySummaryReminder()
        scheduleStreakWarningReminder()
    }

    func cancelAllScheduledNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    // MARK: - Individual Reminders

    private func scheduleBreakfastReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Bom dia! ☀️"
        content.body = "Registre seu café da manhã e ganhe 50 XP!"
        content.sound = .default
        content.userInfo = ["type": "mission_reminder", "missionType": "breakfast"]

        let trigger = createDailyTrigger(hour: 9, minute: 0)

        let request = UNNotificationRequest(
            identifier: "breakfast_reminder",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    private func scheduleLunchReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Hora do almoço! 🍽️"
        content.body = "Não esqueça de registrar seu almoço!"
        content.sound = .default
        content.userInfo = ["type": "mission_reminder", "missionType": "lunch"]

        let trigger = createDailyTrigger(hour: 13, minute: 0)

        let request = UNNotificationRequest(
            identifier: "lunch_reminder",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    private func scheduleDinnerReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Hora do jantar! 🌙"
        content.body = "Complete sua missão de jantar!"
        content.sound = .default
        content.userInfo = ["type": "mission_reminder", "missionType": "dinner"]

        let trigger = createDailyTrigger(hour: 19, minute: 0)

        let request = UNNotificationRequest(
            identifier: "dinner_reminder",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    private func scheduleDailySummaryReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Resumo do dia 📊"
        content.body = "Abra o app para ver suas missões de hoje!"
        content.sound = .default
        content.userInfo = ["type": "daily_summary"]

        let trigger = createDailyTrigger(hour: 21, minute: 0)

        let request = UNNotificationRequest(
            identifier: "daily_summary",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    private func scheduleStreakWarningReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Seu streak está em risco! 🔥"
        content.body = "Complete uma missão para manter seu streak!"
        content.sound = .default
        content.userInfo = ["type": "streak_warning"]

        let trigger = createDailyTrigger(hour: 21, minute: 30)

        let request = UNNotificationRequest(
            identifier: "streak_warning",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    // MARK: - Custom Notifications

    func scheduleCustomNotification(
        identifier: String,
        title: String,
        body: String,
        at date: Date,
        userInfo: [String: Any] = [:]
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = userInfo

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    func cancelNotification(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    // MARK: - XP Milestone Notifications

    func scheduleXPMilestoneNotification(currentXP: Int, targetXP: Int, level: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Quase lá! 🎯"
        content.body = "Faltam apenas \(targetXP - currentXP) XP para o nível \(level + 1)!"
        content.sound = .default
        content.userInfo = ["type": "xp_milestone"]

        // Schedule for 1 hour from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)

        let request = UNNotificationRequest(
            identifier: "xp_milestone_\(level)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    // MARK: - Helpers

    private func createDailyTrigger(hour: Int, minute: Int) -> UNCalendarNotificationTrigger {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    }

    // MARK: - Debug

    func listPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }

    func printPendingNotifications() async {
        let requests = await listPendingNotifications()
        print("Pending notifications (\(requests.count)):")
        for request in requests {
            print("- \(request.identifier): \(request.content.title)")
        }
    }
}

// MARK: - Mission-Specific Notifications
extension NotificationScheduler {

    func scheduleMissionCompletionCelebration(missionType: String, xpEarned: Int) {
        // This would be shown immediately after completing a mission
        // In practice, we'll use in-app animations instead
    }

    func scheduleWaterReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Hora de beber água! 💧"
        content.body = "Mantenha-se hidratado! Registre seus copos de água."
        content.sound = .default
        content.userInfo = ["type": "mission_reminder", "missionType": "hydration"]

        // Every 2 hours during the day (10am, 12pm, 2pm, 4pm, 6pm)
        let hours = [10, 12, 14, 16, 18]

        for hour in hours {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            let request = UNNotificationRequest(
                identifier: "water_reminder_\(hour)",
                content: content,
                trigger: trigger
            )

            notificationCenter.add(request)
        }
    }

    func scheduleWorkoutReminder(preferredHour: Int = 18) {
        let content = UNMutableNotificationContent()
        content.title = "Hora do treino! 💪"
        content.body = "Não esqueça de registrar seu exercício de hoje!"
        content.sound = .default
        content.userInfo = ["type": "mission_reminder", "missionType": "workout"]

        var dateComponents = DateComponents()
        dateComponents.hour = preferredHour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "workout_reminder",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    func scheduleSnackReminder(preferredHour: Int = 16) {
        let content = UNMutableNotificationContent()
        content.title = "Hora do lanche! 🍎"
        content.body = "Registre seu lanche da tarde!"
        content.sound = .default
        content.userInfo = ["type": "mission_reminder", "missionType": "snack"]

        var dateComponents = DateComponents()
        dateComponents.hour = preferredHour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "snack_reminder",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }
}
