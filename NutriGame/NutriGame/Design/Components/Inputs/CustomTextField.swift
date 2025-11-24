//
//  CustomTextField.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

// MARK: - Custom Text Field
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String?
    let keyboardType: UIKeyboardType
    let autocapitalization: TextInputAutocapitalization
    let isSecure: Bool
    let errorMessage: String?
    let onSubmit: (() -> Void)?

    @FocusState private var isFocused: Bool
    @State private var showPassword = false

    init(
        _ placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences,
        isSecure: Bool = false,
        errorMessage: String? = nil,
        onSubmit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.isSecure = isSecure
        self.errorMessage = errorMessage
        self.onSubmit = onSubmit
    }

    private var hasError: Bool {
        errorMessage != nil && !errorMessage!.isEmpty
    }

    private var borderColor: Color {
        if hasError {
            return .error
        } else if isFocused {
            return .accentPurple
        } else {
            return .clear
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            HStack(spacing: Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(isFocused ? .accentPurple : .textSecondary)
                }

                Group {
                    if isSecure && !showPassword {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .focused($isFocused)
                .onSubmit {
                    onSubmit?()
                }

                if isSecure {
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.textSecondary)
                    }
                }

                if !text.isEmpty && !isSecure {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.bgSecondary)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(borderColor, lineWidth: 2)
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)

            if let error = errorMessage, !error.isEmpty {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(error)
                        .font(.caption)
                }
                .foregroundColor(.error)
            }
        }
    }
}

// MARK: - Email Text Field
struct EmailTextField: View {
    @Binding var email: String
    let errorMessage: String?
    let onSubmit: (() -> Void)?

    init(
        email: Binding<String>,
        errorMessage: String? = nil,
        onSubmit: (() -> Void)? = nil
    ) {
        self._email = email
        self.errorMessage = errorMessage
        self.onSubmit = onSubmit
    }

    var body: some View {
        CustomTextField(
            "Email",
            text: $email,
            icon: "envelope.fill",
            keyboardType: .emailAddress,
            autocapitalization: .never,
            errorMessage: errorMessage,
            onSubmit: onSubmit
        )
    }
}

// MARK: - Password Text Field
struct PasswordTextField: View {
    @Binding var password: String
    let placeholder: String
    let errorMessage: String?
    let onSubmit: (() -> Void)?

    init(
        _ placeholder: String = "Senha",
        password: Binding<String>,
        errorMessage: String? = nil,
        onSubmit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._password = password
        self.errorMessage = errorMessage
        self.onSubmit = onSubmit
    }

    var body: some View {
        CustomTextField(
            placeholder,
            text: $password,
            icon: "lock.fill",
            autocapitalization: .never,
            isSecure: true,
            errorMessage: errorMessage,
            onSubmit: onSubmit
        )
    }
}

// MARK: - Search Text Field
struct SearchTextField: View {
    @Binding var text: String
    let placeholder: String
    let onSearch: ((String) -> Void)?

    @FocusState private var isFocused: Bool

    init(
        text: Binding<String>,
        placeholder: String = "Buscar...",
        onSearch: ((String) -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSearch = onSearch
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(.textSecondary)

            TextField(placeholder, text: $text)
                .focused($isFocused)
                .onSubmit {
                    onSearch?(text)
                }

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.bgSecondary)
        .cornerRadius(CornerRadius.full)
    }
}

// MARK: - Text Area
struct TextArea: View {
    let placeholder: String
    @Binding var text: String
    let minHeight: CGFloat
    let maxHeight: CGFloat
    let characterLimit: Int?

    @FocusState private var isFocused: Bool

    init(
        _ placeholder: String,
        text: Binding<String>,
        minHeight: CGFloat = 100,
        maxHeight: CGFloat = 200,
        characterLimit: Int? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.characterLimit = characterLimit
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: Spacing.xxs) {
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.bodyMedium)
                        .foregroundColor(.textTertiary)
                        .padding(Spacing.sm)
                }

                TextEditor(text: $text)
                    .font(.bodyMedium)
                    .focused($isFocused)
                    .scrollContentBackground(.hidden)
                    .onChange(of: text) { _, newValue in
                        if let limit = characterLimit, newValue.count > limit {
                            text = String(newValue.prefix(limit))
                        }
                    }
            }
            .frame(minHeight: minHeight, maxHeight: maxHeight)
            .padding(Spacing.xs)
            .background(Color.bgSecondary)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(isFocused ? Color.accentPurple : Color.clear, lineWidth: 2)
            )

            if let limit = characterLimit {
                Text("\(text.count)/\(limit)")
                    .font(.caption)
                    .foregroundColor(text.count >= limit ? .warning : .textTertiary)
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            CustomTextField("Nome", text: .constant("João"), icon: "person.fill")

            CustomTextField("Com erro", text: .constant("teste"), icon: "envelope.fill", errorMessage: "Email inválido")

            EmailTextField(email: .constant("joao@email.com"))

            PasswordTextField(password: .constant("123456"))

            SearchTextField(text: .constant("Buscar..."))

            TextArea("Escreva uma mensagem...", text: .constant(""), characterLimit: 200)
        }
        .padding()
    }
    .background(Color.bgPrimary)
}
