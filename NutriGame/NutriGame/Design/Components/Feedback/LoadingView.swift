//
//  LoadingView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

// MARK: - Full Screen Loading View
struct LoadingView: View {
    let message: String?
    let style: LoadingStyle

    enum LoadingStyle {
        case fullScreen
        case overlay
        case inline

        var backgroundOpacity: Double {
            switch self {
            case .fullScreen: return 1.0
            case .overlay: return 0.8
            case .inline: return 0
            }
        }
    }

    init(message: String? = nil, style: LoadingStyle = .fullScreen) {
        self.message = message
        self.style = style
    }

    var body: some View {
        ZStack {
            if style != .inline {
                Color.bgPrimary
                    .opacity(style.backgroundOpacity)
                    .ignoresSafeArea()
            }

            VStack(spacing: Spacing.lg) {
                LoadingIndicator()

                if let message = message {
                    Text(message)
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(Spacing.xl)
        }
    }
}

// MARK: - Loading Indicator
struct LoadingIndicator: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.accentPurple.opacity(0.2), lineWidth: 4)
                .frame(width: 48, height: 48)

            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.accentPurple, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 48, height: 48)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Small Loading Indicator
struct SmallLoadingIndicator: View {
    let color: Color
    let size: CGFloat

    @State private var isAnimating = false

    init(color: Color = .accentPurple, size: CGFloat = 20) {
        self.color = color
        self.size = size
    }

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .frame(width: size, height: size)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(.linear(duration: 0.8).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Progress Loading View
struct ProgressLoadingView: View {
    let progress: Double
    let message: String?

    init(progress: Double, message: String? = nil) {
        self.progress = progress
        self.message = message
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.accentPurple.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.accentPurple, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progress)

                Text("\(Int(progress * 100))%")
                    .font(.xpSmall)
                    .foregroundColor(.textPrimary)
            }

            if let message = message {
                Text(message)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

// MARK: - Dots Loading Animation
struct DotsLoadingView: View {
    @State private var animatingDots = [false, false, false]

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.accentPurple)
                    .frame(width: 8, height: 8)
                    .offset(y: animatingDots[index] ? -6 : 0)
            }
        }
        .onAppear {
            for i in 0..<3 {
                withAnimation(
                    .easeInOut(duration: 0.4)
                    .repeatForever(autoreverses: true)
                    .delay(Double(i) * 0.15)
                ) {
                    animatingDots[i] = true
                }
            }
        }
    }
}

// MARK: - Loading Button Content
struct LoadingButtonContent: View {
    let isLoading: Bool
    let title: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            if isLoading {
                SmallLoadingIndicator(color: .white, size: 16)
            }
            Text(isLoading ? "Carregando..." : title)
        }
    }
}

// MARK: - Pull to Refresh Loading
struct PullToRefreshIndicator: View {
    let progress: Double
    let isRefreshing: Bool

    var body: some View {
        ZStack {
            if isRefreshing {
                SmallLoadingIndicator(size: 24)
            } else {
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(Color.accentPurple, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 24, height: 24)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "arrow.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.accentPurple)
                    .opacity(progress >= 1 ? 1 : 0.5)
                    .rotationEffect(.degrees(progress >= 1 ? 180 : 0))
                    .animation(.easeInOut(duration: 0.2), value: progress >= 1)
            }
        }
        .frame(height: 40)
    }
}

// MARK: - View Modifier for Loading Overlay
struct LoadingOverlayModifier: ViewModifier {
    let isLoading: Bool
    let message: String?

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .blur(radius: isLoading ? 2 : 0)

            if isLoading {
                LoadingView(message: message, style: .overlay)
            }
        }
    }
}

extension View {
    func loadingOverlay(isLoading: Bool, message: String? = nil) -> some View {
        modifier(LoadingOverlayModifier(isLoading: isLoading, message: message))
    }
}

#Preview {
    VStack(spacing: Spacing.xxl) {
        // Full screen loading
        LoadingView(message: "Carregando suas missões...")
            .frame(height: 200)

        // Loading indicator
        LoadingIndicator()

        // Small indicator
        SmallLoadingIndicator()

        // Progress loading
        ProgressLoadingView(progress: 0.65, message: "Enviando foto...")

        // Dots loading
        DotsLoadingView()
    }
    .padding()
    .background(Color.bgPrimary)
}
