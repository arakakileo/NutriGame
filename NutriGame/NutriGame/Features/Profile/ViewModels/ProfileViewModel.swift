//
//  ProfileViewModel.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var recentPhotos: [Mission] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let missionService = MissionService.shared

    // MARK: - Load Data

    func loadRecentPhotos(userId: String) {
        guard !userId.isEmpty else { return }

        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                recentPhotos = try await missionService.getUserMissions(userId: userId, limit: 9)
            } catch {
                self.error = error
            }
        }
    }
}
