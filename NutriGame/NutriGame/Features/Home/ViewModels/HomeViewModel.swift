//
//  HomeViewModel.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import FirebaseFirestore

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var todayMissions: [MissionType: Mission] = [:]
    @Published var isLoading = false
    @Published var error: Error?

    private let missionService = MissionService.shared
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
        guard !userId.isEmpty else { return }

        listener?.remove()
        listener = missionService.observeTodayMissions(userId: userId) { [weak self] missions in
            DispatchQueue.main.async {
                self?.todayMissions = Dictionary(
                    uniqueKeysWithValues: missions.map { ($0.type, $0) }
                )
            }
        }
    }

    // MARK: - Actions

    func refresh() async {
        do {
            let missions = try await missionService.getTodayMissions(userId: userId)
            todayMissions = Dictionary(
                uniqueKeysWithValues: missions.map { ($0.type, $0) }
            )
        } catch {
            self.error = error
        }
    }

    func completeMission(type: MissionType, photoData: Data) async -> Bool {
        guard !userId.isEmpty, !squadCode.isEmpty else { return false }

        isLoading = true
        defer { isLoading = false }

        do {
            let mission = try await missionService.completeMission(
                userId: userId,
                squadCode: squadCode,
                type: type,
                photoData: photoData
            )
            todayMissions[type] = mission
            HapticManager.shared.missionComplete()
            return true
        } catch {
            self.error = error
            HapticManager.shared.errorOccurred()
            return false
        }
    }

    func updateHydration(glasses: Int) async -> Bool {
        guard !userId.isEmpty, !squadCode.isEmpty else { return false }

        do {
            let mission = try await missionService.updateHydration(
                userId: userId,
                squadCode: squadCode,
                glasses: glasses
            )
            todayMissions[.hydration] = mission
            HapticManager.shared.waterGlass()
            return true
        } catch {
            self.error = error
            return false
        }
    }

    // MARK: - Helpers

    func isMissionComplete(_ type: MissionType) -> Bool {
        if type == .hydration {
            return (todayMissions[type]?.waterCount ?? 0) >= 5
        }
        return todayMissions[type] != nil
    }

    func waterCount() -> Int {
        todayMissions[.hydration]?.waterCount ?? 0
    }

    func completedCount() -> Int {
        var count = 0
        for type in MissionType.allCases {
            if type == .hydration {
                if waterCount() >= 5 { count += 1 }
            } else if todayMissions[type] != nil {
                count += 1
            }
        }
        return count
    }

    func totalMissions() -> Int {
        MissionType.allCases.count
    }

    func todayXP() -> Int {
        var xp = 0
        for (type, mission) in todayMissions {
            if type == .hydration {
                xp += (mission.waterCount ?? 0) * MissionType.hydration.xpReward
            } else {
                xp += mission.xpEarned
            }
        }
        // Daily bonus
        if completedCount() == totalMissions() {
            xp += Constants.XP.dailyBonus
        }
        return xp
    }
}
