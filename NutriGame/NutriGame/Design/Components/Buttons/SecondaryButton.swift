//
//  SecondaryButton.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    let color: Color
    let isEnabled: Bool
    let isLoading: Bool

    init(color: Color = .accentPurple, isEnabled: Bool = true, isLoading: Bool = false) {
        self.color = color
        self.isEnabled = isEnabled
        self.isLoading = isLoading
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: Spacing.sm) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: color))
                    .scaleEffect(0.8)
            }

            configuration.label
        }
        .font(.system(size: 17, weight: .semibold))
        .foregroundColor(isEnabled && !isLoading ? color : .gray)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .stroke(isEnabled && !isLoading ? color : .gray.opacity(0.5), lineWidth: 2)
        )
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        .opacity(configuration.isPressed ? 0.8 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - View Extension
extension View {
    func secondaryButtonStyle(color: Color = .accentPurple, isEnabled: Bool = true, isLoading: Bool = false) -> some View {
        self.buttonStyle(SecondaryButtonStyle(color: color, isEnabled: isEnabled, isLoading: isLoading))
    }
}

// MARK: - Secondary Button View
struct SecondaryButton: View {
    let title: String
    let color: Color
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void

    init(
        _ title: String,
        color: Color = .accentPurple,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.color = color
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: {
            if isEnabled && !isLoading {
                HapticManager.shared.buttonTap()
                action()
            }
        }) {
            Text(isLoading ? "Carregando..." : title)
        }
        .secondaryButtonStyle(color: color, isEnabled: isEnabled, isLoading: isLoading)
        .disabled(!isEnabled || isLoading)
    }
}

// MARK: - Tertiary/Text Button Style
struct TertiaryButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(color)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension View {
    func tertiaryButtonStyle(color: Color = .accentPurple) -> some View {
        self.buttonStyle(TertiaryButtonStyle(color: color))
    }
}

// MARK: - Destructive Button Style
struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.error)
            .cornerRadius(CornerRadius.medium)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension View {
    func destructiveButtonStyle() -> some View {
        self.buttonStyle(DestructiveButtonStyle())
    }
}

// MARK: - Small Button Style
struct SmallButtonStyle: ButtonStyle {
    let color: Color
    let filled: Bool

    init(color: Color = .accentPurple, filled: Bool = true) {
        self.color = color
        self.filled = filled
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(filled ? .white : color)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                Group {
                    if filled {
                        color
                    } else {
                        RoundedRectangle(cornerRadius: CornerRadius.small)
                            .stroke(color, lineWidth: 1.5)
                    }
                }
            )
            .cornerRadius(CornerRadius.small)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension View {
    func smallButtonStyle(color: Color = .accentPurple, filled: Bool = true) -> some View {
        self.buttonStyle(SmallButtonStyle(color: color, filled: filled))
    }
}

#Preview {
    VStack(spacing: Spacing.lg) {
        SecondaryButton("Cancelar") {
            print("Tapped")
        }

        SecondaryButton("Verde", color: .accentGreen) {
            print("Tapped")
        }

        SecondaryButton("Disabled", isEnabled: false) {
            print("Tapped")
        }

        Button("Excluir Conta") {}
            .destructiveButtonStyle()

        Button("Texto Link") {}
            .tertiaryButtonStyle()

        HStack(spacing: Spacing.md) {
            Button("Pequeno") {}
                .smallButtonStyle()

            Button("Outlined") {}
                .smallButtonStyle(filled: false)
        }
    }
    .padding()
    .background(Color.bgPrimary)
}
