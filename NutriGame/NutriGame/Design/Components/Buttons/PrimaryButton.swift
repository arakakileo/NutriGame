//
//  PrimaryButton.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let isLoading: Bool

    init(isEnabled: Bool = true, isLoading: Bool = false) {
        self.isEnabled = isEnabled
        self.isLoading = isLoading
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: Spacing.sm) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
            }

            configuration.label
        }
        .font(.system(size: 17, weight: .semibold))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(
            Group {
                if isEnabled && !isLoading {
                    LinearGradient(
                        colors: [Color.accentPurple, Color.accentPurple.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                } else {
                    Color.gray.opacity(0.5)
                }
            }
        )
        .cornerRadius(CornerRadius.medium)
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        .opacity(configuration.isPressed ? 0.9 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - View Extension
extension View {
    func primaryButtonStyle(isEnabled: Bool = true, isLoading: Bool = false) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled, isLoading: isLoading))
    }
}

// MARK: - Primary Button View
struct PrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void

    init(
        _ title: String,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
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
        .primaryButtonStyle(isEnabled: isEnabled, isLoading: isLoading)
        .disabled(!isEnabled || isLoading)
    }
}

// MARK: - Primary Button with Icon
struct PrimaryButtonWithIcon: View {
    let title: String
    let icon: String
    let iconPosition: IconPosition
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void

    enum IconPosition {
        case leading
        case trailing
    }

    init(
        _ title: String,
        icon: String,
        iconPosition: IconPosition = .leading,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.iconPosition = iconPosition
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
            HStack(spacing: Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    if iconPosition == .leading {
                        Image(systemName: icon)
                    }

                    Text(title)

                    if iconPosition == .trailing {
                        Image(systemName: icon)
                    }
                }
            }
        }
        .primaryButtonStyle(isEnabled: isEnabled, isLoading: isLoading)
        .disabled(!isEnabled || isLoading)
    }
}

#Preview {
    VStack(spacing: Spacing.lg) {
        PrimaryButton("Continuar") {
            print("Tapped")
        }

        PrimaryButton("Disabled", isEnabled: false) {
            print("Tapped")
        }

        PrimaryButton("Loading", isLoading: true) {
            print("Tapped")
        }

        PrimaryButtonWithIcon("Tirar Foto", icon: "camera.fill") {
            print("Tapped")
        }

        PrimaryButtonWithIcon("Próximo", icon: "arrow.right", iconPosition: .trailing) {
            print("Tapped")
        }
    }
    .padding()
    .background(Color.bgPrimary)
}
