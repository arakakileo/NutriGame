//
//  OnboardingView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage(Constants.UserDefaultsKey.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "checkmark.circle.fill",
            iconColor: .accentGreen,
            title: "Complete Missões",
            description: "Registre suas refeições e treinos diariamente para ganhar XP e subir de nível."
        ),
        OnboardingPage(
            icon: "trophy.fill",
            iconColor: .accentPurple,
            title: "Suba no Ranking",
            description: "Compete com outros membros do seu squad no ranking semanal."
        ),
        OnboardingPage(
            icon: "flame.fill",
            iconColor: .accentOrange,
            title: "Mantenha seu Streak",
            description: "Complete pelo menos uma missão por dia para manter seu streak e ganhar bônus."
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Bottom section
            VStack(spacing: Spacing.lg) {
                // Page indicator
                HStack(spacing: Spacing.xs) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.accentPurple : Color.textTertiary)
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }

                // Button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        hasCompletedOnboarding = true
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Próximo" : "Começar")
                        .primaryButtonStyle()
                }

                // Skip button
                if currentPage < pages.count - 1 {
                    Button("Pular") {
                        hasCompletedOnboarding = true
                    }
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xxl)
        }
        .background(Color.bgPrimary)
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.iconColor.opacity(0.2))
                    .frame(width: 150, height: 150)

                Image(systemName: page.icon)
                    .font(.system(size: 70))
                    .foregroundColor(page.iconColor)
            }

            // Text
            VStack(spacing: Spacing.md) {
                Text(page.title)
                    .font(.titleLarge)
                    .foregroundColor(.textPrimary)

                Text(page.description)
                    .font(.bodyLarge)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
