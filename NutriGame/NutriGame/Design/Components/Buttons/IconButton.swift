//
//  IconButton.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

// MARK: - Icon Button
struct IconButton: View {
    let icon: String
    let size: IconButtonSize
    let style: IconButtonStyle
    let action: () -> Void

    enum IconButtonSize {
        case small, medium, large

        var buttonSize: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 44
            case .large: return 56
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 18
            case .large: return 24
            }
        }
    }

    enum IconButtonStyle {
        case filled(Color)
        case outline(Color)
        case ghost(Color)

        var foregroundColor: Color {
            switch self {
            case .filled: return .white
            case .outline(let color): return color
            case .ghost(let color): return color
            }
        }

        @ViewBuilder
        func background(for size: CGFloat) -> some View {
            switch self {
            case .filled(let color):
                Circle()
                    .fill(color)
            case .outline(let color):
                Circle()
                    .stroke(color, lineWidth: 2)
            case .ghost(let color):
                Circle()
                    .fill(color.opacity(0.1))
            }
        }
    }

    init(
        icon: String,
        size: IconButtonSize = .medium,
        style: IconButtonStyle = .filled(.accentPurple),
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size.iconSize, weight: .semibold))
                .foregroundColor(style.foregroundColor)
                .frame(width: size.buttonSize, height: size.buttonSize)
                .background(style.background(for: size.buttonSize))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    init(
        icon: String = "plus",
        color: Color = .accentPurple,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(color)
                .clipShape(Circle())
                .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Close Button
struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textSecondary)
                .frame(width: 30, height: 30)
                .background(Color.bgTertiary)
                .clipShape(Circle())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Back Button
struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textPrimary)
                .frame(width: 40, height: 40)
                .background(Color.bgSecondary)
                .clipShape(Circle())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Checkbox Button
struct CheckboxButton: View {
    @Binding var isChecked: Bool
    let label: String?
    let onToggle: ((Bool) -> Void)?

    init(
        isChecked: Binding<Bool>,
        label: String? = nil,
        onToggle: ((Bool) -> Void)? = nil
    ) {
        self._isChecked = isChecked
        self.label = label
        self.onToggle = onToggle
    }

    var body: some View {
        Button(action: {
            isChecked.toggle()
            HapticManager.shared.buttonTap()
            onToggle?(isChecked)
        }) {
            HStack(spacing: Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isChecked ? Color.accentGreen : Color.textSecondary, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isChecked {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.accentGreen)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                if let label = label {
                    Text(label)
                        .font(.bodyMedium)
                        .foregroundColor(.textPrimary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: Spacing.xl) {
        // Icon buttons
        HStack(spacing: Spacing.lg) {
            IconButton(icon: "camera.fill", size: .small, style: .filled(.accentPurple)) {}
            IconButton(icon: "camera.fill", size: .medium, style: .filled(.accentGreen)) {}
            IconButton(icon: "camera.fill", size: .large, style: .filled(.accentOrange)) {}
        }

        HStack(spacing: Spacing.lg) {
            IconButton(icon: "heart.fill", size: .medium, style: .outline(.accentPurple)) {}
            IconButton(icon: "star.fill", size: .medium, style: .ghost(.accentPurple)) {}
        }

        // Special buttons
        HStack(spacing: Spacing.lg) {
            CloseButton {}
            BackButton {}
        }

        // FAB
        FloatingActionButton {}

        // Checkbox
        VStack(alignment: .leading, spacing: Spacing.md) {
            CheckboxButton(isChecked: .constant(false), label: "Unchecked")
            CheckboxButton(isChecked: .constant(true), label: "Checked")
        }
    }
    .padding()
    .background(Color.bgPrimary)
}
