//
//  NutriGameApp.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI
import FirebaseCore

@main
struct NutriGameApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var navigationState = NavigationState()

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(authViewModel)
                .environmentObject(navigationState)
                .preferredColorScheme(nil) // Suporta Light e Dark mode
        }
    }
}
