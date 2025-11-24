//
//  Validators.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation

enum Validators {
    // MARK: - Email
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    // MARK: - Password
    static func isValidPassword(_ password: String) -> Bool {
        password.count >= Constants.Validation.minPasswordLength
    }

    static func passwordStrength(_ password: String) -> PasswordStrength {
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecial = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil

        let count = password.count
        var score = 0

        if count >= 6 { score += 1 }
        if count >= 8 { score += 1 }
        if hasUppercase { score += 1 }
        if hasLowercase { score += 1 }
        if hasNumber { score += 1 }
        if hasSpecial { score += 1 }

        switch score {
        case 0...2: return .weak
        case 3...4: return .medium
        default: return .strong
        }
    }

    // MARK: - Name
    static func isValidName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= Constants.Validation.minNameLength &&
               trimmed.count <= Constants.Validation.maxNameLength
    }

    // MARK: - Squad Code
    static func isValidSquadCode(_ code: String) -> Bool {
        Squad.isValidCodeFormat(Squad.normalizeCode(code))
    }

    static func normalizeSquadCode(_ code: String) -> String {
        Squad.normalizeCode(code)
    }
}

// MARK: - Password Strength
enum PasswordStrength {
    case weak
    case medium
    case strong

    var displayName: String {
        switch self {
        case .weak: return "Fraca"
        case .medium: return "Média"
        case .strong: return "Forte"
        }
    }

    var color: String {
        switch self {
        case .weak: return "error"
        case .medium: return "warning"
        case .strong: return "success"
        }
    }
}

// MARK: - Validation Error
enum ValidationError: LocalizedError {
    case invalidEmail
    case invalidPassword
    case passwordTooShort
    case invalidName
    case nameTooShort
    case nameTooLong
    case invalidSquadCode
    case emptyField(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Por favor, insira um e-mail válido."
        case .invalidPassword:
            return "Senha inválida."
        case .passwordTooShort:
            return "A senha deve ter pelo menos \(Constants.Validation.minPasswordLength) caracteres."
        case .invalidName:
            return "Nome inválido."
        case .nameTooShort:
            return "O nome deve ter pelo menos \(Constants.Validation.minNameLength) caracteres."
        case .nameTooLong:
            return "O nome deve ter no máximo \(Constants.Validation.maxNameLength) caracteres."
        case .invalidSquadCode:
            return "Código do squad inválido. Use 6 caracteres alfanuméricos."
        case .emptyField(let field):
            return "O campo '\(field)' é obrigatório."
        }
    }
}
