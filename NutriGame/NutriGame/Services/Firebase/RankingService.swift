//
//  RankingService.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import FirebaseFirestore

final class RankingService {
    static let shared = RankingService()

    private let firebase = FirebaseService.shared

    private init() {}

    // MARK: - Update Ranking

    /// Atualiza o ranking de um usuário na semana atual
    func updateUserRanking(
        userId: String,
        squadCode: String,
        xpEarned: Int,
        missionType: MissionType?
    ) async throws {
        let rankingId = WeeklyRanking.generateId(squadCode: squadCode)
        let rankingRef = firebase.weeklyRankingsCollection.document(rankingId)
        let userRankingRef = rankingRef.collection("users").document(userId)

        // Busca dados do usuário
        let user = try await firebase.document(
            firebase.usersCollection.document(userId),
            as: User.self
        )

        // Verifica se o ranking existe, se não, cria
        let rankingSnapshot = try await rankingRef.getDocument()
        if !rankingSnapshot.exists {
            let (weekStart, weekEnd) = WeeklyRanking.currentWeekBounds()
            let ranking = WeeklyRanking(
                id: rankingId,
                squadCode: squadCode,
                weekStart: weekStart,
                weekEnd: weekEnd
            )
            try rankingRef.setData(from: ranking)
        }

        // Busca ou cria entrada do usuário no ranking
        let userRankingSnapshot = try await userRankingRef.getDocument()

        if userRankingSnapshot.exists {
            // Atualiza entrada existente
            var updates: [String: Any] = [
                "weeklyXP": FieldValue.increment(Int64(xpEarned)),
                "lastUpdated": Timestamp(date: Date())
            ]

            // Adiciona missão de hoje se ainda não estiver
            if let missionType = missionType {
                updates["todayMissions"] = FieldValue.arrayUnion([missionType.rawValue])
            }

            try await userRankingRef.updateData(updates)
        } else {
            // Cria nova entrada
            var todayMissions: [String] = []
            if let missionType = missionType {
                todayMissions.append(missionType.rawValue)
            }

            let entry = RankingUserEntry(
                id: userId,
                name: user.name,
                avatarUrl: user.avatarUrl,
                weeklyXP: xpEarned,
                todayMissions: todayMissions,
                lastUpdated: Date()
            )
            try userRankingRef.setData(from: entry)
        }
    }

    // MARK: - Get Rankings

    /// Busca o ranking semanal de um squad
    func getWeeklyRanking(
        squadCode: String,
        currentUserId: String,
        limit: Int = Constants.Pagination.rankingPageSize
    ) async throws -> [RankedUser] {
        let rankingId = WeeklyRanking.generateId(squadCode: squadCode)
        let rankingRef = firebase.weeklyRankingsCollection.document(rankingId)

        let entries = try await firebase.documents(
            rankingRef.collection("users")
                .order(by: "weeklyXP", descending: true)
                .limit(to: limit),
            as: RankingUserEntry.self
        )

        return entries.enumerated().map { index, entry in
            RankedUser(
                id: entry.id ?? "",
                position: index + 1,
                name: entry.name,
                avatarUrl: entry.avatarUrl,
                weeklyXP: entry.weeklyXP,
                todayMissions: entry.completedMissionTypes,
                isCurrentUser: entry.id == currentUserId
            )
        }
    }

    /// Busca a posição do usuário atual no ranking
    func getCurrentUserPosition(
        squadCode: String,
        userId: String
    ) async throws -> (position: Int, totalUsers: Int)? {
        let rankingId = WeeklyRanking.generateId(squadCode: squadCode)
        let rankingRef = firebase.weeklyRankingsCollection.document(rankingId)

        // Busca XP do usuário atual
        let userRankingRef = rankingRef.collection("users").document(userId)
        let userSnapshot = try await userRankingRef.getDocument()

        guard userSnapshot.exists,
              let userEntry = try? userSnapshot.data(as: RankingUserEntry.self) else {
            return nil
        }

        // Conta quantos usuários têm mais XP
        let higherRanked = try await rankingRef.collection("users")
            .whereField("weeklyXP", isGreaterThan: userEntry.weeklyXP)
            .getDocuments()

        let position = higherRanked.count + 1

        // Conta total de usuários
        let totalSnapshot = try await rankingRef.collection("users").getDocuments()
        let totalUsers = totalSnapshot.count

        return (position, totalUsers)
    }

    // MARK: - Reset Daily Missions

    /// Reseta as missões de hoje para todos os usuários de um squad
    /// (Chamado por Cloud Function à meia-noite UTC)
    func resetTodayMissions(squadCode: String) async throws {
        let rankingId = WeeklyRanking.generateId(squadCode: squadCode)
        let rankingRef = firebase.weeklyRankingsCollection.document(rankingId)

        let usersSnapshot = try await rankingRef.collection("users").getDocuments()

        let batch = firebase.db.batch()
        for doc in usersSnapshot.documents {
            batch.updateData(["todayMissions": []], forDocument: doc.reference)
        }

        try await batch.commit()
    }

    // MARK: - Real-time Listener

    /// Observa mudanças no ranking semanal
    func observeWeeklyRanking(
        squadCode: String,
        currentUserId: String,
        onChange: @escaping ([RankedUser]) -> Void
    ) -> ListenerRegistration {
        let rankingId = WeeklyRanking.generateId(squadCode: squadCode)
        let rankingRef = firebase.weeklyRankingsCollection.document(rankingId)

        return rankingRef.collection("users")
            .order(by: "weeklyXP", descending: true)
            .limit(to: Constants.Pagination.rankingPageSize)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    onChange([])
                    return
                }

                let entries = snapshot.documents.compactMap {
                    try? $0.data(as: RankingUserEntry.self)
                }

                let rankedUsers = entries.enumerated().map { index, entry in
                    RankedUser(
                        id: entry.id ?? "",
                        position: index + 1,
                        name: entry.name,
                        avatarUrl: entry.avatarUrl,
                        weeklyXP: entry.weeklyXP,
                        todayMissions: entry.completedMissionTypes,
                        isCurrentUser: entry.id == currentUserId
                    )
                }

                onChange(rankedUsers)
            }
    }
}
