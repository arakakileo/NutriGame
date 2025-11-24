//
//  CodeInputField.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

// MARK: - Code Input Field (Squad Code)
struct CodeInputField: View {
    @Binding var code: String
    let codeLength: Int
    let onComplete: ((String) -> Void)?

    @FocusState private var isFocused: Bool

    init(
        code: Binding<String>,
        codeLength: Int = 6,
        onComplete: ((String) -> Void)? = nil
    ) {
        self._code = code
        self.codeLength = codeLength
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Hidden text field for keyboard input
            TextField("", text: $code)
                .keyboardType(.asciiCapable)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .focused($isFocused)
                .opacity(0)
                .frame(height: 0)
                .onChange(of: code) { _, newValue in
                    // Filter non-alphanumeric and uppercase
                    let filtered = newValue
                        .uppercased()
                        .filter { $0.isLetter || $0.isNumber }

                    if filtered != newValue {
                        code = String(filtered.prefix(codeLength))
                    }

                    // Limit to codeLength characters
                    if filtered.count > codeLength {
                        code = String(filtered.prefix(codeLength))
                    }

                    // Call completion when full
                    if code.count == codeLength {
                        HapticManager.shared.success()
                        onComplete?(code)
                    }
                }

            // Visual code boxes
            HStack(spacing: Spacing.sm) {
                ForEach(0..<codeLength, id: \.self) { index in
                    CodeBox(
                        character: characterAt(index),
                        isActive: index == code.count && isFocused,
                        isFilled: index < code.count
                    )
                    .onTapGesture {
                        isFocused = true
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }

    private func characterAt(_ index: Int) -> String? {
        guard index < code.count else { return nil }
        let charIndex = code.index(code.startIndex, offsetBy: index)
        return String(code[charIndex])
    }
}

// MARK: - Code Box
private struct CodeBox: View {
    let character: String?
    let isActive: Bool
    let isFilled: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .fill(isFilled ? Color.accentPurple.opacity(0.1) : Color.bgSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .stroke(borderColor, lineWidth: 2)
                )

            if let char = character {
                Text(char)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(.textPrimary)
            }

            // Cursor animation
            if isActive {
                Rectangle()
                    .fill(Color.accentPurple)
                    .frame(width: 2, height: 24)
                    .blinkingCursor()
            }
        }
        .frame(width: 48, height: 56)
    }

    private var borderColor: Color {
        if isActive {
            return .accentPurple
        } else if isFilled {
            return .accentPurple.opacity(0.5)
        } else {
            return .bgTertiary
        }
    }
}

// MARK: - Blinking Cursor Animation
struct BlinkingCursorModifier: ViewModifier {
    @State private var isVisible = true

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    isVisible.toggle()
                }
            }
    }
}

extension View {
    func blinkingCursor() -> some View {
        modifier(BlinkingCursorModifier())
    }
}

// MARK: - OTP Input Field (for verification codes)
struct OTPInputField: View {
    @Binding var otp: String
    let length: Int
    let onComplete: ((String) -> Void)?

    @FocusState private var isFocused: Bool

    init(
        otp: Binding<String>,
        length: Int = 6,
        onComplete: ((String) -> Void)? = nil
    ) {
        self._otp = otp
        self.length = length
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            TextField("", text: $otp)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .opacity(0)
                .frame(height: 0)
                .onChange(of: otp) { _, newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue || filtered.count > length {
                        otp = String(filtered.prefix(length))
                    }

                    if otp.count == length {
                        HapticManager.shared.success()
                        onComplete?(otp)
                    }
                }

            HStack(spacing: Spacing.sm) {
                ForEach(0..<length, id: \.self) { index in
                    OTPBox(
                        digit: digitAt(index),
                        isActive: index == otp.count && isFocused
                    )
                    .onTapGesture {
                        isFocused = true
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }

    private func digitAt(_ index: Int) -> String? {
        guard index < otp.count else { return nil }
        let charIndex = otp.index(otp.startIndex, offsetBy: index)
        return String(otp[charIndex])
    }
}

private struct OTPBox: View {
    let digit: String?
    let isActive: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(digit != nil ? Color.accentGreen.opacity(0.1) : Color.bgSecondary)
                .overlay(
                    Circle()
                        .stroke(isActive ? Color.accentGreen : Color.bgTertiary, lineWidth: 2)
                )

            if let d = digit {
                Text(d)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.textPrimary)
            } else if isActive {
                Circle()
                    .fill(Color.accentGreen)
                    .frame(width: 8, height: 8)
                    .blinkingCursor()
            }
        }
        .frame(width: 44, height: 44)
    }
}

// MARK: - Pin Input Field (for settings/security)
struct PinInputField: View {
    @Binding var pin: String
    let length: Int
    let masked: Bool
    let onComplete: ((String) -> Void)?

    @FocusState private var isFocused: Bool

    init(
        pin: Binding<String>,
        length: Int = 4,
        masked: Bool = true,
        onComplete: ((String) -> Void)? = nil
    ) {
        self._pin = pin
        self.length = length
        self.masked = masked
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            TextField("", text: $pin)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .opacity(0)
                .frame(height: 0)
                .onChange(of: pin) { _, newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue || filtered.count > length {
                        pin = String(filtered.prefix(length))
                    }

                    if pin.count == length {
                        HapticManager.shared.success()
                        onComplete?(pin)
                    }
                }

            HStack(spacing: Spacing.lg) {
                ForEach(0..<length, id: \.self) { index in
                    PinDot(
                        isFilled: index < pin.count,
                        isActive: index == pin.count && isFocused,
                        digit: masked ? nil : digitAt(index)
                    )
                }
            }
            .onTapGesture {
                isFocused = true
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }

    private func digitAt(_ index: Int) -> String? {
        guard index < pin.count else { return nil }
        let charIndex = pin.index(pin.startIndex, offsetBy: index)
        return String(pin[charIndex])
    }
}

private struct PinDot: View {
    let isFilled: Bool
    let isActive: Bool
    let digit: String?

    var body: some View {
        ZStack {
            Circle()
                .stroke(isActive ? Color.accentPurple : Color.textSecondary, lineWidth: 2)
                .frame(width: 20, height: 20)

            if isFilled {
                if let d = digit {
                    Text(d)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.textPrimary)
                } else {
                    Circle()
                        .fill(Color.accentPurple)
                        .frame(width: 12, height: 12)
                }
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isFilled)
    }
}

#Preview {
    VStack(spacing: Spacing.xxl) {
        VStack(spacing: Spacing.sm) {
            Text("Código do Squad")
                .font(.titleSmall)
            CodeInputField(code: .constant("NUT"))
        }

        VStack(spacing: Spacing.sm) {
            Text("Código de Verificação")
                .font(.titleSmall)
            OTPInputField(otp: .constant("123"))
        }

        VStack(spacing: Spacing.sm) {
            Text("PIN")
                .font(.titleSmall)
            PinInputField(pin: .constant("12"))
        }
    }
    .padding()
    .background(Color.bgPrimary)
}
