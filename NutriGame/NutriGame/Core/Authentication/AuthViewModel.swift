//
//  AuthViewModel.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var currentUser: User?
    @Published var error: Error?

    private let authService = AuthService.shared
    private let userService = UserService.shared
    private var cancellables = Set<AnyCancellable>()
    private var userListener: ListenerRegistration?

    init() {
        setupBindings()
    }

    deinit {
        userListener?.remove()
    }

    // MARK: - Setup

    private func setupBindings() {
        authService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                self?.isAuthenticated = isAuthenticated
                if isAuthenticated {
                    self?.loadCurrentUser()
                } else {
                    self?.currentUser = nil
                    self?.isLoading = false
                }
            }
            .store(in: &cancellables)

        // FCM Token
        NotificationCenter.default.publisher(for: .fcmTokenReceived)
            .compactMap { $0.userInfo?["token"] as? String }
            .sink { [weak self] token in
                Task {
                    await self?.updateFCMToken(token)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Load User

    private func loadCurrentUser() {
        guard let firebaseUser = authService.currentUser else {
            isLoading = false
            return
        }

        // Remove listener anterior
        userListener?.remove()

        // Configura listener para mudanças no usuário
        userListener = userService.observeUser(id: firebaseUser.uid) { [weak self] user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isLoading = false
            }
        }
    }

    // MARK: - Sign Up

    func signUp(name: String, email: String, password: String) async {
        isLoading = true
        error = nil

        do {
            let firebaseUser = try await authService.signUp(email: email, password: password)

            // Atualiza display name
            try await authService.updateDisplayName(name)

            // Cria usuário no Firestore
            let user = User(
                id: firebaseUser.uid,
                name: name,
                email: email
            )
            try await userService.createUser(user)

            currentUser = user
        } catch {
            self.error = AuthError.from(error)
        }

        isLoading = false
    }

    // MARK: - Sign In

    func signIn(email: String, password: String) async {
        isLoading = true
        error = nil

        do {
            _ = try await authService.signIn(email: email, password: password)
            // User será carregado pelo listener
        } catch {
            self.error = AuthError.from(error)
            isLoading = false
        }
    }

    // MARK: - Social Sign In

    func signInWithApple(idToken: String, nonce: String, fullName: PersonNameComponents?) async {
        isLoading = true
        error = nil

        do {
            let firebaseUser = try await authService.signInWithApple(
                idToken: idToken,
                nonce: nonce,
                fullName: fullName
            )

            // Verifica se usuário já existe no Firestore
            let userExists = await userService.userExists(id: firebaseUser.uid)

            if !userExists {
                // Cria novo usuário
                var name = "Usuário"
                if let givenName = fullName?.givenName {
                    name = givenName
                    if let familyName = fullName?.familyName {
                        name += " \(familyName)"
                    }
                }

                let user = User(
                    id: firebaseUser.uid,
                    name: name,
                    email: firebaseUser.email ?? ""
                )
                try await userService.createUser(user)
            }
        } catch {
            self.error = AuthError.from(error)
            isLoading = false
        }
    }

    func signInWithGoogle(presenting: UIViewController) async {
        isLoading = true
        error = nil

        do {
            let firebaseUser = try await authService.signInWithGoogle(presenting: presenting)

            // Verifica se usuário já existe no Firestore
            let userExists = await userService.userExists(id: firebaseUser.uid)

            if !userExists {
                let user = User(
                    id: firebaseUser.uid,
                    name: firebaseUser.displayName ?? "Usuário",
                    email: firebaseUser.email ?? "",
                    avatarUrl: firebaseUser.photoURL?.absoluteString
                )
                try await userService.createUser(user)
            }
        } catch {
            self.error = AuthError.from(error)
            isLoading = false
        }
    }

    // MARK: - Sign Out

    func signOut() {
        do {
            try authService.signOut()
            userListener?.remove()
            currentUser = nil
        } catch {
            self.error = error
        }
    }

    // MARK: - Password Reset

    func resetPassword(email: String) async -> Bool {
        error = nil

        do {
            try await authService.resetPassword(email: email)
            return true
        } catch {
            self.error = AuthError.from(error)
            return false
        }
    }

    // MARK: - Delete Account

    func deleteAccount() async -> Bool {
        guard let userId = currentUser?.id else { return false }

        do {
            // Deleta dados do Firestore primeiro
            try await userService.deleteUser(id: userId)

            // Deleta conta do Firebase Auth
            try await authService.deleteAccount()

            return true
        } catch {
            self.error = error
            return false
        }
    }

    // MARK: - Update FCM Token

    private func updateFCMToken(_ token: String) async {
        guard let userId = currentUser?.id else { return }

        do {
            try await userService.updateFCMToken(userId: userId, token: token)
        } catch {
            print("Erro ao atualizar FCM token: \(error)")
        }
    }

    // MARK: - Clear Error

    func clearError() {
        error = nil
    }
}
