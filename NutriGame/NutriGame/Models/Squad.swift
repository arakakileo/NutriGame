//
//  Squad.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import FirebaseFirestore

struct Squad: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var ownerUserId: String
    var code: String
    var memberCount: Int
    var maxMembers: Int
    var createdAt: Date

    // Preparado para monetização
    var isPremium: Bool
    var premiumFeatures: [String]

    init(
        id: String? = nil,
        name: String,
        ownerUserId: String,
        code: String,
        memberCount: Int = 1,
        maxMembers: Int = 100,
        createdAt: Date = Date(),
        isPremium: Bool = false,
        premiumFeatures: [String] = []
    ) {
        self.id = id
        self.name = name
        self.ownerUserId = ownerUserId
        self.code = code
        self.memberCount = memberCount
        self.maxMembers = maxMembers
        self.createdAt = createdAt
        self.isPremium = isPremium
        self.premiumFeatures = premiumFeatures
    }

    // MARK: - Computed Properties

    var isFull: Bool {
        memberCount >= maxMembers
    }

    var availableSpots: Int {
        max(0, maxMembers - memberCount)
    }

    // MARK: - Static Methods

    /// Gera um código único de 6 caracteres alfanuméricos
    static func generateCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }

    /// Valida formato do código (6 chars, uppercase alfanumérico)
    static func isValidCodeFormat(_ code: String) -> Bool {
        let pattern = "^[A-Z0-9]{6}$"
        return code.range(of: pattern, options: .regularExpression) != nil
    }

    /// Normaliza código (uppercase, remove espaços)
    static func normalizeCode(_ code: String) -> String {
        code.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Mock Data
extension Squad {
    static let mock = Squad(
        id: "NUTRI1",
        name: "Squad da Dra. Maria",
        ownerUserId: "mock-nutri-id",
        code: "NUTRI1",
        memberCount: 15,
        maxMembers: 100,
        createdAt: Date().addingTimeInterval(-60 * 24 * 60 * 60)
    )
}
