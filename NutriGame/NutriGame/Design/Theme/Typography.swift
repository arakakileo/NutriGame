//
//  Typography.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

extension Font {
    // MARK: - Títulos
    static let titleLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    static let titleMedium = Font.system(size: 28, weight: .bold, design: .rounded)
    static let titleSmall = Font.system(size: 22, weight: .semibold, design: .rounded)

    // MARK: - Body
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let bodySmall = Font.system(size: 13, weight: .regular)

    // MARK: - Números/XP (destaque)
    static let xpLarge = Font.system(size: 48, weight: .bold, design: .rounded)
    static let xpMedium = Font.system(size: 24, weight: .bold, design: .rounded)
    static let xpSmall = Font.system(size: 18, weight: .semibold, design: .rounded)

    // MARK: - Labels
    static let caption = Font.system(size: 12, weight: .medium)
    static let overline = Font.system(size: 10, weight: .semibold)
}

// MARK: - Text Style Modifiers
extension View {
    func titleLargeStyle() -> some View {
        self.font(.titleLarge)
            .foregroundColor(.textPrimary)
    }

    func titleMediumStyle() -> some View {
        self.font(.titleMedium)
            .foregroundColor(.textPrimary)
    }

    func titleSmallStyle() -> some View {
        self.font(.titleSmall)
            .foregroundColor(.textPrimary)
    }

    func bodyLargeStyle() -> some View {
        self.font(.bodyLarge)
            .foregroundColor(.textPrimary)
    }

    func bodySecondaryStyle() -> some View {
        self.font(.bodyMedium)
            .foregroundColor(.textSecondary)
    }

    func captionStyle() -> some View {
        self.font(.caption)
            .foregroundColor(.textTertiary)
    }

    func xpStyle(size: XPFontSize = .medium) -> some View {
        self.font(size.font)
            .foregroundColor(.accentGreen)
    }
}

enum XPFontSize {
    case small, medium, large

    var font: Font {
        switch self {
        case .small: return .xpSmall
        case .medium: return .xpMedium
        case .large: return .xpLarge
        }
    }
}
