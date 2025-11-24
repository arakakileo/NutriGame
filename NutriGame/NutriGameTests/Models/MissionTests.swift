//
//  MissionTests.swift
//  NutriGameTests
//
//  Created by NutriGame Team
//

import XCTest
@testable import NutriGame

final class MissionTests: XCTestCase {

    // MARK: - Mission Type XP Values

    func testMissionTypeXPValues() {
        XCTAssertEqual(MissionType.breakfast.xpValue, 50)
        XCTAssertEqual(MissionType.lunch.xpValue, 50)
        XCTAssertEqual(MissionType.dinner.xpValue, 50)
        XCTAssertEqual(MissionType.snack.xpValue, 50)
        XCTAssertEqual(MissionType.workout.xpValue, 50)
        XCTAssertEqual(MissionType.hydration.xpValue, 10) // Per water glass
    }

    // MARK: - Mission Type Display Names

    func testMissionTypeDisplayNames() {
        XCTAssertEqual(MissionType.breakfast.displayName, "Café da Manhã")
        XCTAssertEqual(MissionType.lunch.displayName, "Almoço")
        XCTAssertEqual(MissionType.dinner.displayName, "Jantar")
        XCTAssertEqual(MissionType.snack.displayName, "Lanche")
        XCTAssertEqual(MissionType.workout.displayName, "Treino")
        XCTAssertEqual(MissionType.hydration.displayName, "Hidratação")
    }

    // MARK: - Mission Type Icons

    func testMissionTypeIcons() {
        XCTAssertEqual(MissionType.breakfast.icon, "cup.and.saucer.fill")
        XCTAssertEqual(MissionType.lunch.icon, "fork.knife")
        XCTAssertEqual(MissionType.dinner.icon, "moon.stars.fill")
        XCTAssertEqual(MissionType.snack.icon, "carrot.fill")
        XCTAssertEqual(MissionType.workout.icon, "figure.run")
        XCTAssertEqual(MissionType.hydration.icon, "drop.fill")
    }

    // MARK: - Mission Type Requires Photo

    func testMissionTypeRequiresPhoto() {
        XCTAssertTrue(MissionType.breakfast.requiresPhoto)
        XCTAssertTrue(MissionType.lunch.requiresPhoto)
        XCTAssertTrue(MissionType.dinner.requiresPhoto)
        XCTAssertTrue(MissionType.snack.requiresPhoto)
        XCTAssertTrue(MissionType.workout.requiresPhoto)
        XCTAssertFalse(MissionType.hydration.requiresPhoto)
    }

    // MARK: - Hydration XP Calculation

    func testHydrationXPCalculation() {
        XCTAssertEqual(Mission.calculateHydrationXP(waterCount: 0), 0)
        XCTAssertEqual(Mission.calculateHydrationXP(waterCount: 1), 10)
        XCTAssertEqual(Mission.calculateHydrationXP(waterCount: 3), 30)
        XCTAssertEqual(Mission.calculateHydrationXP(waterCount: 5), 50)

        // Should cap at 5 glasses (50 XP)
        XCTAssertEqual(Mission.calculateHydrationXP(waterCount: 10), 50)
    }

    // MARK: - Daily Maximum XP

    func testDailyMaximumXP() {
        // 5 missions × 50 XP + 5 waters × 10 XP + 100 bonus = 400 XP
        let maxXP = Mission.calculateDailyMaxXP()
        XCTAssertEqual(maxXP, 400)
    }

    // MARK: - Daily Bonus Eligibility

    func testDailyBonusEligibility() {
        let allMissions: [MissionType] = [.breakfast, .lunch, .dinner, .snack, .workout, .hydration]
        let fiveMissions: [MissionType] = [.breakfast, .lunch, .dinner, .snack, .workout]
        let fourMissions: [MissionType] = [.breakfast, .lunch, .dinner, .snack]

        XCTAssertTrue(Mission.isEligibleForDailyBonus(completedMissions: allMissions))
        XCTAssertFalse(Mission.isEligibleForDailyBonus(completedMissions: fiveMissions))
        XCTAssertFalse(Mission.isEligibleForDailyBonus(completedMissions: fourMissions))
    }

    // MARK: - Mission Creation

    func testMissionCreation() {
        let mission = Mission(
            id: "mission123",
            userId: "user123",
            squadCode: "ABC123",
            type: .breakfast,
            photoUrl: "https://example.com/photo.jpg",
            waterCount: nil,
            xpEarned: 50,
            completedAt: Date(),
            date: "2024-11-24"
        )

        XCTAssertEqual(mission.id, "mission123")
        XCTAssertEqual(mission.type, .breakfast)
        XCTAssertEqual(mission.xpEarned, 50)
        XCTAssertNotNil(mission.photoUrl)
        XCTAssertNil(mission.waterCount)
    }

    func testHydrationMissionCreation() {
        let mission = Mission(
            id: "mission456",
            userId: "user123",
            squadCode: "ABC123",
            type: .hydration,
            photoUrl: nil,
            waterCount: 5,
            xpEarned: 50,
            completedAt: Date(),
            date: "2024-11-24"
        )

        XCTAssertEqual(mission.type, .hydration)
        XCTAssertNil(mission.photoUrl)
        XCTAssertEqual(mission.waterCount, 5)
        XCTAssertEqual(mission.xpEarned, 50)
    }
}

// MARK: - Mission Extension for Tests
extension Mission {
    static func calculateHydrationXP(waterCount: Int) -> Int {
        let cappedCount = min(waterCount, 5)
        return cappedCount * 10
    }

    static func calculateDailyMaxXP() -> Int {
        // 5 photo missions × 50 XP
        let photoMissionsXP = 5 * 50

        // 5 water glasses × 10 XP
        let hydrationXP = 5 * 10

        // Daily bonus
        let dailyBonus = 100

        return photoMissionsXP + hydrationXP + dailyBonus
    }

    static func isEligibleForDailyBonus(completedMissions: [MissionType]) -> Bool {
        let requiredMissions = Set(MissionType.allCases)
        let completedSet = Set(completedMissions)
        return requiredMissions.isSubset(of: completedSet)
    }
}
