//
//  ProfileView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingSettings = false
    @State private var showingEditProfile = false

    var user: User {
        authViewModel.currentUser ?? .mock
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Profile Header
                    ProfileHeaderView(
                        user: user,
                        onEditTap: { showingEditProfile = true }
                    )

                    // Stats Grid
                    StatsGridView(user: user)

                    // Photo Gallery
                    PhotoGalleryPreview(
                        photos: viewModel.recentPhotos,
                        onViewAll: {
                            // Navigate to full gallery
                        }
                    )

                    // Squad Info
                    if let squadCode = user.squadCode {
                        SquadInfoCard(squadCode: squadCode)
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.xxl)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
        }
        .onAppear {
            viewModel.loadRecentPhotos(userId: user.id ?? "")
        }
    }
}

// MARK: - Profile Header View
struct ProfileHeaderView: View {
    let user: User
    let onEditTap: () -> Void

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                AvatarView(
                    name: user.name,
                    imageUrl: user.avatarUrl,
                    size: .extraLarge
                )

                Button(action: onEditTap) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.accentPurple)
                        .background(Circle().fill(Color.bgPrimary))
                }
            }

            // Name and info
            VStack(spacing: Spacing.xs) {
                Text(user.name)
                    .font(.titleMedium)
                    .foregroundColor(.textPrimary)

                HStack(spacing: Spacing.sm) {
                    // Level badge
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.accentPurple)
                        Text("Nível \(user.level)")
                    }
                    .font(.caption)
                    .foregroundColor(.accentPurple)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xxs)
                    .background(Color.accentPurple.opacity(0.1))
                    .cornerRadius(CornerRadius.full)

                    // Member since
                    Text("Desde \(user.createdAt.month) \(user.createdAt.day)")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(Spacing.lg)
    }
}

// MARK: - Stats Grid View
struct StatsGridView: View {
    let user: User

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: Spacing.md) {
            StatGridItem(
                value: user.totalXP.formattedCompact,
                label: "XP Total",
                icon: "bolt.fill",
                color: .accentGreen
            )

            StatGridItem(
                value: "\(user.currentStreak)",
                label: "Streak Atual",
                icon: "flame.fill",
                color: .accentOrange
            )

            StatGridItem(
                value: "\(user.longestStreak)",
                label: "Maior Streak",
                icon: "trophy.fill",
                color: .accentPurple
            )
        }
    }
}

struct StatGridItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.xpMedium)
                .foregroundColor(.textPrimary)

            Text(label)
                .font(.caption)
                .foregroundColor(.textTertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(Color.bgSecondary)
        .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - Photo Gallery Preview
struct PhotoGalleryPreview: View {
    let photos: [Mission]
    let onViewAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Diário Visual")
                    .font(.titleSmall)
                    .foregroundColor(.textPrimary)

                Spacer()

                Button("Ver Todos", action: onViewAll)
                    .font(.caption)
                    .foregroundColor(.accentPurple)
            }

            if photos.isEmpty {
                EmptyGalleryView()
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: Spacing.xs) {
                    ForEach(photos.prefix(6)) { mission in
                        PhotoGridItem(photoUrl: mission.photoUrl)
                    }
                }
            }
        }
    }
}

struct PhotoGridItem: View {
    let photoUrl: String?

    var body: some View {
        if let urlString = photoUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(Color.bgTertiary)
                    .overlay(ProgressView())
            }
            .frame(height: 100)
            .clipped()
            .cornerRadius(CornerRadius.small)
        }
    }
}

struct EmptyGalleryView: View {
    var body: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 40))
                .foregroundColor(.textTertiary)

            Text("Nenhuma foto ainda")
                .font(.bodyMedium)
                .foregroundColor(.textSecondary)

            Text("Complete missões para ver suas fotos aqui")
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
        .background(Color.bgSecondary)
        .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - Squad Info Card
struct SquadInfoCard: View {
    let squadCode: String
    @State private var squad: Squad?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Meu Squad")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)

            HStack(spacing: Spacing.md) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.accentPurple)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(squad?.name ?? "Carregando...")
                        .font(.bodyLarge)
                        .foregroundColor(.textPrimary)

                    HStack {
                        Text("Código: \(squadCode)")
                            .font(.caption)
                            .foregroundColor(.textSecondary)

                        if let squad = squad {
                            Text("• \(squad.memberCount) membros")
                                .font(.caption)
                                .foregroundColor(.textTertiary)
                        }
                    }
                }

                Spacer()

                Button {
                    UIPasteboard.general.string = squadCode
                    HapticManager.shared.success()
                } label: {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(Spacing.md)
            .background(Color.bgSecondary)
            .cornerRadius(CornerRadius.medium)
        }
        .task {
            do {
                squad = try await SquadService.shared.getSquad(code: squadCode)
            } catch {
                print("Erro ao carregar squad: \(error)")
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
