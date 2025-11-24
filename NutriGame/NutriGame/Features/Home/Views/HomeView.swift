//
//  HomeView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Header com XP, Level e Streak
                    XPHeaderView(user: authViewModel.currentUser ?? .mock)

                    // Missões do dia
                    MissionsListView(viewModel: viewModel)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.xxl)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Olá, \(authViewModel.currentUser?.name.components(separatedBy: " ").first ?? "")!")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
        }
        .onAppear {
            viewModel.setup(userId: authViewModel.currentUser?.id ?? "",
                          squadCode: authViewModel.currentUser?.squadCode ?? "")
        }
    }
}

// MARK: - XP Header View
struct XPHeaderView: View {
    let user: User
    @State private var animateProgress = false

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Stats Row
            HStack(spacing: Spacing.md) {
                // Level
                StatCard(
                    icon: "star.fill",
                    iconColor: .accentPurple,
                    title: "Nível",
                    value: "\(user.level)"
                )

                // XP
                StatCard(
                    icon: "bolt.fill",
                    iconColor: .accentGreen,
                    title: "XP Total",
                    value: user.totalXP.formattedXP
                )

                // Streak
                StatCard(
                    icon: "flame.fill",
                    iconColor: .accentOrange,
                    title: "Streak",
                    value: "\(user.currentStreak)",
                    subtitle: user.currentStreak == 1 ? "dia" : "dias"
                )
            }

            // XP Progress Bar
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text("Progresso do nível")
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    Spacer()

                    Text("\(user.xpProgressInCurrentLevel)/\(user.xpForCurrentLevel) XP")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: CornerRadius.small)
                            .fill(Color.bgTertiary)

                        // Progress
                        RoundedRectangle(cornerRadius: CornerRadius.small)
                            .fill(Color.xpGradient)
                            .frame(width: animateProgress ?
                                   geometry.size.width * user.xpProgressPercentage : 0)
                    }
                }
                .frame(height: 8)
            }
            .padding(.top, Spacing.xs)
        }
        .padding(Spacing.md)
        .background(Color.bgSecondary)
        .cornerRadius(CornerRadius.large)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateProgress = true
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    var subtitle: String? = nil

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)

            Text(value)
                .font(.xpMedium)
                .foregroundColor(.textPrimary)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            } else {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
        .background(Color.bgTertiary.opacity(0.5))
        .cornerRadius(CornerRadius.medium)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(NavigationState())
}
