//
//  LoginView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingEmailLogin = false

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xl) {
                Spacer()

                // Logo
                VStack(spacing: Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.accentGreen.opacity(0.2))
                            .frame(width: 120, height: 120)

                        Image(systemName: "leaf.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.accentGreen)
                    }

                    Text("NutriGame")
                        .font(.titleLarge)
                        .foregroundColor(.textPrimary)

                    Text("Gamifique sua dieta")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                // Login Buttons
                VStack(spacing: Spacing.md) {
                    // Sign in with Apple
                    SignInWithAppleButton { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleAppleSignIn(result)
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: AppTheme.buttonHeightLarge)
                    .cornerRadius(CornerRadius.medium)

                    // Sign in with Google
                    Button {
                        signInWithGoogle()
                    } label: {
                        HStack {
                            Image(systemName: "g.circle.fill")
                            Text("Continuar com Google")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.buttonHeightLarge)
                        .background(Color.bgSecondary)
                        .foregroundColor(.textPrimary)
                        .cornerRadius(CornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .stroke(Color.textTertiary.opacity(0.3), lineWidth: 1)
                        )
                    }

                    // Email login
                    Button {
                        showingEmailLogin = true
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Continuar com E-mail")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.buttonHeightLarge)
                        .background(Color.bgSecondary)
                        .foregroundColor(.textPrimary)
                        .cornerRadius(CornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .stroke(Color.textTertiary.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, Spacing.lg)

                // Terms
                Text("Ao continuar, você concorda com nossos Termos de Uso e Política de Privacidade")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xxl)
            }
            .background(Color.bgPrimary)
            .loadingOverlay(authViewModel.isLoading)
            .errorAlert(error: Binding(
                get: { authViewModel.error },
                set: { authViewModel.error = $0 }
            ))
            .sheet(isPresented: $showingEmailLogin) {
                EmailLoginView()
            }
        }
    }

    // MARK: - Apple Sign In
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let idTokenData = appleIDCredential.identityToken,
                      let idToken = String(data: idTokenData, encoding: .utf8) else {
                    return
                }

                let nonce = AuthService.randomNonceString()

                Task {
                    await authViewModel.signInWithApple(
                        idToken: idToken,
                        nonce: nonce,
                        fullName: appleIDCredential.fullName
                    )
                }
            }
        case .failure(let error):
            print("Apple Sign In error: \(error)")
        }
    }

    // MARK: - Google Sign In
    private func signInWithGoogle() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        Task {
            await authViewModel.signInWithGoogle(presenting: rootViewController)
        }
    }
}

// MARK: - Email Login View
struct EmailLoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var showingForgotPassword = false

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                // Toggle
                Picker("", selection: $isSignUp) {
                    Text("Entrar").tag(false)
                    Text("Criar Conta").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)

                // Form
                VStack(spacing: Spacing.md) {
                    if isSignUp {
                        TextField("Nome", text: $name)
                            .textContentType(.name)
                            .textInputAutocapitalization(.words)
                            .padding(Spacing.md)
                            .background(Color.bgSecondary)
                            .cornerRadius(CornerRadius.medium)
                    }

                    TextField("E-mail", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding(Spacing.md)
                        .background(Color.bgSecondary)
                        .cornerRadius(CornerRadius.medium)

                    SecureField("Senha", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password)
                        .padding(Spacing.md)
                        .background(Color.bgSecondary)
                        .cornerRadius(CornerRadius.medium)
                }
                .padding(.horizontal, Spacing.lg)

                // Forgot password
                if !isSignUp {
                    Button("Esqueci minha senha") {
                        showingForgotPassword = true
                    }
                    .font(.caption)
                    .foregroundColor(.accentPurple)
                }

                Spacer()

                // Submit button
                Button {
                    Task {
                        if isSignUp {
                            await authViewModel.signUp(name: name, email: email, password: password)
                        } else {
                            await authViewModel.signIn(email: email, password: password)
                        }
                        if authViewModel.isAuthenticated {
                            dismiss()
                        }
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isSignUp ? "Criar Conta" : "Entrar")
                    }
                }
                .primaryButtonStyle()
                .disabled(!isFormValid || authViewModel.isLoading)
                .opacity(isFormValid ? 1 : 0.6)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xxl)
            }
            .background(Color.bgPrimary)
            .navigationTitle(isSignUp ? "Criar Conta" : "Entrar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .errorAlert(error: Binding(
                get: { authViewModel.error },
                set: { authViewModel.error = $0 }
            ))
            .alert("Recuperar Senha", isPresented: $showingForgotPassword) {
                TextField("E-mail", text: $email)
                    .textContentType(.emailAddress)
                Button("Enviar") {
                    Task {
                        _ = await authViewModel.resetPassword(email: email)
                    }
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Digite seu e-mail para receber um link de recuperação")
            }
            .dismissKeyboardOnTap()
        }
    }

    var isFormValid: Bool {
        let emailValid = Validators.isValidEmail(email)
        let passwordValid = Validators.isValidPassword(password)

        if isSignUp {
            return emailValid && passwordValid && Validators.isValidName(name)
        }
        return emailValid && passwordValid
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
