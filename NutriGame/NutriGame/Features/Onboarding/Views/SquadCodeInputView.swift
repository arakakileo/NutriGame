//
//  SquadCodeInputView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

struct SquadCodeInputView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = SquadCodeViewModel()
    @FocusState private var isCodeFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                Spacer()

                // Header
                VStack(spacing: Spacing.md) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentPurple)

                    Text("Entre no seu Squad")
                        .font(.titleLarge)
                        .foregroundColor(.textPrimary)

                    Text("Digite o código fornecido pelo seu nutricionista")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // Code Input
                VStack(spacing: Spacing.sm) {
                    TextField("CÓDIGO", text: $viewModel.squadCode)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .padding(Spacing.md)
                        .background(Color.bgSecondary)
                        .cornerRadius(CornerRadius.medium)
                        .focused($isCodeFieldFocused)
                        .onChange(of: viewModel.squadCode) { _, newValue in
                            viewModel.squadCode = String(newValue.uppercased().prefix(6))
                        }

                    if let error = viewModel.error {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.error)
                    }
                }
                .padding(.horizontal, Spacing.xl)

                Spacer()

                // Buttons
                VStack(spacing: Spacing.md) {
                    Button {
                        Task {
                            await viewModel.joinSquad(userId: authViewModel.currentUser?.id ?? "")
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Entrar no Squad")
                        }
                    }
                    .primaryButtonStyle()
                    .disabled(!viewModel.isValidCode || viewModel.isLoading)
                    .opacity(viewModel.isValidCode ? 1 : 0.6)

                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.textTertiary.opacity(0.3))
                            .frame(height: 1)
                        Text("ou")
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                        Rectangle()
                            .fill(Color.textTertiary.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.vertical, Spacing.sm)

                    // Create Squad button
                    NavigationLink {
                        CreateSquadView()
                    } label: {
                        Text("Sou Nutricionista")
                            .secondaryButtonStyle()
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xxl)
            }
            .background(Color.bgPrimary)
            .dismissKeyboardOnTap()
            .onAppear {
                isCodeFieldFocused = true
            }
        }
    }
}

// MARK: - View Model
@MainActor
final class SquadCodeViewModel: ObservableObject {
    @Published var squadCode = ""
    @Published var isLoading = false
    @Published var error: Error?

    private let squadService = SquadService.shared

    var isValidCode: Bool {
        Squad.isValidCodeFormat(squadCode)
    }

    func joinSquad(userId: String) async {
        guard isValidCode, !userId.isEmpty else { return }

        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            _ = try await squadService.joinSquad(userId: userId, code: squadCode)
            HapticManager.shared.success()
        } catch {
            self.error = error
            HapticManager.shared.errorOccurred()
        }
    }
}

#Preview {
    SquadCodeInputView()
        .environmentObject(AuthViewModel())
}
