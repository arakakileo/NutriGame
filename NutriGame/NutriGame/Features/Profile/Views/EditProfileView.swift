//
//  EditProfileView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EditProfileViewModel()

    @State private var name: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Avatar Editor
                    AvatarEditorView(
                        currentImageUrl: authViewModel.currentUser?.avatarUrl,
                        selectedImage: $selectedImage,
                        onSelectPhoto: { showingImagePicker = true }
                    )

                    // Name Field
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Nome")
                            .font(.caption)
                            .foregroundColor(.textSecondary)

                        TextField("Seu nome", text: $name)
                            .textContentType(.name)
                            .textInputAutocapitalization(.words)
                            .padding(Spacing.md)
                            .background(Color.bgSecondary)
                            .cornerRadius(CornerRadius.medium)
                    }
                    .padding(.horizontal, Spacing.lg)

                    // Info (read-only)
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Informações")
                            .font(.caption)
                            .foregroundColor(.textSecondary)

                        InfoRowReadOnly(label: "E-mail", value: authViewModel.currentUser?.email ?? "")
                        InfoRowReadOnly(label: "Membro desde", value: authViewModel.currentUser?.createdAt.fullDate ?? "")
                        InfoRowReadOnly(label: "Nível", value: "\(authViewModel.currentUser?.level ?? 1)")
                        InfoRowReadOnly(label: "XP Total", value: "\(authViewModel.currentUser?.totalXP ?? 0)")
                    }
                    .padding(.horizontal, Spacing.lg)

                    Spacer()
                }
                .padding(.top, Spacing.lg)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        saveProfile()
                    }
                    .disabled(!hasChanges || viewModel.isLoading)
                }
            }
            .loadingOverlay(viewModel.isLoading)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .onAppear {
                name = authViewModel.currentUser?.name ?? ""
            }
            .errorAlert(error: $viewModel.error)
        }
    }

    private var hasChanges: Bool {
        let nameChanged = name != authViewModel.currentUser?.name
        let imageChanged = selectedImage != nil
        return nameChanged || imageChanged
    }

    private func saveProfile() {
        guard let userId = authViewModel.currentUser?.id else { return }

        Task {
            let success = await viewModel.updateProfile(
                userId: userId,
                name: name.trimmed,
                newImage: selectedImage
            )
            if success {
                HapticManager.shared.success()
                dismiss()
            }
        }
    }
}

// MARK: - Avatar Editor View
struct AvatarEditorView: View {
    let currentImageUrl: String?
    @Binding var selectedImage: UIImage?
    let onSelectPhoto: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Avatar
            Group {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if let urlString = currentImageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        DefaultAvatarView()
                    }
                } else {
                    DefaultAvatarView()
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())

            // Edit button
            Button(action: onSelectPhoto) {
                ZStack {
                    Circle()
                        .fill(Color.accentPurple)
                        .frame(width: 36, height: 36)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
            }
            .offset(x: 4, y: 4)
        }
    }
}

struct DefaultAvatarView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.bgTertiary)

            Image(systemName: "person.fill")
                .font(.system(size: 40))
                .foregroundColor(.textTertiary)
        }
    }
}

// MARK: - Info Row Read Only
struct InfoRowReadOnly: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.bodyMedium)
                .foregroundColor(.textSecondary)

            Spacer()

            Text(value)
                .font(.bodyMedium)
                .foregroundColor(.textPrimary)
        }
        .padding(Spacing.md)
        .background(Color.bgSecondary)
        .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - View Model
@MainActor
final class EditProfileViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?

    private let userService = UserService.shared
    private let storageService = StorageService.shared

    func updateProfile(userId: String, name: String, newImage: UIImage?) async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            // Update avatar if changed
            var avatarUrl: String? = nil
            if let image = newImage {
                let url = try await storageService.uploadAvatar(userId: userId, image: image)
                avatarUrl = url.absoluteString
            }

            // Get current user and update
            var user = try await userService.getUser(id: userId)
            user.name = name
            if let newAvatarUrl = avatarUrl {
                user.avatarUrl = newAvatarUrl
            }

            try await userService.updateUser(user)
            return true
        } catch {
            self.error = error
            return false
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthViewModel())
}
