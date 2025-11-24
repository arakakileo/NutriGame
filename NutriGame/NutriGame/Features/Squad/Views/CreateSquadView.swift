//
//  CreateSquadView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

struct CreateSquadView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateSquadViewModel()
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Header
            VStack(spacing: Spacing.md) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentPurple)

                Text("Criar meu Squad")
                    .font(.titleLarge)
                    .foregroundColor(.textPrimary)

                Text("Crie um grupo para seus pacientes acompanharem o progresso")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Spacing.xl)

            // Name Input
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Nome do Squad")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                TextField("Ex: Pacientes da Dra. Maria", text: $viewModel.squadName)
                    .textInputAutocapitalization(.words)
                    .padding(Spacing.md)
                    .background(Color.bgSecondary)
                    .cornerRadius(CornerRadius.medium)
                    .focused($isNameFieldFocused)

                if let error = viewModel.error {
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.error)
                }
            }
            .padding(.horizontal, Spacing.lg)

            // Info box
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.accentPurple)
                    Text("Informações")
                        .font(.caption)
                        .foregroundColor(.textPrimary)
                }

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    InfoRow(icon: "person.3", text: "Até 100 membros por squad")
                    InfoRow(icon: "key.fill", text: "Código único será gerado automaticamente")
                    InfoRow(icon: "chart.bar.fill", text: "Você poderá ver o ranking dos seus pacientes")
                }
            }
            .padding(Spacing.md)
            .background(Color.accentPurple.opacity(0.1))
            .cornerRadius(CornerRadius.medium)
            .padding(.horizontal, Spacing.lg)

            Spacer()

            // Create Button
            Button {
                Task {
                    let success = await viewModel.createSquad(userId: authViewModel.currentUser?.id ?? "")
                    if success {
                        dismiss()
                    }
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Criar Squad")
                }
            }
            .primaryButtonStyle()
            .disabled(!viewModel.isValidName || viewModel.isLoading)
            .opacity(viewModel.isValidName ? 1 : 0.6)
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xxl)
        }
        .background(Color.bgPrimary)
        .navigationTitle("Novo Squad")
        .navigationBarTitleDisplayMode(.inline)
        .dismissKeyboardOnTap()
        .onAppear {
            isNameFieldFocused = true
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .frame(width: 20)
            Text(text)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - View Model
@MainActor
final class CreateSquadViewModel: ObservableObject {
    @Published var squadName = ""
    @Published var isLoading = false
    @Published var error: Error?

    private let squadService = SquadService.shared

    var isValidName: Bool {
        squadName.trimmed.count >= 3
    }

    func createSquad(userId: String) async -> Bool {
        guard isValidName, !userId.isEmpty else { return false }

        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            _ = try await squadService.createSquad(name: squadName.trimmed, ownerUserId: userId)
            HapticManager.shared.success()
            return true
        } catch {
            self.error = error
            HapticManager.shared.errorOccurred()
            return false
        }
    }
}

#Preview {
    NavigationStack {
        CreateSquadView()
            .environmentObject(AuthViewModel())
    }
}
