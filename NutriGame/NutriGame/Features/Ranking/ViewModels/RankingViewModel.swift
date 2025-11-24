//
//  RankingViewModel.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import FirebaseFirestore

@MainActor
final class RankingViewModel: ObservableObject {
    @Published var ranking: [RankedUser] = []
    @Published var currentUserPosition: Int?
    @Published var isLoading = false
    @Published var error: Error?

    private let rankingService = RankingService.shared
    private var userId: String = ""
    private var squadCode: String = ""
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    // MARK: - Setup

    func setup(userId: String, squadCode: String) {
        self.userId = userId
        self.squadCode = squadCode
        startListening()
    }

    // MARK: - Listeners

    private func startListening() {
        guard !squadCode.isEmpty, !userId.isEmpty else { return }

        listener?.remove()
        isLoading = true

        listener = rankingService.observeWeeklyRanking(
            squadCode: squadCode,
            currentUserId: userId
        ) { [weak self] rankedUsers in
            DispatchQueue.main.async {
                self?.ranking = rankedUsers
                self?.currentUserPosition = rankedUsers.first(where: { $0.isCurrentUser })?.position
                self?.isLoading = false
            }
        }
    }

    // MARK: - Actions

    func refresh() async {
        guard !squadCode.isEmpty, !userId.isEmpty else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            ranking = try await rankingService.getWeeklyRanking(
                squadCode: squadCode,
                currentUserId: userId
            )
            currentUserPosition = ranking.first(where: { $0.isCurrentUser })?.position
        } catch {
            self.error = error
        }
    }
}
