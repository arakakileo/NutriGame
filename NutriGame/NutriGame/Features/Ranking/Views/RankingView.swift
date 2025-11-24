//
//  RankingView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

struct RankingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = RankingViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.ranking.isEmpty {
                    LoadingView(message: "Carregando ranking...")
                } else if viewModel.ranking.isEmpty {
                    EmptyRankingView()
                } else {
                    RankingListView(
                        ranking: viewModel.ranking,
                        currentUserPosition: viewModel.currentUserPosition
                    )
                }
            }
            .navigationTitle("Ranking")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    WeekBadge()
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
        .onAppear {
            viewModel.setup(
                userId: authViewModel.currentUser?.id ?? "",
                squadCode: authViewModel.currentUser?.squadCode ?? ""
            )
        }
    }
}

// MARK: - Week Badge
struct WeekBadge: View {
    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: "calendar")
                .font(.caption)
            Text("Semana \(Date().weekNumber)")
                .font(.caption)
        }
        .foregroundColor(.textSecondary)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs)
        .background(Color.bgSecondary)
        .cornerRadius(CornerRadius.full)
    }
}

// MARK: - Ranking List View
struct RankingListView: View {
    let ranking: [RankedUser]
    let currentUserPosition: Int?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                // Current user position highlight
                if let position = currentUserPosition, position > 3 {
                    CurrentPositionCard(position: position)
                        .padding(.horizontal, Spacing.md)
                        .padding(.bottom, Spacing.sm)
                }

                // Top 3 podium
                if ranking.count >= 3 {
                    PodiumView(topThree: Array(ranking.prefix(3)))
                        .padding(.horizontal, Spacing.md)
                        .padding(.bottom, Spacing.md)
                }

                // Rest of ranking
                ForEach(ranking) { user in
                    RankingRowView(user: user)
                        .padding(.horizontal, Spacing.md)
                }
            }
            .padding(.vertical, Spacing.md)
        }
        .background(Color.bgPrimary)
    }
}

// MARK: - Podium View
struct PodiumView: View {
    let topThree: [RankedUser]

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.md) {
            // 2nd place
            if topThree.count > 1 {
                PodiumUser(user: topThree[1], height: 80)
            }

            // 1st place
            if !topThree.isEmpty {
                PodiumUser(user: topThree[0], height: 100)
            }

            // 3rd place
            if topThree.count > 2 {
                PodiumUser(user: topThree[2], height: 60)
            }
        }
    }
}

struct PodiumUser: View {
    let user: RankedUser
    let height: CGFloat

    var body: some View {
        VStack(spacing: Spacing.xs) {
            // Avatar
            AvatarView(
                name: user.name,
                imageUrl: user.avatarUrl,
                size: .medium
            )
            .overlay(
                PositionBadge(position: user.position)
                    .offset(x: 16, y: 16),
                alignment: .bottomTrailing
            )

            // Name
            Text(user.name.components(separatedBy: " ").first ?? "")
                .font(.caption)
                .foregroundColor(.textPrimary)
                .lineLimit(1)

            // XP
            Text("\(user.weeklyXP.formattedCompact) XP")
                .font(.caption)
                .foregroundColor(.textSecondary)

            // Podium base
            RoundedRectangle(cornerRadius: CornerRadius.small)
                .fill(podiumColor)
                .frame(height: height)
        }
        .frame(maxWidth: .infinity)
    }

    var podiumColor: Color {
        switch user.position {
        case 1: return Color(hex: "#FFD700") // Gold
        case 2: return Color(hex: "#C0C0C0") // Silver
        case 3: return Color(hex: "#CD7F32") // Bronze
        default: return Color.bgTertiary
        }
    }
}

// MARK: - Ranking Row View
struct RankingRowView: View {
    let user: RankedUser

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Position
            Text("\(user.position)")
                .font(.bodyLarge)
                .foregroundColor(.textSecondary)
                .frame(width: 30)

            // Avatar
            AvatarView(
                name: user.name,
                imageUrl: user.avatarUrl,
                size: .small
            )

            // Name and missions
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(user.name)
                    .font(.bodyMedium)
                    .foregroundColor(user.isCurrentUser ? .accentPurple : .textPrimary)

                TodayMissionsIndicator(missions: user.todayMissions)
            }

            Spacer()

            // XP
            Text("\(user.weeklyXP.formattedXP)")
                .font(.xpSmall)
                .foregroundColor(.accentGreen)
        }
        .padding(Spacing.md)
        .background(user.isCurrentUser ? Color.accentPurple.opacity(0.1) : Color.bgSecondary)
        .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - Today Missions Indicator
struct TodayMissionsIndicator: View {
    let missions: [MissionType]

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            ForEach(missions.sorted(by: { $0.order < $1.order }), id: \.self) { type in
                Image(systemName: type.icon)
                    .font(.system(size: 10))
                    .foregroundColor(Color.forMission(type))
            }

            if missions.isEmpty {
                Text("Nenhuma missão hoje")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
        }
    }
}

// MARK: - Position Badge
struct PositionBadge: View {
    let position: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 24, height: 24)

            if position <= 3 {
                Image(systemName: "crown.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.white)
            } else {
                Text("\(position)")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
        }
    }

    var backgroundColor: Color {
        switch position {
        case 1: return Color(hex: "#FFD700")
        case 2: return Color(hex: "#C0C0C0")
        case 3: return Color(hex: "#CD7F32")
        default: return Color.textTertiary
        }
    }
}

// MARK: - Current Position Card
struct CurrentPositionCard: View {
    let position: Int

    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .foregroundColor(.accentPurple)
            Text("Você está em")
                .foregroundColor(.textSecondary)
            Text("\(position)º lugar")
                .font(.xpSmall)
                .foregroundColor(.accentPurple)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity)
        .background(Color.accentPurple.opacity(0.1))
        .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - Empty Ranking View
struct EmptyRankingView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)

            Text("Nenhum participante ainda")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)

            Text("Complete missões para aparecer no ranking!")
                .font(.bodyMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.xl)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
            Text(message)
                .font(.bodyMedium)
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - Avatar View
struct AvatarView: View {
    let name: String
    let imageUrl: String?
    let size: AvatarSize

    var body: some View {
        if let urlString = imageUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                InitialsAvatar(name: name, size: size)
            }
            .frame(width: size.dimension, height: size.dimension)
            .clipShape(Circle())
        } else {
            InitialsAvatar(name: name, size: size)
        }
    }
}

struct InitialsAvatar: View {
    let name: String
    let size: AvatarSize

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.accentPurple.opacity(0.2))

            Text(name.initials)
                .font(.system(size: size.dimension * 0.4, weight: .semibold))
                .foregroundColor(.accentPurple)
        }
        .frame(width: size.dimension, height: size.dimension)
    }
}

#Preview {
    RankingView()
        .environmentObject(AuthViewModel())
}
