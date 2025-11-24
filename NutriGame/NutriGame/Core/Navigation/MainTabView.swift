//
//  MainTabView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var navigationState: NavigationState

    var body: some View {
        TabView(selection: $navigationState.selectedTab) {
            HomeView()
                .tabItem {
                    Label(
                        NavigationState.Tab.home.title,
                        systemImage: NavigationState.Tab.home.icon
                    )
                }
                .tag(NavigationState.Tab.home)

            RankingView()
                .tabItem {
                    Label(
                        NavigationState.Tab.ranking.title,
                        systemImage: NavigationState.Tab.ranking.icon
                    )
                }
                .tag(NavigationState.Tab.ranking)

            ProfileView()
                .tabItem {
                    Label(
                        NavigationState.Tab.profile.title,
                        systemImage: NavigationState.Tab.profile.icon
                    )
                }
                .tag(NavigationState.Tab.profile)
        }
        .tint(.accentPurple)
    }
}

#Preview {
    MainTabView()
        .environmentObject(NavigationState())
        .environmentObject(AuthViewModel())
}
