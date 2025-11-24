//
//  Colors.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

extension Color {
    // MARK: - Background (Dark Mode adaptive)
    static let bgPrimary = Color(.systemBackground)
    static let bgSecondary = Color(.secondarySystemBackground)
    static let bgTertiary = Color(.tertiarySystemBackground)

    // MARK: - Accent/Gamification (Fixed colors)
    static let accentGreen = Color(hex: "#00E676")    // Verde Neon - XP, sucesso
    static let accentPurple = Color(hex: "#7C4DFF")   // Roxo Elétrico - Níveis
    static let accentOrange = Color(hex: "#FF6D00")   // Laranja Vivo - Streak/Fogo

    // MARK: - Mission Colors
    static let missionBreakfast = Color(hex: "#FFB74D")  // Laranja claro
    static let missionLunch = Color(hex: "#81C784")      // Verde
    static let missionDinner = Color(hex: "#7986CB")     // Azul/Roxo
    static let missionSnack = Color(hex: "#F06292")      // Rosa
    static let missionWorkout = Color(hex: "#4FC3F7")    // Azul claro
    static let missionWater = Color(hex: "#4DD0E1")      // Cyan

    // MARK: - Status
    static let success = Color(hex: "#4CAF50")
    static let warning = Color(hex: "#FFC107")
    static let error = Color(hex: "#F44336")

    // MARK: - Text (Dark Mode adaptive)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)

    // MARK: - Gradients
    static let xpGradient = LinearGradient(
        colors: [accentGreen, accentGreen.opacity(0.7)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let levelGradient = LinearGradient(
        colors: [accentPurple, accentPurple.opacity(0.7)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let streakGradient = LinearGradient(
        colors: [accentOrange, Color(hex: "#FF9800")],
        startPoint: .bottom,
        endPoint: .top
    )

    // MARK: - Mission Color Helper
    static func forMission(_ type: MissionType) -> Color {
        switch type {
        case .breakfast: return missionBreakfast
        case .lunch: return missionLunch
        case .dinner: return missionDinner
        case .snack: return missionSnack
        case .workout: return missionWorkout
        case .hydration: return missionWater
        }
    }
}

// MARK: - Hex Color Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
