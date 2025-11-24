//
//  AppTheme.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

// MARK: - App Theme
struct AppTheme {
    // Animation durations
    static let animationFast: Double = 0.2
    static let animationNormal: Double = 0.3
    static let animationSlow: Double = 0.5
    static let animationLevelUp: Double = 1.5

    // Shadow
    static let shadowRadius: CGFloat = 8
    static let shadowOpacity: Double = 0.1

    // Button heights
    static let buttonHeightSmall: CGFloat = 36
    static let buttonHeightMedium: CGFloat = 48
    static let buttonHeightLarge: CGFloat = 56

    // Card
    static let cardCornerRadius: CGFloat = CornerRadius.large
    static let cardShadow = Shadow(
        color: Color.black.opacity(0.08),
        radius: 8,
        x: 0,
        y: 4
    )
}

// MARK: - Shadow Helper
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Modifiers
extension View {
    func cardStyle() -> some View {
        self
            .background(Color.bgSecondary)
            .cornerRadius(AppTheme.cardCornerRadius)
            .shadow(
                color: AppTheme.cardShadow.color,
                radius: AppTheme.cardShadow.radius,
                x: AppTheme.cardShadow.x,
                y: AppTheme.cardShadow.y
            )
    }

    func primaryButtonStyle() -> some View {
        self
            .frame(height: AppTheme.buttonHeightLarge)
            .frame(maxWidth: .infinity)
            .background(Color.accentPurple)
            .foregroundColor(.white)
            .font(.system(size: 17, weight: .semibold))
            .cornerRadius(CornerRadius.medium)
    }

    func secondaryButtonStyle() -> some View {
        self
            .frame(height: AppTheme.buttonHeightMedium)
            .frame(maxWidth: .infinity)
            .background(Color.bgSecondary)
            .foregroundColor(.accentPurple)
            .font(.system(size: 15, weight: .medium))
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(Color.accentPurple, lineWidth: 1.5)
            )
    }

    func animateOnAppear() -> some View {
        self.transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

// MARK: - Preview Helper
struct ThemePreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Colors
                Section("Colors") {
                    HStack {
                        colorSwatch(.accentGreen, "Green")
                        colorSwatch(.accentPurple, "Purple")
                        colorSwatch(.accentOrange, "Orange")
                    }
                }

                // Typography
                Section("Typography") {
                    Text("Title Large").font(.titleLarge)
                    Text("Title Medium").font(.titleMedium)
                    Text("Body Large").font(.bodyLarge)
                    Text("XP Medium").font(.xpMedium).foregroundColor(.accentGreen)
                }

                // Buttons
                Section("Buttons") {
                    Button("Primary Button") {}
                        .primaryButtonStyle()

                    Button("Secondary Button") {}
                        .secondaryButtonStyle()
                }
            }
            .padding()
        }
    }

    private func colorSwatch(_ color: Color, _ name: String) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: CornerRadius.small)
                .fill(color)
                .frame(width: 60, height: 60)
            Text(name).font(.caption)
        }
    }
}

#Preview {
    ThemePreview()
}
