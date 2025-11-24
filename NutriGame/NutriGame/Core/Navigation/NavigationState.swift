//
//  NavigationState.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import SwiftUI

@MainActor
final class NavigationState: ObservableObject {
    @Published var selectedTab: Tab = .home
    @Published var showingOnboarding = false
    @Published var showingSquadInput = false
    @Published var path = NavigationPath()

    enum Tab: Int, CaseIterable {
        case home = 0
        case ranking = 1
        case profile = 2

        var title: String {
            switch self {
            case .home: return "Início"
            case .ranking: return "Ranking"
            case .profile: return "Perfil"
            }
        }

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .ranking: return "trophy.fill"
            case .profile: return "person.fill"
            }
        }
    }

    // MARK: - Navigation Actions

    func navigateToHome() {
        selectedTab = .home
    }

    func navigateToRanking() {
        selectedTab = .ranking
    }

    func navigateToProfile() {
        selectedTab = .profile
    }

    func showOnboarding() {
        showingOnboarding = true
    }

    func hideOnboarding() {
        showingOnboarding = false
    }

    func showSquadInput() {
        showingSquadInput = true
    }

    func hideSquadInput() {
        showingSquadInput = false
    }

    func resetNavigation() {
        selectedTab = .home
        path = NavigationPath()
    }
}

// MARK: - Navigation Destinations
enum NavigationDestination: Hashable {
    case missionDetail(MissionType)
    case userProfile(String) // userId
    case squadDetails(String) // squadCode
    case settings
    case editProfile
    case createSquad
    case photoGallery(String) // userId
}
