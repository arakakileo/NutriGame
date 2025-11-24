//
//  ShimmerEffect.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

// MARK: - Shimmer Effect (Loading Placeholder)
struct ShimmerEffect: ViewModifier {
    let isActive: Bool

    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        if isActive {
            content
                .redacted(reason: .placeholder)
                .overlay(
                    GeometryReader { geometry in
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.4),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 2)
                        .offset(x: -geometry.size.width + phase * geometry.size.width * 3)
                    }
                )
                .mask(content)
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}

extension View {
    func shimmerLoading(_ isLoading: Bool) -> some View {
        modifier(ShimmerEffect(isActive: isLoading))
    }
}

// MARK: - Skeleton Views
struct SkeletonView: View {
    var height: CGFloat = 20
    var cornerRadius: CGFloat = CornerRadius.small

    var body: some View {
        Rectangle()
            .fill(Color.bgTertiary)
            .frame(height: height)
            .cornerRadius(cornerRadius)
            .shimmerLoading(true)
    }
}

struct SkeletonCircle: View {
    var size: CGFloat = 48

    var body: some View {
        Circle()
            .fill(Color.bgTertiary)
            .frame(width: size, height: size)
            .shimmerLoading(true)
    }
}

// MARK: - Mission Card Skeleton
struct MissionCardSkeleton: View {
    var body: some View {
        HStack(spacing: Spacing.md) {
            SkeletonCircle(size: 48)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                SkeletonView(height: 16)
                    .frame(width: 120)
                SkeletonView(height: 12)
                    .frame(width: 80)
            }

            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.bgSecondary)
        .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - Ranking Row Skeleton
struct RankingRowSkeleton: View {
    var body: some View {
        HStack(spacing: Spacing.md) {
            SkeletonView(height: 20)
                .frame(width: 30)

            SkeletonCircle(size: 32)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                SkeletonView(height: 14)
                    .frame(width: 100)
                SkeletonView(height: 10)
                    .frame(width: 60)
            }

            Spacer()

            SkeletonView(height: 16)
                .frame(width: 50)
        }
        .padding(Spacing.md)
        .background(Color.bgSecondary)
        .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - Stats Card Skeleton
struct StatsCardSkeleton: View {
    var body: some View {
        VStack(spacing: Spacing.sm) {
            SkeletonCircle(size: 32)
            SkeletonView(height: 24)
                .frame(width: 50)
            SkeletonView(height: 12)
                .frame(width: 40)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(Color.bgSecondary)
        .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - Home Screen Skeleton
struct HomeScreenSkeleton: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Header skeleton
            VStack(spacing: Spacing.md) {
                HStack(spacing: Spacing.md) {
                    StatsCardSkeleton()
                    StatsCardSkeleton()
                    StatsCardSkeleton()
                }

                SkeletonView(height: 8)
            }
            .padding(Spacing.md)
            .background(Color.bgSecondary)
            .cornerRadius(CornerRadius.large)

            // Missions skeleton
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    SkeletonView(height: 20)
                        .frame(width: 120)
                    Spacer()
                    SkeletonView(height: 16)
                        .frame(width: 40)
                }

                ForEach(0..<4, id: \.self) { _ in
                    MissionCardSkeleton()
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - Ranking Screen Skeleton
struct RankingScreenSkeleton: View {
    var body: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(0..<10, id: \.self) { _ in
                RankingRowSkeleton()
            }
        }
        .padding(.horizontal, Spacing.md)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.xl) {
            Text("Home Skeleton")
                .font(.caption)
            HomeScreenSkeleton()

            Divider()

            Text("Ranking Skeleton")
                .font(.caption)
            RankingScreenSkeleton()
        }
        .padding()
    }
    .background(Color.bgPrimary)
}
