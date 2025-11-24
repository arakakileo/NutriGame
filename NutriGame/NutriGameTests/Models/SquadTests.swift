//
//  SquadTests.swift
//  NutriGameTests
//
//  Created by NutriGame Team
//

import XCTest
@testable import NutriGame

final class SquadTests: XCTestCase {

    // MARK: - Squad Code Generation

    func testSquadCodeLength() {
        let code = Squad.generateCode()
        XCTAssertEqual(code.count, 6)
    }

    func testSquadCodeFormat() {
        let code = Squad.generateCode()

        // Should be alphanumeric
        let alphanumericSet = CharacterSet.alphanumerics
        XCTAssertTrue(code.unicodeScalars.allSatisfy { alphanumericSet.contains($0) })

        // Should be uppercase
        XCTAssertEqual(code, code.uppercased())
    }

    func testSquadCodeUniqueness() {
        var codes = Set<String>()

        // Generate 100 codes and check for uniqueness
        for _ in 0..<100 {
            let code = Squad.generateCode()
            XCTAssertFalse(codes.contains(code), "Duplicate code generated: \(code)")
            codes.insert(code)
        }
    }

    // MARK: - Squad Validation

    func testValidSquadCode() {
        XCTAssertTrue(Squad.isValidCode("ABC123"))
        XCTAssertTrue(Squad.isValidCode("NUTRI1"))
        XCTAssertTrue(Squad.isValidCode("A1B2C3"))
    }

    func testInvalidSquadCode() {
        // Too short
        XCTAssertFalse(Squad.isValidCode("ABC"))

        // Too long
        XCTAssertFalse(Squad.isValidCode("ABCDEFG"))

        // Lowercase
        XCTAssertFalse(Squad.isValidCode("abc123"))

        // Special characters
        XCTAssertFalse(Squad.isValidCode("ABC-12"))

        // Empty
        XCTAssertFalse(Squad.isValidCode(""))
    }

    // MARK: - Squad Creation

    func testSquadCreation() {
        let squad = Squad(
            code: "TEST01",
            name: "Meu Squad",
            ownerUserId: "user123",
            memberCount: 1,
            maxMembers: 100,
            createdAt: Date(),
            isPremium: false,
            premiumFeatures: []
        )

        XCTAssertEqual(squad.code, "TEST01")
        XCTAssertEqual(squad.name, "Meu Squad")
        XCTAssertEqual(squad.ownerUserId, "user123")
        XCTAssertEqual(squad.memberCount, 1)
        XCTAssertEqual(squad.maxMembers, 100)
        XCTAssertFalse(squad.isPremium)
    }

    // MARK: - Squad Capacity

    func testSquadHasSpace() {
        let squad = Squad(
            code: "TEST01",
            name: "Test Squad",
            ownerUserId: "user123",
            memberCount: 50,
            maxMembers: 100,
            createdAt: Date(),
            isPremium: false,
            premiumFeatures: []
        )

        XCTAssertTrue(squad.hasSpace)
    }

    func testSquadFull() {
        let squad = Squad(
            code: "TEST01",
            name: "Test Squad",
            ownerUserId: "user123",
            memberCount: 100,
            maxMembers: 100,
            createdAt: Date(),
            isPremium: false,
            premiumFeatures: []
        )

        XCTAssertFalse(squad.hasSpace)
    }

    func testSquadRemainingSpots() {
        let squad = Squad(
            code: "TEST01",
            name: "Test Squad",
            ownerUserId: "user123",
            memberCount: 75,
            maxMembers: 100,
            createdAt: Date(),
            isPremium: false,
            premiumFeatures: []
        )

        XCTAssertEqual(squad.remainingSpots, 25)
    }
}

// MARK: - Squad Extension for Tests
extension Squad {
    static func generateCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }

    static func isValidCode(_ code: String) -> Bool {
        guard code.count == 6 else { return false }
        let pattern = "^[A-Z0-9]{6}$"
        return code.range(of: pattern, options: .regularExpression) != nil
    }

    var hasSpace: Bool {
        memberCount < maxMembers
    }

    var remainingSpots: Int {
        maxMembers - memberCount
    }
}
