//
//  UserService.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class UserService {
    static let shared = UserService()

    private let firebase = FirebaseService.shared

    private init() {}

    // MARK: - CRUD Operations

    /// Cria um novo usuário no Firestore
    func createUser(_ user: User) async throws {
        guard let userId = user.id else {
            throw UserServiceError.invalidUserId
        }
        try firebase.usersCollection.document(userId).setData(from: user)
    }

    /// Busca um usuário pelo ID
    func getUser(id: String) async throws -> User {
        try await firebase.document(
            firebase.usersCollection.document(id),
            as: User.self
        )
    }

    /// Atualiza um usuário
    func updateUser(_ user: User) async throws {
        guard let userId = user.id else {
            throw UserServiceError.invalidUserId
        }
        try firebase.usersCollection.document(userId).setData(from: user, merge: true)
    }

    /// Deleta um usuário
    func deleteUser(id: String) async throws {
        try await firebase.usersCollection.document(id).delete()
    }

    // MARK: - Specific Updates

    /// Atualiza o código do squad do usuário
    func updateSquadCode(userId: String, squadCode: String?) async throws {
        try await firebase.usersCollection.document(userId).updateData([
            "squadCode": squadCode as Any
        ])
    }

    /// Atualiza o FCM token do usuário
    func updateFCMToken(userId: String, token: String) async throws {
        try await firebase.usersCollection.document(userId).updateData([
            "fcmToken": token
        ])
    }

    /// Incrementa XP e atualiza nível se necessário
    func addXP(userId: String, amount: Int) async throws -> User {
        let user = try await getUser(id: userId)
        let newTotalXP = user.totalXP + amount
        let newLevel = User.levelForTotalXP(newTotalXP)

        try await firebase.usersCollection.document(userId).updateData([
            "totalXP": newTotalXP,
            "level": newLevel
        ])

        var updatedUser = user
        updatedUser.totalXP = newTotalXP
        updatedUser.level = newLevel
        return updatedUser
    }

    /// Atualiza streak do usuário
    func updateStreak(userId: String, completed: Bool) async throws {
        let user = try await getUser(id: userId)
        let today = Mission.todayDateString()

        var updates: [String: Any] = [:]

        if completed {
            // Verifica se já completou hoje
            if let lastDate = user.lastCompletedDate,
               Mission.dateFormatter.string(from: lastDate) == today {
                // Já completou hoje, não faz nada
                return
            }

            // Verifica se completou ontem para manter streak
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let yesterdayString = Mission.dateFormatter.string(from: yesterday)

            var newStreak = user.currentStreak

            if let lastDate = user.lastCompletedDate,
               Mission.dateFormatter.string(from: lastDate) == yesterdayString {
                // Completou ontem, incrementa streak
                newStreak += 1
            } else if user.lastCompletedDate == nil || user.currentStreak == 0 {
                // Primeiro dia ou streak já estava zerado
                newStreak = 1
            } else {
                // Perdeu o streak, começa de novo
                newStreak = 1
            }

            let newLongestStreak = max(user.longestStreak, newStreak)

            updates["currentStreak"] = newStreak
            updates["longestStreak"] = newLongestStreak
            updates["lastCompletedDate"] = Timestamp(date: Date())
        }

        if !updates.isEmpty {
            try await firebase.usersCollection.document(userId).updateData(updates)
        }
    }

    /// Atualiza configuração de notificações
    func updateNotificationSettings(userId: String, enabled: Bool) async throws {
        try await firebase.usersCollection.document(userId).updateData([
            "notificationsEnabled": enabled
        ])
    }

    // MARK: - Queries

    /// Busca usuários de um squad
    func getUsersInSquad(squadCode: String) async throws -> [User] {
        try await firebase.documents(
            firebase.usersCollection.whereField("squadCode", isEqualTo: squadCode),
            as: User.self
        )
    }

    /// Verifica se um usuário existe
    func userExists(id: String) async -> Bool {
        do {
            _ = try await getUser(id: id)
            return true
        } catch {
            return false
        }
    }

    // MARK: - Real-time Listener

    /// Observa mudanças em um usuário
    func observeUser(
        id: String,
        onChange: @escaping (User?) -> Void
    ) -> ListenerRegistration {
        firebase.usersCollection.document(id).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                onChange(nil)
                return
            }
            let user = try? snapshot.data(as: User.self)
            onChange(user)
        }
    }
}

// MARK: - Errors
enum UserServiceError: LocalizedError {
    case invalidUserId
    case userNotFound
    case updateFailed

    var errorDescription: String? {
        switch self {
        case .invalidUserId:
            return "ID de usuário inválido."
        case .userNotFound:
            return "Usuário não encontrado."
        case .updateFailed:
            return "Falha ao atualizar usuário."
        }
    }
}
