//
//  BaseCard.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

// MARK: - Base Card
struct BaseCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadowEnabled: Bool

    init(
        padding: CGFloat = Spacing.md,
        cornerRadius: CGFloat = CornerRadius.medium,
        shadowEnabled: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowEnabled = shadowEnabled
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(Color.bgSecondary)
            .cornerRadius(cornerRadius)
            .shadow(
                color: shadowEnabled ? Color.black.opacity(0.1) : .clear,
                radius: shadowEnabled ? 8 : 0,
                x: 0,
                y: shadowEnabled ? 4 : 0
            )
    }
}

// MARK: - Card View Modifier
struct CardModifier: ViewModifier {
    let padding: CGFloat
    let cornerRadius: CGFloat
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }
}

extension View {
    func cardStyle(
        padding: CGFloat = Spacing.md,
        cornerRadius: CGFloat = CornerRadius.medium,
        backgroundColor: Color = .bgSecondary
    ) -> some View {
        modifier(CardModifier(
            padding: padding,
            cornerRadius: cornerRadius,
            backgroundColor: backgroundColor
        ))
    }
}

// MARK: - Interactive Card
struct InteractiveCard<Content: View>: View {
    let content: Content
    let action: () -> Void

    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            content
                .padding(Spacing.md)
                .background(Color.bgSecondary)
                .cornerRadius(CornerRadius.medium)
        }
        .buttonStyle(CardButtonStyle())
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Gradient Card
struct GradientCard<Content: View>: View {
    let gradient: LinearGradient
    let content: Content

    init(
        colors: [Color] = [.accentPurple, .accentPurple.opacity(0.7)],
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing,
        @ViewBuilder content: () -> Content
    ) {
        self.gradient = LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
        self.content = content()
    }

    var body: some View {
        content
            .padding(Spacing.md)
            .background(gradient)
            .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - Stats Card
struct StatsCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.xpMedium)
                .foregroundColor(.textPrimary)

            Text(label)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(Color.bgSecondary)
        .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let icon: String
    let title: String
    let message: String
    let type: InfoCardType

    enum InfoCardType {
        case info, success, warning, error

        var color: Color {
            switch self {
            case .info: return .accentPurple
            case .success: return .accentGreen
            case .warning: return .warning
            case .error: return .error
            }
        }

        var defaultIcon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
    }

    init(
        title: String,
        message: String,
        type: InfoCardType = .info,
        icon: String? = nil
    ) {
        self.title = title
        self.message = message
        self.type = type
        self.icon = icon ?? type.defaultIcon
    }

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(type.color)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(.bodyMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)

                Text(message)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(Spacing.md)
        .background(type.color.opacity(0.1))
        .cornerRadius(CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .stroke(type.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Avatar View
struct AvatarView: View {
    let name: String
    let imageUrl: String?
    let size: AvatarSize

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

        var fontSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 18
            case .large: return 24
            case .extraLarge: return 36
            }
        }
    }

    init(name: String, imageUrl: String? = nil, size: AvatarSize = .medium) {
        self.name = name
        self.imageUrl = imageUrl
        self.size = size
    }

    private var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var body: some View {
        Group {
            if let url = imageUrl, let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        placeholderView
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
            } else {
                placeholderView
            }
        }
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(Circle())
    }

    private var placeholderView: some View {
        ZStack {
            Circle()
                .fill(Color.accentPurple.opacity(0.2))

            Text(initials)
                .font(.system(size: size.fontSize, weight: .semibold))
                .foregroundColor(.accentPurple)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            // Base Card
            BaseCard {
                Text("Base Card Content")
                    .foregroundColor(.textPrimary)
            }

            // Interactive Card
            InteractiveCard(action: { print("Tapped") }) {
                HStack {
                    Text("Interactive Card")
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.textSecondary)
                }
            }

            // Gradient Card
            GradientCard {
                VStack(alignment: .leading) {
                    Text("Premium")
                        .font(.titleSmall)
                        .foregroundColor(.white)
                    Text("Desbloqueie recursos exclusivos")
                        .font(.bodySmall)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Stats Cards
            HStack(spacing: Spacing.md) {
                StatsCard(icon: "bolt.fill", value: "1,250", label: "XP Total", color: .accentGreen)
                StatsCard(icon: "flame.fill", value: "7", label: "Streak", color: .accentOrange)
                StatsCard(icon: "star.fill", value: "5", label: "Nível", color: .accentPurple)
            }

            // Info Cards
            InfoCard(title: "Parabéns!", message: "Você completou todas as missões de hoje.", type: .success)
            InfoCard(title: "Atenção", message: "Seu streak está em risco. Complete uma missão hoje!", type: .warning)
            InfoCard(title: "Erro", message: "Não foi possível carregar os dados.", type: .error)

            // Avatars
            HStack(spacing: Spacing.md) {
                AvatarView(name: "João Silva", size: .small)
                AvatarView(name: "Maria Santos", size: .medium)
                AvatarView(name: "Pedro Lima", size: .large)
            }
        }
        .padding()
    }
    .background(Color.bgPrimary)
}
