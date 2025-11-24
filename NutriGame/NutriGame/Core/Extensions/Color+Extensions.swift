//
//  Color+Extensions.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

// Hex initializer já está em Colors.swift

// MARK: - Additional Color Utilities
extension Color {
    /// Retorna uma versão mais clara da cor
    func lighter(by percentage: CGFloat = 0.2) -> Color {
        self.opacity(1 - percentage)
    }

    /// Retorna uma versão mais escura da cor
    func darker(by percentage: CGFloat = 0.2) -> Color {
        self.opacity(1 + percentage)
    }
}

// MARK: - Gradient Helpers
extension LinearGradient {
    static func diagonal(_ colors: [Color]) -> LinearGradient {
        LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func vertical(_ colors: [Color]) -> LinearGradient {
        LinearGradient(
            colors: colors,
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func horizontal(_ colors: [Color]) -> LinearGradient {
        LinearGradient(
            colors: colors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
