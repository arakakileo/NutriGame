//
//  PremiumFeature.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import FirebaseFirestore

// MARK: - Premium Plan
struct PremiumPlan: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var price: Double
    var currency: String
    var duration: PlanDuration
    var features: [String]
    var isActive: Bool

    init(
        id: String? = nil,
        name: String,
        price: Double,
        currency: String = "BRL",
        duration: PlanDuration,
        features: [String],
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.currency = currency
        self.duration = duration
        self.features = features
        self.isActive = isActive
    }

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: price)) ?? "R$ \(price)"
    }

    var pricePerMonth: Double {
        switch duration {
        case .monthly: return price
        case .yearly: return price / 12
        }
    }
}

// MARK: - Plan Duration
enum PlanDuration: String, Codable {
    case monthly = "monthly"
    case yearly = "yearly"

    var displayName: String {
        switch self {
        case .monthly: return "Mensal"
        case .yearly: return "Anual"
        }
    }
}

// MARK: - Premium Feature Keys
enum PremiumFeatureKey: String, CaseIterable {
    // Paciente
    case historyComplete = "history_complete"
    case advancedStats = "advanced_stats"
    case noAds = "no_ads"

    // Nutricionista
    case unlimitedMembers = "unlimited_members"
    case multipleSquads = "multiple_squads"
    case customMissions = "custom_missions"
    case exportData = "export_data"

    var displayName: String {
        switch self {
        case .historyComplete: return "Histórico Completo"
        case .advancedStats: return "Estatísticas Avançadas"
        case .noAds: return "Sem Anúncios"
        case .unlimitedMembers: return "Membros Ilimitados"
        case .multipleSquads: return "Múltiplos Squads"
        case .customMissions: return "Missões Customizadas"
        case .exportData: return "Exportar Dados"
        }
    }

    var description: String {
        switch self {
        case .historyComplete:
            return "Acesse o histórico completo de rankings de semanas anteriores"
        case .advancedStats:
            return "Visualize gráficos de evolução e tendências do seu progresso"
        case .noAds:
            return "Experiência limpa sem anúncios"
        case .unlimitedMembers:
            return "Tenha mais de 100 membros no seu squad"
        case .multipleSquads:
            return "Gerencie múltiplos grupos de pacientes"
        case .customMissions:
            return "Crie missões personalizadas para seus pacientes"
        case .exportData:
            return "Exporte relatórios em PDF com dados dos pacientes"
        }
    }

    var icon: String {
        switch self {
        case .historyComplete: return "clock.arrow.circlepath"
        case .advancedStats: return "chart.line.uptrend.xyaxis"
        case .noAds: return "xmark.circle"
        case .unlimitedMembers: return "person.3.fill"
        case .multipleSquads: return "rectangle.stack.fill"
        case .customMissions: return "checklist"
        case .exportData: return "doc.text.fill"
        }
    }

    var isForNutritionist: Bool {
        switch self {
        case .unlimitedMembers, .multipleSquads, .customMissions, .exportData:
            return true
        default:
            return false
        }
    }
}

// MARK: - Mock Data
extension PremiumPlan {
    static let mockPatientMonthly = PremiumPlan(
        id: "patient-monthly",
        name: "Premium Paciente",
        price: 9.90,
        currency: "BRL",
        duration: .monthly,
        features: [
            PremiumFeatureKey.historyComplete.rawValue,
            PremiumFeatureKey.advancedStats.rawValue,
            PremiumFeatureKey.noAds.rawValue
        ]
    )

    static let mockNutritionistMonthly = PremiumPlan(
        id: "nutri-monthly",
        name: "Premium Nutricionista",
        price: 29.90,
        currency: "BRL",
        duration: .monthly,
        features: [
            PremiumFeatureKey.unlimitedMembers.rawValue,
            PremiumFeatureKey.multipleSquads.rawValue,
            PremiumFeatureKey.customMissions.rawValue,
            PremiumFeatureKey.exportData.rawValue,
            PremiumFeatureKey.noAds.rawValue
        ]
    )
}
