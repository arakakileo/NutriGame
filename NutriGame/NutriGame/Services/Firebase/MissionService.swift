//
//  MissionService.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import FirebaseFirestore

final class MissionService {
    static let shared = MissionService()

    private let firebase = FirebaseService.shared
    private let userService = UserService.shared
    private let rankingService = RankingService.shared

    private init() {}

    // MARK: - Complete Mission

    /// Completa uma missão com foto
    func completeMission(
        userId: String,
        squadCode: String,
        type: MissionType,
        photoData: Data
    ) async throws -> Mission {
        guard type.requiresPhoto else {
            throw MissionServiceError.photoNotRequired
        }

        // Verifica se já completou hoje
        if try await hasMissionToday(userId: userId, type: type) {
            throw MissionServiceError.alreadyCompleted
        }

        // Upload da foto
        let missionId = UUID().uuidString
        let photoRef = firebase.missionPhotoRef(missionId: missionId)
        let photoUrl = try await firebase.uploadImage(photoData, to: photoRef)

        // Cria a missão
        var mission = Mission(
            id: missionId,
            userId: userId,
            squadCode: squadCode,
            type: type,
            photoUrl: photoUrl.absoluteString,
            xpEarned: type.xpReward
        )

        // Salva no Firestore
        try firebase.missionsCollection.document(missionId).setData(from: mission)

        // Atualiza XP do usuário
        _ = try await userService.addXP(userId: userId, amount: type.xpReward)

        // Atualiza streak
        try await userService.updateStreak(userId: userId, completed: true)

        // Atualiza ranking semanal
        try await rankingService.updateUserRanking(
            userId: userId,
            squadCode: squadCode,
            xpEarned: type.xpReward,
            missionType: type
        )

        // Verifica daily bonus
        try await checkAndAwardDailyBonus(userId: userId, squadCode: squadCode)

        return mission
    }

    /// Completa/atualiza missão de hidratação
    func updateHydration(
        userId: String,
        squadCode: String,
        glasses: Int
    ) async throws -> Mission {
        let today = Mission.todayDateString()
        let type = MissionType.hydration

        // Busca missão de hidratação de hoje
        let existingMission = try await getTodayMission(userId: userId, type: type)

        let previousGlasses = existingMission?.waterCount ?? 0
        let newGlasses = min(glasses, Constants.XP.maxWaterGlasses)

        // Calcula XP adicional
        let additionalGlasses = max(0, newGlasses - previousGlasses)
        let xpEarned = additionalGlasses * type.xpReward

        if let mission = existingMission, let missionId = mission.id {
            // Atualiza missão existente
            try await firebase.missionsCollection.document(missionId).updateData([
                "waterCount": newGlasses,
                "xpEarned": newGlasses * type.xpReward,
                "completedAt": Timestamp(date: Date())
            ])

            if xpEarned > 0 {
                _ = try await userService.addXP(userId: userId, amount: xpEarned)
                try await rankingService.updateUserRanking(
                    userId: userId,
                    squadCode: squadCode,
                    xpEarned: xpEarned,
                    missionType: type
                )
            }

            var updated = mission
            updated.waterCount = newGlasses
            updated.xpEarned = newGlasses * type.xpReward

            // Verifica daily bonus
            try await checkAndAwardDailyBonus(userId: userId, squadCode: squadCode)

            return updated
        } else {
            // Cria nova missão
            let missionId = UUID().uuidString
            let mission = Mission(
                id: missionId,
                userId: userId,
                squadCode: squadCode,
                type: type,
                waterCount: newGlasses,
                xpEarned: xpEarned,
                date: today
            )

            try firebase.missionsCollection.document(missionId).setData(from: mission)

            if xpEarned > 0 {
                _ = try await userService.addXP(userId: userId, amount: xpEarned)
                try await userService.updateStreak(userId: userId, completed: true)
                try await rankingService.updateUserRanking(
                    userId: userId,
                    squadCode: squadCode,
                    xpEarned: xpEarned,
                    missionType: type
                )
            }

            // Verifica daily bonus
            try await checkAndAwardDailyBonus(userId: userId, squadCode: squadCode)

            return mission
        }
    }

