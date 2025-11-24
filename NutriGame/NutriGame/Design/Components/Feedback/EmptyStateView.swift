//
//  EmptyStateView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.textTertiary)

            // Text
            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.titleSmall)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Action
            if let title = actionTitle, let action = action {
                PrimaryButton(title, action: action)
                    .padding(.top, Spacing.md)
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preset Empty States
struct NoMissionsEmptyState: View {
    var body: some View {
        EmptyStateView(
            icon: "checkmark.circle",
            title: "Todas as missões completas!",
            message: "Parabéns! Você completou todas as missões de hoje. Volte amanhã para mais desafios."
        )
    }
}

struct NoSquadEmptyState: View {
    let onJoinSquad: () -> Void

    var body: some View {
        EmptyStateView(
            icon: "person.3",
            title: "Você ainda não está em um squad",
            message: "Entre em um squad para competir com outros participantes e aparecer no ranking.",
            actionTitle: "Entrar em um Squad",
            action: onJoinSquad
        )
    }
}

struct NoPhotosEmptyState: View {
    let onTakePhoto: () -> Void

    var body: some View {
        EmptyStateView(
            icon: "photo.on.rectangle",
            title: "Nenhuma foto ainda",
            message: "Complete suas missões de refeição para começar a construir sua galeria de fotos.",
            actionTitle: "Completar Missão",
            action: onTakePhoto
        )
    }
}

struct NoRankingEmptyState: View {
    var body: some View {
        EmptyStateView(
            icon: "trophy",
            title: "Ranking vazio",
            message: "Seja o primeiro a aparecer no ranking! Complete missões para ganhar XP."
        )
    }
}

struct NoSearchResultsEmptyState: View {
    let searchTerm: String

    var body: some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "Nenhum resultado",
            message: "Não encontramos resultados para \"\(searchTerm)\". Tente buscar por outro termo."
        )
    }
}

struct NoNotificationsEmptyState: View {
    var body: some View {
        EmptyStateView(
            icon: "bell.slash",
            title: "Nenhuma notificação",
            message: "Você não tem notificações no momento. Continue completando missões!"
        )
    }
}

// MARK: - Compact Empty State (for inline use)
struct CompactEmptyState: View {
    let icon: String
    let message: String

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.textTertiary)

            Text(message)
                .font(.bodySmall)
                .foregroundColor(.textSecondary)

            Spacer()
        }
        .padding(Spacing.lg)
        .background(Color.bgSecondary)
        .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - Illustrated Empty State
struct IllustratedEmptyState: View {
    let illustration: String // SF Symbol name
    let illustrationColor: Color
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        illustration: String,
        illustrationColor: Color = .accentPurple,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.illustration = illustration
        self.illustrationColor = illustrationColor
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Illustrated circle
            ZStack {
                Circle()
                    .fill(illustrationColor.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: illustration)
                    .font(.system(size: 48))
                    .foregroundColor(illustrationColor)
            }

            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.titleSmall)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let title = actionTitle, let action = action {
                PrimaryButton(title, action: action)
                    .padding(.top, Spacing.sm)
            }
        }
        .padding(Spacing.xl)
    }
}

// MARK: - First Time User Empty State
struct FirstTimeEmptyState: View {
    let featureName: String
    let description: String
    let steps: [String]
    let onGetStarted: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Welcome icon
            ZStack {
                Circle()
                    .fill(Color.accentGreen.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "hand.wave.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.accentGreen)
            }

            // Title
            VStack(spacing: Spacing.sm) {
                Text("Bem-vindo ao \(featureName)!")
                    .font(.titleSmall)
                    .foregroundColor(.textPrimary)

                Text(description)
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Steps
            VStack(alignment: .leading, spacing: Spacing.md) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.accentPurple)
                                .frame(width: 24, height: 24)

                            Text("\(index + 1)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text(step)
                            .font(.bodySmall)
                            .foregroundColor(.textPrimary)

                        Spacer()
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.bgSecondary)
            .cornerRadius(CornerRadius.medium)

            PrimaryButton("Começar") {
                onGetStarted()
            }
        }
        .padding(Spacing.xl)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.xxl) {
            // Generic empty state
            EmptyStateView(
                icon: "tray",
                title: "Nada por aqui",
                message: "Parece que ainda não há nada para mostrar.",
                actionTitle: "Adicionar",
                action: { print("Action") }
            )

            Divider()

            // No missions
            NoMissionsEmptyState()

            Divider()

            // No squad
            NoSquadEmptyState(onJoinSquad: { print("Join") })

            Divider()

            // Compact
            CompactEmptyState(icon: "doc.text", message: "Nenhum histórico disponível")
                .padding(.horizontal)

            Divider()

            // Illustrated
            IllustratedEmptyState(
                illustration: "star.fill",
                illustrationColor: .accentOrange,
                title: "Conquistas",
                message: "Complete missões para desbloquear conquistas especiais.",
                actionTitle: "Ver Missões",
                action: { print("View") }
            )

            Divider()

            // First time
            FirstTimeEmptyState(
                featureName: "Ranking",
                description: "Compete com outros membros do seu squad!",
                steps: [
                    "Complete suas missões diárias",
                    "Ganhe XP a cada missão",
                    "Suba no ranking semanal"
                ],
                onGetStarted: { print("Start") }
            )
        }
    }
    .background(Color.bgPrimary)
}
