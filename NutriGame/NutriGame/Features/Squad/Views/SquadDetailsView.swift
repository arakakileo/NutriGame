//
//  SquadDetailsView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

struct SquadDetailsView: View {
    let squadCode: String

    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = SquadDetailsViewModel()
    @State private var showingLeaveConfirmation = false
    @State private var showingDeleteConfirmation = false
    @State private var showingShareSheet = false

    var isOwner: Bool {
        viewModel.squad?.ownerUserId == authViewModel.currentUser?.id
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Squad Header
                SquadHeaderCard(
                    squad: viewModel.squad,
                    isOwner: isOwner,
                    onShare: { showingShareSheet = true }
                )

                // Members Section
                MembersSection(
                    members: viewModel.members,
                    isLoading: viewModel.isLoading,
                    currentUserId: authViewModel.currentUser?.id ?? ""
                )

                // Actions
                VStack(spacing: Spacing.md) {
                    if isOwner {
                        // Owner actions
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Excluir Squad")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.md)
                            .background(Color.error.opacity(0.1))
                            .foregroundColor(.error)
                            .cornerRadius(CornerRadius.medium)
                        }
                    } else {
                        // Member actions
                        Button(role: .destructive) {
                            showingLeaveConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sair do Squad")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.md)
                            .background(Color.warning.opacity(0.1))
                            .foregroundColor(.warning)
                            .cornerRadius(CornerRadius.medium)
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.lg)
            }
            .padding(.vertical, Spacing.md)
        }
        .background(Color.bgPrimary)
        .navigationTitle("Squad")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadSquad(code: squadCode)
        }
        .alert("Sair do Squad", isPresented: $showingLeaveConfirmation) {
            Button("Cancelar", role: .cancel) {}
            Button("Sair", role: .destructive) {
                leaveSquad()
            }
        } message: {
            Text("Você sairá do ranking e perderá sua posição. Seu XP total será mantido.")
        }
        .alert("Excluir Squad", isPresented: $showingDeleteConfirmation) {
            Button("Cancelar", role: .cancel) {}
            Button("Excluir", role: .destructive) {
                deleteSquad()
            }
        } message: {
            Text("Esta ação é irreversível. Todos os membros serão removidos do squad.")
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSquadSheet(squadCode: squadCode, squadName: viewModel.squad?.name ?? "Squad")
        }
    }

    private func leaveSquad() {
        guard let userId = authViewModel.currentUser?.id else { return }
        Task {
            await viewModel.leaveSquad(userId: userId)
        }
    }

    private func deleteSquad() {
        guard let userId = authViewModel.currentUser?.id else { return }
        Task {
            await viewModel.deleteSquad(code: squadCode, ownerId: userId)
        }
    }
}

// MARK: - Squad Header Card
struct SquadHeaderCard: View {
    let squad: Squad?
    let isOwner: Bool
    let onShare: () -> Void

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.accentPurple.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: "person.3.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.accentPurple)
            }

            // Name
            Text(squad?.name ?? "Carregando...")
                .font(.titleMedium)
                .foregroundColor(.textPrimary)

            // Owner badge
            if isOwner {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.accentOrange)
                    Text("Você é o criador")
                        .foregroundColor(.accentOrange)
                }
                .font(.caption)
            }

            // Stats
            HStack(spacing: Spacing.xl) {
                VStack {
                    Text("\(squad?.memberCount ?? 0)")
                        .font(.xpMedium)
                        .foregroundColor(.textPrimary)
                    Text("Membros")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Divider()
                    .frame(height: 40)

                VStack {
                    Text("\(squad?.maxMembers ?? 100)")
                        .font(.xpMedium)
                        .foregroundColor(.textPrimary)
                    Text("Máximo")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }

            // Code
            HStack {
                VStack(alignment: .leading) {
                    Text("Código do Squad")
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    Text(squad?.code ?? "------")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.textPrimary)
                }

                Spacer()

                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                        .foregroundColor(.accentPurple)
                        .padding(Spacing.sm)
                        .background(Color.accentPurple.opacity(0.1))
                        .cornerRadius(CornerRadius.medium)
                }
            }
            .padding(Spacing.md)
            .background(Color.bgTertiary)
            .cornerRadius(CornerRadius.medium)
        }
        .padding(Spacing.lg)
        .background(Color.bgSecondary)
        .cornerRadius(CornerRadius.large)
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - Members Section
struct MembersSection: View {
    let members: [User]
    let isLoading: Bool
    let currentUserId: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Membros")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.md)

