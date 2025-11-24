//
//  Mission.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import FirebaseFirestore

struct Mission: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var squadCode: String
    var type: MissionType
    var photoUrl: String?
    var waterCount: Int?
    var xpEarned: Int
    var completedAt: Date
    var date: String // "YYYY-MM-DD"

    init(
        id: String? = nil,
        userId: String,
        squadCode: String,
        type: MissionType,
        photoUrl: String? = nil,
        waterCount: Int? = nil,
        xpEarned: Int = 0,
        completedAt: Date = Date(),
        date: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.squadCode = squadCode
        self.type = type
        self.photoUrl = photoUrl
        self.waterCount = waterCount
        self.xpEarned = xpEarned
        self.completedAt = completedAt
        self.date = date ?? Mission.dateFormatter.string(from: Date())
    }

    // MARK: - Static Properties

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    static func todayDateString() -> String {
        dateFormatter.string(from: Date())
    }
}

// MARK: - Mission Type
enum MissionType: String, Codable, CaseIterable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"
    case workout = "workout"
    case hydration = "hydration"

    var displayName: String {
        switch self {
        case .breakfast: return "Café da Manhã"
        case .lunch: return "Almoço"
        case .dinner: return "Jantar"
        case .snack: return "Lanche"
        case .workout: return "Treino"
        case .hydration: return "Hidratação"
        }
    }

    var icon: String {
        switch self {
        case .breakfast: return "sun.horizon.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "leaf.fill"
        case .workout: return "figure.run"
        case .hydration: return "drop.fill"
        }
    }

    var xpReward: Int {
        switch self {
        case .hydration: return 10 // por copo
        default: return 50
        }
    }

    var requiresPhoto: Bool {
        self != .hydration
    }

    var order: Int {
        switch self {
        case .breakfast: return 0
        case .lunch: return 1
        case .dinner: return 2
        case .snack: return 3
        case .workout: return 4
        case .hydration: return 5
        }
    }
}

// MARK: - Daily Missions Helper
struct DailyMissions {
    let date: String
    var completedMissions: [MissionType: Mission]

    var totalXP: Int {
        var xp = 0
        for (type, mission) in completedMissions {
            if type == .hydration {
                xp += (mission.waterCount ?? 0) * MissionType.hydration.xpReward
            } else {
                xp += type.xpReward
            }
        }
        // Daily Bonus
        if isAllComplete {
            xp += 100
        }
        return xp
    }

    var completedCount: Int {
        completedMissions.count
    }

    var isAllComplete: Bool {
        // Verifica se todas as 6 missões foram completadas
        // Para hidratação, precisa ter pelo menos 5 copos
        for type in MissionType.allCases {
            if type == .hydration {
                guard let mission = completedMissions[type],
                      let waterCount = mission.waterCount,
                      waterCount >= 5 else {
                    return false
                }
            } else {
                guard completedMissions[type] != nil else {
                    return false
                }
            }
        }
        return true
    }

    func isComplete(_ type: MissionType) -> Bool {
        if type == .hydration {
            guard let mission = completedMissions[type],
                  let waterCount = mission.waterCount else {
                return false
            }
            return waterCount >= 5
        }
        return completedMissions[type] != nil
    }

    func waterCount() -> Int {
        completedMissions[.hydration]?.waterCount ?? 0
    }
}

// MARK: - Mock Data
extension Mission {
    static let mockBreakfast = Mission(
        id: "mission-1",
        userId: "mock-user-id",
        squadCode: "NUTRI1",
        type: .breakfast,
        photoUrl: "https://example.com/photo1.jpg",
        xpEarned: 50,
        completedAt: Date(),
        date: Mission.todayDateString()
    )

    static let mockHydration = Mission(
        id: "mission-2",
        userId: "mock-user-id",
        squadCode: "NUTRI1",
        type: .hydration,
        waterCount: 3,
        xpEarned: 30,
        completedAt: Date(),
        date: Mission.todayDateString()
    )
}
