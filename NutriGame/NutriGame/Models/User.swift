//
//  User.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var avatarUrl: String?
    var squadCode: String?
    var level: Int
    var totalXP: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastCompletedDate: Date?
    var createdAt: Date
    var isNutritionist: Bool
    var fcmToken: String?
    var timezone: String
    var notificationsEnabled: Bool

    // Preparado para monetização
    var isPremium: Bool
    var premiumUntil: Date?
    var premiumFeatures: [String]

    init(
        id: String? = nil,
        name: String,
        email: String,
        avatarUrl: String? = nil,
        squadCode: String? = nil,
        level: Int = 1,
        totalXP: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastCompletedDate: Date? = nil,
        createdAt: Date = Date(),
        isNutritionist: Bool = false,
        fcmToken: String? = nil,
        timezone: String = TimeZone.current.identifier,
        notificationsEnabled: Bool = true,
        isPremium: Bool = false,
        premiumUntil: Date? = nil,
        premiumFeatures: [String] = []
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarUrl = avatarUrl
        self.squadCode = squadCode
        self.level = level
        self.totalXP = totalXP
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastCompletedDate = lastCompletedDate
        self.createdAt = createdAt
        self.isNutritionist = isNutritionist
        self.fcmToken = fcmToken
        self.timezone = timezone
        self.notificationsEnabled = notificationsEnabled
        self.isPremium = isPremium
        self.premiumUntil = premiumUntil
        self.premiumFeatures = premiumFeatures
    }

    // MARK: - Computed Properties

    var xpForCurrentLevel: Int {
        User.xpRequiredForLevel(level)
    }

    var xpProgressInCurrentLevel: Int {
        let previousLevelTotalXP = User.totalXPUpToLevel(level - 1)
        return totalXP - previousLevelTotalXP
    }

    var xpProgressPercentage: Double {
        guard xpForCurrentLevel > 0 else { return 0 }
        return Double(xpProgressInCurrentLevel) / Double(xpForCurrentLevel)
    }

    // MARK: - Static Methods

    /// XP necessário para completar um nível específico
    static func xpRequiredForLevel(_ level: Int) -> Int {
        return level * 500
    }

    /// XP total acumulado até um nível específico
    static func totalXPUpToLevel(_ level: Int) -> Int {
        guard level > 0 else { return 0 }
        return (level * (level + 1) / 2) * 500
    }

    /// Calcula o nível baseado no XP total
    static func levelForTotalXP(_ xp: Int) -> Int {
        var level = 1
        while totalXPUpToLevel(level) <= xp {
            level += 1
        }
        return level
    }
}

// MARK: - Mock Data
extension User {
    static let mock = User(
        id: "mock-user-id",
        name: "João Silva",
        email: "joao@email.com",
        avatarUrl: nil,
        squadCode: "NUTRI1",
        level: 5,
        totalXP: 2350,
        currentStreak: 7,
        longestStreak: 14,
        lastCompletedDate: Date(),
        createdAt: Date().addingTimeInterval(-30 * 24 * 60 * 60),
        isNutritionist: false
    )

    static let mockNutritionist = User(
        id: "mock-nutri-id",
        name: "Dra. Maria Santos",
        email: "maria.nutri@email.com",
        avatarUrl: nil,
        squadCode: "MARIA1",
        level: 1,
        totalXP: 0,
        currentStreak: 0,
        longestStreak: 0,
        createdAt: Date(),
        isNutritionist: true
    )
}