            if isLoading && members.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.xl)
            } else {
                LazyVStack(spacing: Spacing.sm) {
                    ForEach(members) { member in
                        MemberRow(
                            member: member,
                            isCurrentUser: member.id == currentUserId
                        )
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }
}

struct MemberRow: View {
    let member: User
    let isCurrentUser: Bool

    var body: some View {
        HStack(spacing: Spacing.md) {
            AvatarView(
                name: member.name,
                imageUrl: member.avatarUrl,
                size: .small
            )

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(member.name)
                        .font(.bodyMedium)
                        .foregroundColor(isCurrentUser ? .accentPurple : .textPrimary)

                    if isCurrentUser {
                        Text("(você)")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }

                    if member.isNutritionist {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.accentOrange)
                    }
                }

                Text("Nível \(member.level) • \(member.totalXP.formattedCompact) XP")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            // Streak
            if member.currentStreak > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.accentOrange)
                    Text("\(member.currentStreak)")
                        .foregroundColor(.textSecondary)
                }
                .font(.caption)
            }
        }
        .padding(Spacing.md)
        .background(isCurrentUser ? Color.accentPurple.opacity(0.1) : Color.bgSecondary)
        .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - Share Squad Sheet
struct ShareSquadSheet: View {
    let squadCode: String
    let squadName: String
    @Environment(\.dismiss) private var dismiss

    var shareText: String {
        "Entre no meu squad no NutriGame! Use o código: \(squadCode)"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                // Code display
                VStack(spacing: Spacing.md) {
                    Text("Compartilhe o código")
                        .font(.titleSmall)
                        .foregroundColor(.textPrimary)

                    Text(squadCode)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.accentPurple)
                        .padding(Spacing.lg)
                        .background(Color.bgSecondary)
                        .cornerRadius(CornerRadius.large)
                }

                // Actions
                VStack(spacing: Spacing.md) {
                    Button {
                        UIPasteboard.general.string = squadCode
                        HapticManager.shared.success()
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copiar Código")
                        }
                        .primaryButtonStyle()
                    }

                    ShareLink(item: shareText) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Compartilhar")
                        }
                        .secondaryButtonStyle()
                    }
                }
                .padding(.horizontal, Spacing.lg)

                Spacer()
            }
            .padding(.top, Spacing.xl)
            .background(Color.bgPrimary)
            .navigationTitle(squadName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - View Model
@MainActor
final class SquadDetailsViewModel: ObservableObject {
    @Published var squad: Squad?
    @Published var members: [User] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let squadService = SquadService.shared
    private let userService = UserService.shared

    func loadSquad(code: String) {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                squad = try await squadService.getSquad(code: code)
                members = try await userService.getUsersInSquad(squadCode: code)
                    .sorted { $0.totalXP > $1.totalXP }
            } catch {
                self.error = error
            }
        }
    }

    func leaveSquad(userId: String) async {
        do {
            try await squadService.leaveSquad(userId: userId)
            HapticManager.shared.success()
        } catch {
            self.error = error
            HapticManager.shared.errorOccurred()
        }
    }

    func deleteSquad(code: String, ownerId: String) async {
        do {
            try await squadService.deleteSquad(code: code, ownerUserId: ownerId)
            HapticManager.shared.success()
        } catch {
            self.error = error
            HapticManager.shared.errorOccurred()
        }
    }
}

#Preview {
    NavigationStack {
        SquadDetailsView(squadCode: "NUTRI1")
            .environmentObject(AuthViewModel())
    }
}
