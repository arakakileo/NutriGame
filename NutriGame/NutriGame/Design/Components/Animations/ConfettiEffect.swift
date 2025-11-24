//
//  ConfettiEffect.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

struct ConfettiView: View {
    @Binding var isActive: Bool
    var intensity: Int = 50

    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(particle: particle)
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    createParticles(in: geometry.size)
                    HapticManager.shared.levelUp()

                    // Auto-dismiss after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        isActive = false
                        particles.removeAll()
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func createParticles(in size: CGSize) {
        particles = (0..<intensity).map { _ in
            ConfettiParticle(
                position: CGPoint(x: size.width / 2, y: -20),
                color: [Color.accentGreen, Color.accentPurple, Color.accentOrange, Color.blue, Color.pink].randomElement()!,
                size: CGFloat.random(in: 6...12),
                rotation: Double.random(in: 0...360),
                velocity: CGPoint(
                    x: CGFloat.random(in: -200...200),
                    y: CGFloat.random(in: 200...400)
                ),
                angularVelocity: Double.random(in: -360...360),
                delay: Double.random(in: 0...0.5)
            )
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var rotation: Double
    var velocity: CGPoint
    var angularVelocity: Double
    var delay: Double
}

struct ConfettiPiece: View {
    let particle: ConfettiParticle

    @State private var position: CGPoint
    @State private var rotation: Double
    @State private var opacity: Double = 1

    init(particle: ConfettiParticle) {
        self.particle = particle
        self._position = State(initialValue: particle.position)
        self._rotation = State(initialValue: particle.rotation)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size * 0.6)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 2.0)
                    .delay(particle.delay)
                ) {
                    position = CGPoint(
                        x: particle.position.x + particle.velocity.x,
                        y: particle.position.y + particle.velocity.y
                    )
                    rotation = particle.rotation + particle.angularVelocity * 2
                }

                withAnimation(
                    .easeIn(duration: 0.5)
                    .delay(particle.delay + 1.5)
                ) {
                    opacity = 0
                }
            }
    }
}

// MARK: - View Modifier
struct ConfettiModifier: ViewModifier {
    @Binding var isActive: Bool
    var intensity: Int

    func body(content: Content) -> some View {
        ZStack {
            content
            ConfettiView(isActive: $isActive, intensity: intensity)
        }
    }
}

extension View {
    func confetti(isActive: Binding<Bool>, intensity: Int = 50) -> some View {
        modifier(ConfettiModifier(isActive: isActive, intensity: intensity))
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showConfetti = false

        var body: some View {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                VStack {
                    Text("Level Up!")
                        .font(.titleLarge)

                    Button("Celebrate!") {
                        showConfetti = true
                    }
                    .primaryButtonStyle()
                    .padding()
                }
            }
            .confetti(isActive: $showConfetti)
        }
    }

    return PreviewWrapper()
}
