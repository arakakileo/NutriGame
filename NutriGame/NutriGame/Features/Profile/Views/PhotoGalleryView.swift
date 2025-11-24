//
//  PhotoGalleryView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

struct PhotoGalleryView: View {
    let userId: String
    let userName: String

    @StateObject private var viewModel = GalleryViewModel()
    @State private var selectedMission: Mission?

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.photos.isEmpty {
                LoadingView(message: "Carregando fotos...")
                    .frame(maxWidth: .infinity)
                    .padding(.top, Spacing.xxxl)
            } else if viewModel.photos.isEmpty {
                EmptyGalleryFullView()
                    .padding(.top, Spacing.xxxl)
            } else {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(viewModel.photos) { mission in
                        GalleryPhotoItem(mission: mission)
                            .onTapGesture {
                                selectedMission = mission
                            }
                    }
                }
            }
        }
        .background(Color.bgPrimary)
        .navigationTitle("Fotos de \(userName.components(separatedBy: " ").first ?? userName)")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedMission) { mission in
            PhotoDetailView(mission: mission)
        }
        .onAppear {
            viewModel.loadPhotos(userId: userId)
        }
    }
}

// MARK: - Gallery Photo Item
struct GalleryPhotoItem: View {
    let mission: Mission

    var body: some View {
        GeometryReader { geometry in
            if let urlString = mission.photoUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.bgSecondary)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.bgSecondary)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.textTertiary)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Photo Detail View
struct PhotoDetailView: View {
    let mission: Mission
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Photo
                        if let urlString = mission.photoUrl, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.bgSecondary)
                                    .overlay(ProgressView())
                            }
                            .frame(maxWidth: geometry.size.width)
                            .cornerRadius(CornerRadius.medium)
                        }

                        // Info
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            // Mission type
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.forMission(mission.type).opacity(0.2))
                                        .frame(width: 40, height: 40)

                                    Image(systemName: mission.type.icon)
                                        .foregroundColor(Color.forMission(mission.type))
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(mission.type.displayName)
                                        .font(.bodyLarge)
                                        .foregroundColor(.textPrimary)

                                    Text(mission.completedAt.relative)
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)
                                }

                                Spacer()

                                // XP earned
                                HStack(spacing: Spacing.xxs) {
                                    Image(systemName: "bolt.fill")
                                        .foregroundColor(.accentGreen)
                                    Text("+\(mission.xpEarned) XP")
                                        .font(.xpSmall)
                                        .foregroundColor(.accentGreen)
                                }
                            }

                            // Date
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.textTertiary)
                                Text(mission.completedAt.fullDate)
                                    .font(.bodyMedium)
                                    .foregroundColor(.textSecondary)

                                Spacer()

                                Image(systemName: "clock")
                                    .foregroundColor(.textTertiary)
                                Text(mission.completedAt.time)
                                    .font(.bodyMedium)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .padding(Spacing.md)
                        .background(Color.bgSecondary)
                        .cornerRadius(CornerRadius.medium)
                    }
                    .padding(Spacing.md)
                }
            }
            .background(Color.bgPrimary)
            .navigationTitle("Detalhes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Empty Gallery Full View
struct EmptyGalleryFullView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)

            Text("Nenhuma foto ainda")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)

            Text("As fotos das missões completadas aparecerão aqui")
                .font(.bodyMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
        }
    }
}

// MARK: - Gallery View Model
@MainActor
final class GalleryViewModel: ObservableObject {
    @Published var photos: [Mission] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let missionService = MissionService.shared
    private var lastDocument: Mission?
    private var hasMorePages = true

    func loadPhotos(userId: String) {
        guard !isLoading else { return }

        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let newPhotos = try await missionService.getUserMissions(
                    userId: userId,
                    limit: Constants.Pagination.galleryPageSize
                )
                photos = newPhotos
                hasMorePages = newPhotos.count >= Constants.Pagination.galleryPageSize
                lastDocument = newPhotos.last
            } catch {
                self.error = error
            }
        }
    }

    func loadMore(userId: String) {
        guard !isLoading, hasMorePages else { return }

        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let newPhotos = try await missionService.getUserMissions(
                    userId: userId,
                    limit: Constants.Pagination.galleryPageSize
                )
                photos.append(contentsOf: newPhotos)
                hasMorePages = newPhotos.count >= Constants.Pagination.galleryPageSize
                lastDocument = newPhotos.last
            } catch {
                self.error = error
            }
        }
    }
}

#Preview {
    NavigationStack {
        PhotoGalleryView(userId: "test", userName: "João Silva")
    }
}
