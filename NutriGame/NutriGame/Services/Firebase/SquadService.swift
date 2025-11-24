//
//  SquadService.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import FirebaseFirestore

final class SquadService {
    static let shared = SquadService()

    private let firebase = FirebaseService.shared
    private let userService = UserService.shared

    private init() {}

    // MARK: - CRUD Operations

    /// Cria um novo squad
    func createSquad(name: String, ownerUserId: String) async throws -> Squad {
        // Gera um código único
        var code = Squad.generateCode()
        var attempts = 0
        let maxAttempts = 10

        // Garante que o código é único
        while try await squadExists(code: code) && attempts < maxAttempts {
            code = Squad.generateCode()
            attempts += 1
        }

        if attempts >= maxAttempts {
            throw SquadServiceError.codeGenerationFailed
        }

        let squad = Squad(
            id: code,
            name: name,
            ownerUserId: ownerUserId,
            code: code,
            memberCount: 1
        )

        try firebase.squadsCollection.document(code).setData(from: squad)

        // Atualiza o usuário com o código do squad
        try await userService.updateSquadCode(userId: ownerUserId, squadCode: code)

        // Marca o usuário como nutricionista
        try await firebase.usersCollection.document(ownerUserId).updateData([
            "isNutritionist": true
        ])

        return squad
    }

    /// Busca um squad pelo código
    func getSquad(code: String) async throws -> Squad {
        let normalizedCode = Squad.normalizeCode(code)
        return try await firebase.document(
            firebase.squadsCollection.document(normalizedCode),
            as: Squad.self
        )
    }

    /// Atualiza um squad
    func updateSquad(_ squad: Squad) async throws {
        guard let squadId = squad.id else {
            throw SquadServiceError.invalidSquadCode
        }
        try firebase.squadsCollection.document(squadId).setData(from: squad, merge: true)
    }

    /// Deleta um squad
    func deleteSquad(code: String, ownerUserId: String) async throws {
        let squad = try await getSquad(code: code)

        // Verifica se o usuário é o owner
        guard squad.ownerUserId == ownerUserId else {
            throw SquadServiceError.notOwner
        }

        // Remove todos os membros do squad
        let members = try await userService.getUsersInSquad(squadCode: code)
        for member in members {
            if let memberId = member.id {
                try await userService.updateSquadCode(userId: memberId, squadCode: nil)
            }
        }

        // Deleta o squad
        try await firebase.squadsCollection.document(code).delete()
    }

    // MARK: - Member Management

    /// Adiciona um usuário ao squad
    func joinSquad(userId: String, code: String) async throws -> Squad {
        let normalizedCode = Squad.normalizeCode(code)

        // Valida formato do código
        guard Squad.isValidCodeFormat(normalizedCode) else {
            throw SquadServiceError.invalidSquadCode
        }

        // Verifica se o squad existe
        let squad = try await getSquad(code: normalizedCode)

        // Verifica se o squad está cheio
        guard !squad.isFull else {
            throw SquadServiceError.squadFull
        }

        // Verifica se o usuário já está em um squad
        let user = try await userService.getUser(id: userId)
        if let currentSquad = user.squadCode, !currentSquad.isEmpty {
            // Remove do squad atual primeiro
            try await leaveSquad(userId: userId)
        }

        // Atualiza o usuário com o novo squad
        try await userService.updateSquadCode(userId: userId, squadCode: normalizedCode)

        // Incrementa contador de membros
        try await firebase.squadsCollection.document(normalizedCode).updateData([
            "memberCount": FieldValue.increment(Int64(1))
        ])

        // Retorna squad atualizado
        return try await getSquad(code: normalizedCode)
    }

    /// Remove um usuário do squad
    func leaveSquad(userId: String) async throws {
        let user = try await userService.getUser(id: userId)

        guard let squadCode = user.squadCode, !squadCode.isEmpty else {
            return // Usuário não está em nenhum squad
        }

        // Atualiza o usuário
        try await userService.updateSquadCode(userId: userId, squadCode: nil)

        // Decrementa contador de membros
        try await firebase.squadsCollection.document(squadCode).updateData([
            "memberCount": FieldValue.increment(Int64(-1))
        ])
    }

    // MARK: - Queries

    /// Verifica se um squad existe
    func squadExists(code: String) async throws -> Bool {
        let normalizedCode = Squad.normalizeCode(code)
        let snapshot = try await firebase.squadsCollection.document(normalizedCode).getDocument()
        return snapshot.exists
    }

    /// Busca squads de um nutricionista
    func getSquadsByOwner(userId: String) async throws -> [Squad] {
        try await firebase.documents(
            firebase.squadsCollection.whereField("ownerUserId", isEqualTo: userId),
            as: Squad.self
        )
    }

    // MARK: - Real-time Listener

    /// Observa mudanças em um squad
    func observeSquad(
        code: String,
        onChange: @escaping (Squad?) -> Void
    ) -> ListenerRegistration {
        firebase.squadsCollection.document(code).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                onChange(nil)
                return
            }
            let squad = try? snapshot.data(as: Squad.self)
            onChange(squad)
        }
    }
}

// MARK: - Errors
enum SquadServiceError: LocalizedError {
    case invalidSquadCode
    case squadNotFound
    case squadFull
    case notOwner
    case codeGenerationFailed
    case alreadyInSquad

    var errorDescription: String? {
        switch self {
        case .invalidSquadCode:
            return "Código do squad inválido. Verifique com seu nutricionista."
        case .squadNotFound:
            return "Squad não encontrado. Verifique o código."
        case .squadFull:
            return "Este squad atingiu o limite de membros."
        case .notOwner:
            return "Apenas o criador do squad pode realizar esta ação."
        case .codeGenerationFailed:
            return "Erro ao gerar código. Tente novamente."
        case .alreadyInSquad:
            return "Você já está em um squad."
        }
    }
}
