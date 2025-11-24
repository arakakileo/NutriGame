//
//  WeeklyRanking.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import FirebaseFirestore

struct WeeklyRanking: Identifiable, Codable {
    @DocumentID var id: String?
    var squadCode: String
    var weekStart: Date
    var weekEnd: Date

    init(
        id: String? = nil,
        squadCode: String,
        weekStart: Date,
        weekEnd: Date
    ) {
        self.id = id
        self.squadCode = squadCode
        self.weekStart = weekStart
        self.weekEnd = weekEnd
    }

    // MARK: - Static Methods

    /// Gera o ID do ranking semanal no formato "SQUADCODE_YYYY-WW"
    static func generateId(squadCode: String, for date: Date = Date()) -> String {
        let weekId = weekIdFor(date: date)
        return "\(squadCode)_\(weekId)"
    }

    /// Retorna o identificador da semana no formato "YYYY-WW"
    static func weekIdFor(date: Date) -> String {
        let calendar = Calendar(identifier: .iso8601)
        let year = calendar.component(.yearForWeekOfYear, from: date)
        let week = calendar.component(.weekOfYear, from: date)
        return String(format: "%04d-%02d", year, week)
    }

    /// Retorna as datas de início e fim da semana atual
    static func currentWeekBounds() -> (start: Date, end: Date) {
        let calendar = Calendar(identifier: .iso8601)
        let now = Date()

        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!

        // Fim da semana às 23:59:59
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endOfWeek)!

        return (startOfWeek, endOfDay)
    }
}

// MARK: - Ranking User Entry
struct RankingUserEntry: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var avatarUrl: String?
    var weeklyXP: Int
    var todayMissions: [String] // MissionType raw values completados hoje
    var lastUpdated: Date

    init(
        id: String? = nil,
        name: String,
        avatarUrl: String? = nil,
        weeklyXP: Int = 0,
        todayMissions: [String] = [],
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.avatarUrl = avatarUrl
        self.weeklyXP = weeklyXP
        self.todayMissions = todayMissions
        self.lastUpdated = lastUpdated
    }

    // MARK: - Computed Properties

    var completedMissionTypes: [MissionType] {
        todayMissions.compactMap { MissionType(rawValue: $0) }
    }

    func hasCompletedToday(_ type: MissionType) -> Bool {
        todayMissions.contains(type.rawValue)
    }
}

// MARK: - Ranked User (for display)
struct RankedUser: Identifiable {
    let id: String
    let position: Int
    let name: String
    let avatarUrl: String?
    let weeklyXP: Int
    let todayMissions: [MissionType]
    let isCurrentUser: Bool

    var positionSuffix: String {
        switch position {
        case 1: return "º"
        case 2: return "º"
        case 3: return "º"
        default: return "º"
        }
    }

    var formattedPosition: String {
        "\(position)\(positionSuffix)"
    }
}

// MARK: - Mock Data
extension RankedUser {
    static let mockRanking: [RankedUser] = [
        RankedUser(
            id: "user-1",
            position: 1,
            name: "Maria Silva",
            avatarUrl: nil,
            weeklyXP: 2400,
            todayMissions: [.breakfast, .lunch, .workout],
            isCurrentUser: false
        ),
        RankedUser(
            id: "user-2",
            position: 2,
            name: "João Santos",
            avatarUrl: nil,
            weeklyXP: 2100,
            todayMissions: [.breakfast, .lunch],
            isCurrentUser: true
        ),
        RankedUser(
            id: "user-3",
            position: 3,
            name: "Ana Costa",
            avatarUrl: nil,
            weeklyXP: 1800,
            todayMissions: [.breakfast],
            isCurrentUser: false
        ),
        RankedUser(
            id: "user-4",
            position: 4,
            name: "Pedro Lima",
            avatarUrl: nil,
            weeklyXP: 1500,
            todayMissions: [],
            isCurrentUser: false
        ),
        RankedUser(
            id: "user-5",
            position: 5,
            name: "Carla Mendes",
            avatarUrl: nil,
            weeklyXP: 1200,
            todayMissions: [.breakfast, .workout],
            isCurrentUser: false
        )
    ]
}
