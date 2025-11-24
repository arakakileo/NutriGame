//
//  Spacing.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

// MARK: - Spacing
enum Spacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius
enum CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let extraLarge: CGFloat = 24
    static let full: CGFloat = 9999
}

// MARK: - Icon Sizes
enum IconSize {
    static let small: CGFloat = 16
    static let medium: CGFloat = 24
    static let large: CGFloat = 32
    static let extraLarge: CGFloat = 48
}

// MARK: - Avatar Sizes
enum AvatarSize {
    case small, medium, large, extraLarge

    var dimension: CGFloat {
        switch self {
        case .small: return 32
        case .medium: return 48
        case .large: return 64
        case .extraLarge: return 96
        }
    }
}

// MARK: - View Extension for Spacing
extension View {
    func padding(_ spacing: CGFloat) -> some View {
        self.padding(spacing)
    }

    func horizontalPadding(_ value: CGFloat = Spacing.md) -> some View {
        self.padding(.horizontal, value)
    }

    func verticalPadding(_ value: CGFloat = Spacing.md) -> some View {
        self.padding(.vertical, value)
    }

    func cardPadding() -> some View {
        self.padding(Spacing.md)
    }

    func screenPadding() -> some View {
        self.padding(.horizontal, Spacing.md)
    }
}
