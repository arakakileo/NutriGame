//
//  MissionsListView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

struct MissionsListView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var showingCamera = false
    @State private var selectedMissionType: MissionType?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                Text("Missões do Dia")
                    .font(.titleSmall)
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("\(viewModel.completedCount())/\(viewModel.totalMissions())")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
            }

            // Daily progress
            HStack(spacing: Spacing.xs) {
                Text("+\(viewModel.todayXP()) XP hoje")
                    .font(.caption)
                    .foregroundColor(.accentGreen)

                if viewModel.completedCount() == viewModel.totalMissions() {
                    Text("+ Bônus!")
                        .font(.caption)
                        .foregroundColor(.accentOrange)
                }

                Spacer()
            }

            // Mission Cards
            VStack(spacing: Spacing.sm) {
                ForEach(MissionType.allCases.sorted(by: { $0.order < $1.order }), id: \.self) { type in
                    if type == .hydration {
                        HydrationCard(
                            currentGlasses: viewModel.waterCount(),
                            onUpdate: { glasses in
                                Task {
                                    await viewModel.updateHydration(glasses: glasses)
                                }
                            }
                        )
                    } else {
                        MissionCardView(
                            type: type,
                            isComplete: viewModel.isMissionComplete(type),
                            onTap: {
                                selectedMissionType = type
                                showingCamera = true
                            }
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
            if let type = selectedMissionType {
                CameraView(missionType: type) { imageData in
                    Task {
                        await viewModel.completeMission(type: type, photoData: imageData)
                    }
                }
            }
        }
    }
}

// MARK: - Mission Card View
struct MissionCardView: View {
    let type: MissionType
    let isComplete: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            guard !isComplete else { return }
            HapticManager.shared.buttonTap()
            onTap()
        }) {
            HStack(spacing: Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isComplete ? Color.success.opacity(0.2) : Color.forMission(type).opacity(0.2))
                        .frame(width: 48, height: 48)

                    Image(systemName: isComplete ? "checkmark" : type.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isComplete ? .success : Color.forMission(type))
                }

                // Content
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(type.displayName)
                        .font(.bodyLarge)
                        .foregroundColor(isComplete ? .textSecondary : .textPrimary)
                        .strikethrough(isComplete)

                    Text(isComplete ? "Concluído" : "+\(type.xpReward) XP")
                        .font(.caption)
                        .foregroundColor(isComplete ? .success : .textTertiary)
                }

                Spacer()

                // Chevron
                if !isComplete {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.textTertiary)
                }
            }
            .padding(Spacing.md)
            .background(Color.bgSecondary)
            .cornerRadius(CornerRadius.medium)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isComplete)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Hydration Card
struct HydrationCard: View {
    let currentGlasses: Int
    let onUpdate: (Int) -> Void

    private let maxGlasses = Constants.XP.maxWaterGlasses

    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(currentGlasses >= maxGlasses ? Color.success.opacity(0.2) : Color.missionWater.opacity(0.2))
                        .frame(width: 48, height: 48)

                    Image(systemName: currentGlasses >= maxGlasses ? "checkmark" : "drop.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(currentGlasses >= maxGlasses ? .success : .missionWater)
                }

                // Content
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(MissionType.hydration.displayName)
                        .font(.bodyLarge)
                        .foregroundColor(currentGlasses >= maxGlasses ? .textSecondary : .textPrimary)

                    Text("\(currentGlasses)/\(maxGlasses) copos • +\(currentGlasses * MissionType.hydration.xpReward) XP")
                        .font(.caption)
                        .foregroundColor(currentGlasses >= maxGlasses ? .success : .textTertiary)
                }

                Spacer()
            }

            // Water glasses
            HStack(spacing: Spacing.sm) {
                ForEach(0..<maxGlasses, id: \.self) { index in
                    Button {
                        let newCount = index < currentGlasses ? index : index + 1
                        HapticManager.shared.waterGlass()
                        onUpdate(newCount)
                    } label: {
                        Image(systemName: index < currentGlasses ? "drop.fill" : "drop")
                            .font(.system(size: 24))
                            .foregroundColor(index < currentGlasses ? .missionWater : .textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.bgSecondary)
        .cornerRadius(CornerRadius.medium)
    }
}

#Preview {
    MissionsListView(viewModel: HomeViewModel())
        .padding()
}
