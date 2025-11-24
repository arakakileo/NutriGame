//
//  XPGainAnimation.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

struct XPGainAnimation: View {
    let xpAmount: Int
    @Binding var isVisible: Bool

    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: "bolt.fill")
                .foregroundColor(.accentGreen)

            Text("+\(xpAmount) XP")
                .font(.xpMedium)
                .foregroundColor(.accentGreen)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.accentGreen.opacity(0.2))
        .cornerRadius(CornerRadius.full)
        .scaleEffect(scale)
        .offset(y: offset)
        .opacity(opacity)
        .onChange(of: isVisible) { _, newValue in
            if newValue {
                animate()
            }
        }
        .onAppear {
            if isVisible {
                animate()
            }
        }
    }

    private func animate() {
        // Reset
        offset = 0
        opacity = 0
        scale = 0.5

        // Animate in
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            opacity = 1
            scale = 1
        }

        // Float up and fade
        withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
            offset = -50
        }

        withAnimation(.easeIn(duration: 0.3).delay(1.2)) {
            opacity = 0
        }

        // Reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isVisible = false
        }
    }
}

// MARK: - XP Gain Overlay
struct XPGainOverlay: View {
    let xpAmount: Int
    @Binding var isVisible: Bool

    var body: some View {
        ZStack {
            if isVisible {
                XPGainAnimation(xpAmount: xpAmount, isVisible: $isVisible)
            }
        }
    }
}

// MARK: - View Modifier
struct XPGainModifier: ViewModifier {
    let xpAmount: Int
    @Binding var isVisible: Bool

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                XPGainOverlay(xpAmount: xpAmount, isVisible: $isVisible)
                    .padding(.top, Spacing.xl)
            }
    }
}

extension View {
    func xpGainAnimation(amount: Int, isVisible: Binding<Bool>) -> some View {
        modifier(XPGainModifier(xpAmount: amount, isVisible: isVisible))
    }
}

// MARK: - Multiple XP Gains
struct XPGainQueue: View {
    @Binding var gains: [XPGain]

    var body: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(gains) { gain in
                XPGainItem(gain: gain) {
                    gains.removeAll { $0.id == gain.id }
                }
            }
        }
    }
}

struct XPGain: Identifiable {
    let id = UUID()
    let amount: Int
    let source: String?

    init(amount: Int, source: String? = nil) {
        self.amount = amount
        self.source = source
    }
}

struct XPGainItem: View {
    let gain: XPGain
    let onComplete: () -> Void

    @State private var offset: CGFloat = 20
    @State private var opacity: Double = 0

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "bolt.fill")
                .foregroundColor(.accentGreen)

            Text("+\(gain.amount) XP")
                .font(.xpSmall)
                .foregroundColor(.accentGreen)

            if let source = gain.source {
                Text("• \(source)")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.accentGreen.opacity(0.15))
        .cornerRadius(CornerRadius.full)
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = 0
                opacity = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeIn(duration: 0.3)) {
                    opacity = 0
                    offset = -20
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onComplete()
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showXP = false

        var body: some View {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                VStack {
                    Button("Gain XP") {
                        showXP = true
                        HapticManager.shared.xpGain()
                    }
                    .primaryButtonStyle()
                    .padding()
                }
            }
            .xpGainAnimation(amount: 50, isVisible: $showXP)
        }
    }

    return PreviewWrapper()
}
