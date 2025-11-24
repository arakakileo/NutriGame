//
//  UserTests.swift
//  NutriGameTests
//
//  Created by NutriGame Team
//

import XCTest
@testable import NutriGame

final class UserTests: XCTestCase {

    // MARK: - User Creation

    func testUserCreation() {
        let user = User(
            id: "user123",
            name: "João Silva",
            email: "joao@example.com",
            avatarUrl: nil,
            squadCode: "ABC123",
            level: 1,
            totalXP: 0,
            currentStreak: 0,
            longestStreak: 0,
            lastCompletedDate: nil,
            createdAt: Date(),
            isNutritionist: false,
            fcmToken: nil,
            timezone: "America/Sao_Paulo",
            notificationsEnabled: true,
            isPremium: false,
            premiumUntil: nil,
            premiumFeatures: []
        )

        XCTAssertEqual(user.id, "user123")
        XCTAssertEqual(user.name, "João Silva")
        XCTAssertEqual(user.email, "joao@example.com")
        XCTAssertEqual(user.level, 1)
        XCTAssertEqual(user.totalXP, 0)
        XCTAssertFalse(user.isNutritionist)
    }

    // MARK: - Level Calculation

    func testXPRequiredForLevel() {
        XCTAssertEqual(User.xpRequiredForLevel(1), 500)
        XCTAssertEqual(User.xpRequiredForLevel(2), 1000)
        XCTAssertEqual(User.xpRequiredForLevel(3), 1500)
        XCTAssertEqual(User.xpRequiredForLevel(5), 2500)
        XCTAssertEqual(User.xpRequiredForLevel(10), 5000)
    }

    func testTotalXPForLevel() {
        // XP needed to reach level N
        XCTAssertEqual(User.totalXPForLevel(1), 0) // Start at level 1
        XCTAssertEqual(User.totalXPForLevel(2), 500) // 500 to reach level 2
        XCTAssertEqual(User.totalXPForLevel(3), 1500) // 500 + 1000
        XCTAssertEqual(User.totalXPForLevel(4), 3000) // 500 + 1000 + 1500
        XCTAssertEqual(User.totalXPForLevel(5), 5000) // 500 + 1000 + 1500 + 2000
    }

    func testCalculateLevel() {
        XCTAssertEqual(User.calculateLevel(from: 0), 1)
        XCTAssertEqual(User.calculateLevel(from: 499), 1)
        XCTAssertEqual(User.calculateLevel(from: 500), 2)
        XCTAssertEqual(User.calculateLevel(from: 1499), 2)
        XCTAssertEqual(User.calculateLevel(from: 1500), 3)
        XCTAssertEqual(User.calculateLevel(from: 5000), 5)
        XCTAssertEqual(User.calculateLevel(from: 10000), 6)
    }

    func testXPProgressToNextLevel() {
        // User at level 1 with 250 XP
        let progress1 = User.xpProgressToNextLevel(currentXP: 250, currentLevel: 1)
        XCTAssertEqual(progress1.current, 250)
        XCTAssertEqual(progress1.required, 500)
        XCTAssertEqual(progress1.percentage, 0.5, accuracy: 0.01)

        // User at level 2 with 800 XP (needs 1000 more to reach level 3)
        let progress2 = User.xpProgressToNextLevel(currentXP: 800, currentLevel: 2)
        XCTAssertEqual(progress2.current, 300) // 800 - 500 (XP already used for level 2)
        XCTAssertEqual(progress2.required, 1000)
        XCTAssertEqual(progress2.percentage, 0.3, accuracy: 0.01)
    }

    // MARK: - Streak Logic

    func testStreakShouldContinue() {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        // Last completed yesterday - streak continues
        XCTAssertTrue(User.streakShouldContinue(lastCompletedDate: yesterday, today: today))

        // Last completed today - streak continues
        XCTAssertTrue(User.streakShouldContinue(lastCompletedDate: today, today: today))

        // Last completed 2+ days ago - streak broken
        XCTAssertFalse(User.streakShouldContinue(lastCompletedDate: twoDaysAgo, today: today))

        // Nil date - no streak
        XCTAssertFalse(User.streakShouldContinue(lastCompletedDate: nil, today: today))
    }

    // MARK: - Formatted Values

    func testFormattedXP() {
        XCTAssertEqual(User.formattedXP(0), "0")
        XCTAssertEqual(User.formattedXP(999), "999")
        XCTAssertEqual(User.formattedXP(1000), "1K")
        XCTAssertEqual(User.formattedXP(1500), "1.5K")
        XCTAssertEqual(User.formattedXP(10000), "10K")
        XCTAssertEqual(User.formattedXP(1000000), "1M")
    }
}

// MARK: - User Extension for Tests
extension User {
    static func xpRequiredForLevel(_ level: Int) -> Int {
        return level * 500
    }

    static func totalXPForLevel(_ level: Int) -> Int {
        guard level > 1 else { return 0 }
        return (1..<level).reduce(0) { $0 + xpRequiredForLevel($1) }
    }

    static func calculateLevel(from xp: Int) -> Int {
        var level = 1
        var totalXPNeeded = 0

        while totalXPNeeded + xpRequiredForLevel(level) <= xp {
            totalXPNeeded += xpRequiredForLevel(level)
            level += 1
        }

        return level
    }

    static func xpProgressToNextLevel(
        currentXP: Int,
        currentLevel: Int
    ) -> (current: Int, required: Int, percentage: Double) {
        let xpForCurrentLevel = totalXPForLevel(currentLevel)
        let xpInCurrentLevel = currentXP - xpForCurrentLevel
        let xpNeeded = xpRequiredForLevel(currentLevel)
        let percentage = Double(xpInCurrentLevel) / Double(xpNeeded)

        return (xpInCurrentLevel, xpNeeded, percentage)
    }

    static func streakShouldContinue(lastCompletedDate: Date?, today: Date) -> Bool {
        guard let lastDate = lastCompletedDate else { return false }

        let calendar = Calendar.current
        let lastDay = calendar.startOfDay(for: lastDate)
        let todayStart = calendar.startOfDay(for: today)

        let daysDifference = calendar.dateComponents([.day], from: lastDay, to: todayStart).day ?? 0

        return daysDifference <= 1
    }

    static func formattedXP(_ xp: Int) -> String {
        if xp >= 1_000_000 {
            return "\(xp / 1_000_000)M"
        } else if xp >= 1000 {
            let value = Double(xp) / 1000.0
            if value == Double(Int(value)) {
                return "\(Int(value))K"
            } else {
                return String(format: "%.1fK", value)
            }
        }
        return "\(xp)"
    }
}
