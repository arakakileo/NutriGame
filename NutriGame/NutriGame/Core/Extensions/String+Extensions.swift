//
//  String+Extensions.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation

extension String {
    // MARK: - Validation

    var isValidEmail: Bool {
        Validators.isValidEmail(self)
    }

    var isNotEmpty: Bool {
        !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Formatting

    var initials: String {
        let words = self.split(separator: " ")
        let initials = words.prefix(2).compactMap { $0.first }
        return String(initials).uppercased()
    }

    var capitalizedFirst: String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst()
    }

    // MARK: - Squad Code

    var normalizedSquadCode: String {
        Squad.normalizeCode(self)
    }

    var isValidSquadCode: Bool {
        Squad.isValidCodeFormat(normalizedSquadCode)
    }

    // MARK: - Number Formatting

    func formatAsXP() -> String {
        guard let number = Int(self) else { return self }
        return number.formattedXP
    }
}

// MARK: - Int Extensions for XP Formatting
extension Int {
    var formattedXP: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    var formattedCompact: String {
        if self >= 1000000 {
            return String(format: "%.1fM", Double(self) / 1000000)
        } else if self >= 1000 {
            return String(format: "%.1fK", Double(self) / 1000)
        }
        return "\(self)"
    }
}

// MARK: - Optional String
extension Optional where Wrapped == String {
    var orEmpty: String {
        self ?? ""
    }

    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}
