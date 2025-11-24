//
//  AppRouter.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

struct AppRouter: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var navigationState: NavigationState
    @AppStorage(Constants.UserDefaultsKey.hasCompletedOnboarding) private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if authViewModel.isLoading {
                SplashView()
            } else if !authViewModel.isAuthenticated {
                LoginView()
            } else if !hasCompletedOnboarding {
                OnboardingView()
            } else if authViewModel.currentUser?.squadCode == nil {
                SquadCodeInputView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: hasCompletedOnboarding)
    }
}

// MARK: - Splash View
struct SplashView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color.bgPrimary
                .ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                // Logo placeholder
                ZStack {
                    Circle()
                        .fill(Color.accentGreen.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.accentGreen)
                }

                Text("NutriGame")
                    .font(.titleLarge)
                    .foregroundColor(.textPrimary)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    AppRouter()
        .environmentObject(AuthViewModel())
        .environmentObject(NavigationState())
}
