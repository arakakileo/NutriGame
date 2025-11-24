//
//  SettingsView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAlert = false
    @State private var notificationsEnabled = true

    var body: some View {
        NavigationStack {
            List {
                // Account Section
                Section("Conta") {
                    if let user = authViewModel.currentUser {
                        HStack {
                            Text("E-mail")
                            Spacer()
                            Text(user.email)
                                .foregroundColor(.textSecondary)
                        }

                        HStack {
                            Text("Membro desde")
                            Spacer()
                            Text(user.createdAt.fullDate)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }

                // Notifications Section
                Section("Notificações") {
                    Toggle("Lembretes de refeições", isOn: $notificationsEnabled)
                        .tint(.accentPurple)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            updateNotificationSettings(enabled: newValue)
                        }
                }

                // Squad Section
                Section("Squad") {
                    if let user = authViewModel.currentUser, let squadCode = user.squadCode {
                        HStack {
                            Text("Código")
                            Spacer()
                            Text(squadCode)
                                .foregroundColor(.textSecondary)
                            Button {
                                UIPasteboard.general.string = squadCode
                                HapticManager.shared.success()
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.accentPurple)
                            }
                        }

                        Button("Sair do Squad") {
                            // Implement leave squad
                        }
                        .foregroundColor(.warning)
                    }
                }

                // App Info Section
                Section("Sobre") {
                    HStack {
                        Text("Versão")
                        Spacer()
                        Text("\(Constants.App.version) (\(Constants.App.build))")
                            .foregroundColor(.textSecondary)
                    }

                    Link(destination: URL(string: "https://nutrigame.app/terms")!) {
                        HStack {
                            Text("Termos de Uso")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.textTertiary)
                        }
                    }
                    .foregroundColor(.textPrimary)

                    Link(destination: URL(string: "https://nutrigame.app/privacy")!) {
                        HStack {
                            Text("Política de Privacidade")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.textTertiary)
                        }
                    }
                    .foregroundColor(.textPrimary)
                }

                // Danger Zone
                Section {
                    Button("Sair da Conta") {
                        showingLogoutAlert = true
                    }
                    .foregroundColor(.warning)

                    Button("Excluir Conta") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.error)
                }
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
            .alert("Sair da Conta", isPresented: $showingLogoutAlert) {
                Button("Cancelar", role: .cancel) {}
                Button("Sair", role: .destructive) {
                    authViewModel.signOut()
                    dismiss()
                }
            } message: {
                Text("Tem certeza que deseja sair?")
            }
            .alert("Excluir Conta", isPresented: $showingDeleteAlert) {
                Button("Cancelar", role: .cancel) {}
                Button("Excluir", role: .destructive) {
                    Task {
                        let success = await authViewModel.deleteAccount()
                        if success {
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("Esta ação é irreversível. Todos os seus dados serão perdidos permanentemente.")
            }
            .onAppear {
                notificationsEnabled = authViewModel.currentUser?.notificationsEnabled ?? true
            }
        }
    }

    private func updateNotificationSettings(enabled: Bool) {
        guard let userId = authViewModel.currentUser?.id else { return }
        Task {
            do {
                try await UserService.shared.updateNotificationSettings(userId: userId, enabled: enabled)
            } catch {
                print("Erro ao atualizar configurações: \(error)")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