    // MARK: - Queries

    /// Busca missões de hoje de um usuário
    func getTodayMissions(userId: String) async throws -> [Mission] {
        let today = Mission.todayDateString()
        return try await firebase.documents(
            firebase.missionsCollection
                .whereField("userId", isEqualTo: userId)
                .whereField("date", isEqualTo: today),
            as: Mission.self
        )
    }

    /// Busca uma missão específica de hoje
    func getTodayMission(userId: String, type: MissionType) async throws -> Mission? {
        let today = Mission.todayDateString()
        let missions = try await firebase.documents(
            firebase.missionsCollection
                .whereField("userId", isEqualTo: userId)
                .whereField("date", isEqualTo: today)
                .whereField("type", isEqualTo: type.rawValue),
            as: Mission.self
        )
        return missions.first
    }

    /// Verifica se já completou uma missão hoje
    func hasMissionToday(userId: String, type: MissionType) async throws -> Bool {
        let mission = try await getTodayMission(userId: userId, type: type)
        return mission != nil
    }

    /// Busca todas as missões de um usuário (para galeria)
    func getUserMissions(
        userId: String,
        limit: Int = Constants.Pagination.galleryPageSize
    ) async throws -> [Mission] {
        try await firebase.documents(
            firebase.missionsCollection
                .whereField("userId", isEqualTo: userId)
                .whereField("photoUrl", isNotEqualTo: NSNull())
                .order(by: "completedAt", descending: true)
                .limit(to: limit),
            as: Mission.self
        )
    }

    /// Busca missões de um usuário em uma data específica
    func getMissions(userId: String, date: String) async throws -> [Mission] {
        try await firebase.documents(
            firebase.missionsCollection
                .whereField("userId", isEqualTo: userId)
                .whereField("date", isEqualTo: date),
            as: Mission.self
        )
    }

    // MARK: - Daily Bonus

    private func checkAndAwardDailyBonus(userId: String, squadCode: String) async throws {
        let missions = try await getTodayMissions(userId: userId)
        let dailyMissions = DailyMissions(
            date: Mission.todayDateString(),
            completedMissions: Dictionary(
                uniqueKeysWithValues: missions.compactMap { mission in
                    (mission.type, mission)
                }
            )
        )

        if dailyMissions.isAllComplete {
            // Verifica se já recebeu o bônus hoje
            // (implementar flag ou verificação adicional se necessário)
            _ = try await userService.addXP(userId: userId, amount: Constants.XP.dailyBonus)
            try await rankingService.updateUserRanking(
                userId: userId,
                squadCode: squadCode,
                xpEarned: Constants.XP.dailyBonus,
                missionType: nil // Daily bonus não é de um tipo específico
            )
        }
    }

    // MARK: - Real-time Listener

    /// Observa missões de hoje
    func observeTodayMissions(
        userId: String,
        onChange: @escaping ([Mission]) -> Void
    ) -> ListenerRegistration {
        let today = Mission.todayDateString()
        return firebase.missionsCollection
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isEqualTo: today)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    onChange([])
                    return
                }
                let missions = snapshot.documents.compactMap {
                    try? $0.data(as: Mission.self)
                }
                onChange(missions)
            }
    }
}

// MARK: - Errors
enum MissionServiceError: LocalizedError {
    case alreadyCompleted
    case photoNotRequired
    case uploadFailed
    case invalidMissionType

    var errorDescription: String? {
        switch self {
        case .alreadyCompleted:
            return "Você já completou esta missão hoje."
        case .photoNotRequired:
            return "Esta missão não requer foto."
        case .uploadFailed:
            return "Falha ao enviar a foto. Tente novamente."
        case .invalidMissionType:
            return "Tipo de missão inválido."
        }
    }
}
