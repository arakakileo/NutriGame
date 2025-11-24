//
//  PulseAnimation.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

// MARK: - Pulse Effect
struct PulseEffect: ViewModifier {
    let isActive: Bool
    let color: Color
    let duration: Double

    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .background(
                Circle()
                    .fill(color.opacity(0.3))
                    .scaleEffect(isPulsing ? 1.5 : 1.0)
                    .opacity(isPulsing ? 0 : 0.5)
            )
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    startPulse()
                }
            }
            .onAppear {
                if isActive {
                    startPulse()
                }
            }
    }

    private func startPulse() {
        withAnimation(.easeOut(duration: duration)) {
            isPulsing = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            isPulsing = false
        }
    }
}

extension View {
    func pulseEffect(
        isActive: Bool,
        color: Color = .accentPurple,
        duration: Double = 0.5
    ) -> some View {
        modifier(PulseEffect(isActive: isActive, color: color, duration: duration))
    }
}

// MARK: - Continuous Pulse
struct ContinuousPulse: ViewModifier {
    let isActive: Bool
    let color: Color
    let scale: CGFloat

    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 2)
                    .scaleEffect(isPulsing ? scale : 1.0)
                    .opacity(isPulsing ? 0 : 0.8)
            )
            .onAppear {
                if isActive {
                    startContinuousPulse()
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    startContinuousPulse()
                } else {
                    isPulsing = false
                }
            }
    }

    private func startContinuousPulse() {
        withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
            isPulsing = true
        }
    }
}

extension View {
    func continuousPulse(
        isActive: Bool,
        color: Color = .accentGreen,
        scale: CGFloat = 1.5
    ) -> some View {
        modifier(ContinuousPulse(isActive: isActive, color: color, scale: scale))
    }
}

// MARK: - Streak Fire Animation
struct StreakFireView: View {
    let streak: Int
    let animate: Bool

    @State private var flameScale: CGFloat = 1.0
    @State private var flameOffset: CGFloat = 0

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: "flame.fill")
                .font(.system(size: 20))
                .foregroundColor(.accentOrange)
                .scaleEffect(flameScale)
                .offset(y: flameOffset)

            Text("\(streak)")
                .font(.xpSmall)
                .foregroundColor(.accentOrange)
        }
        .onChange(of: animate) { _, newValue in
            if newValue {
                animateFire()
            }
        }
    }

    private func animateFire() {
        // Scale up
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            flameScale = 1.3
        }

        // Wiggle
        withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
            flameOffset = -2
        }

        // Reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                flameScale = 1.0
                flameOffset = 0
            }
        }
    }
}

// MARK: - Level Up Animation
struct LevelUpOverlay: View {
    let newLevel: Int
    @Binding var isVisible: Bool

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var starRotation: Double = 0

    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .opacity(opacity)

            // Content
            VStack(spacing: Spacing.lg) {
                // Star icon
                ZStack {
                    // Glow
                    Circle()
                        .fill(Color.accentPurple.opacity(0.3))
                        .frame(width: 150, height: 150)
                        .blur(radius: 20)

                    // Star
                    Image(systemName: "star.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.accentPurple)
                        .rotationEffect(.degrees(starRotation))
                }

                VStack(spacing: Spacing.sm) {
                    Text("LEVEL UP!")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.accentPurple)

                    Text("Nível \(newLevel)")
                        .font(.xpLarge)
                        .foregroundColor(.white)
                }

                Button("Continuar") {
                    dismiss()
                }
                .secondaryButtonStyle()
                .padding(.top, Spacing.lg)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onChange(of: isVisible) { _, newValue in
            if newValue {
                showAnimation()
            }
        }
    }

    private func showAnimation() {
        HapticManager.shared.levelUp()

        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            scale = 1.0
            opacity = 1.0
        }

        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            starRotation = 360
        }
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.2)) {
            scale = 1.1
            opacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isVisible = false
        }
    }
}

// MARK: - View Modifier
extension View {
    func levelUpOverlay(level: Int, isVisible: Binding<Bool>) -> some View {
        ZStack {
            self
            if isVisible.wrappedValue {
                LevelUpOverlay(newLevel: level, isVisible: isVisible)
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showLevelUp = false
        @State private var animateStreak = false

        var body: some View {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                VStack(spacing: Spacing.xl) {
                    StreakFireView(streak: 7, animate: animateStreak)

                    Button("Animate Streak") {
                        animateStreak = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            animateStreak = false
                        }
                    }

                    Button("Level Up!") {
                        showLevelUp = true
                    }
                    .primaryButtonStyle()
                    .padding()
                }
            }
            .levelUpOverlay(level: 5, isVisible: $showLevelUp)
        }
    }

    return PreviewWrapper()
}
