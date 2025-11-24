//
//  ErrorView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

// MARK: - Error View
struct ErrorView: View {
    let title: String
    let message: String
    let icon: String
    let retryAction: (() -> Void)?
    let dismissAction: (() -> Void)?

    init(
        title: String = "Ops! Algo deu errado",
        message: String = "Não foi possível completar a operação. Tente novamente.",
        icon: String = "exclamationmark.triangle.fill",
        retryAction: (() -> Void)? = nil,
        dismissAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.retryAction = retryAction
        self.dismissAction = dismissAction
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.error)

            // Text
            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.titleSmall)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Actions
            VStack(spacing: Spacing.md) {
                if let retry = retryAction {
                    PrimaryButton("Tentar novamente", action: retry)
                }

                if let dismiss = dismissAction {
                    Button("Voltar") {
                        dismiss()
                    }
                    .tertiaryButtonStyle()
                }
            }
            .padding(.top, Spacing.md)
        }
        .padding(Spacing.xl)
    }
}

// MARK: - Network Error View
struct NetworkErrorView: View {
    let onRetry: () -> Void

    var body: some View {
        ErrorView(
            title: "Sem conexão",
            message: "Verifique sua conexão com a internet e tente novamente.",
            icon: "wifi.slash",
            retryAction: onRetry
        )
    }
}

// MARK: - Server Error View
struct ServerErrorView: View {
    let onRetry: () -> Void

    var body: some View {
        ErrorView(
            title: "Erro no servidor",
            message: "Estamos com problemas técnicos. Tente novamente em alguns minutos.",
            icon: "server.rack",
            retryAction: onRetry
        )
    }
}

// MARK: - Permission Error View
struct PermissionErrorView: View {
    let permissionType: PermissionType
    let onOpenSettings: () -> Void

    enum PermissionType {
        case camera
        case notifications
        case photos

        var title: String {
            switch self {
            case .camera: return "Acesso à Câmera"
            case .notifications: return "Notificações"
            case .photos: return "Acesso às Fotos"
            }
        }

        var message: String {
            switch self {
            case .camera:
                return "O NutriGame precisa de acesso à câmera para você registrar suas refeições."
            case .notifications:
                return "Ative as notificações para não perder seus lembretes de missões."
            case .photos:
                return "O NutriGame precisa de acesso às fotos para salvar suas refeições."
            }
        }

        var icon: String {
            switch self {
            case .camera: return "camera.fill"
            case .notifications: return "bell.fill"
            case .photos: return "photo.fill"
            }
        }
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: permissionType.icon)
                .font(.system(size: 64))
                .foregroundColor(.warning)

            VStack(spacing: Spacing.sm) {
                Text(permissionType.title)
                    .font(.titleSmall)
                    .foregroundColor(.textPrimary)

                Text(permissionType.message)
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            PrimaryButton("Abrir Configurações") {
                onOpenSettings()
            }
            .padding(.top, Spacing.md)
        }
        .padding(Spacing.xl)
    }
}

// MARK: - Inline Error
struct InlineError: View {
    let message: String
    let onDismiss: (() -> Void)?

    init(message: String, onDismiss: (() -> Void)? = nil) {
        self.message = message
        self.onDismiss = onDismiss
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.error)

            Text(message)
                .font(.bodySmall)
                .foregroundColor(.error)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            if let dismiss = onDismiss {
                Button(action: dismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.error)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.error.opacity(0.1))
        .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - Error Banner
struct ErrorBanner: View {
    let message: String
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.white)

                Text(message)
                    .font(.bodySmall)
                    .foregroundColor(.white)
                    .lineLimit(2)

                Spacer()

                Button(action: {
                    withAnimation {
                        isVisible = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(Spacing.md)
            .background(Color.error)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Error Alert Modifier
struct ErrorAlertModifier: ViewModifier {
    let error: Error?
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .alert("Erro", isPresented: $isPresented) {
                Button("OK") {
                    onDismiss?()
                }
            } message: {
                Text(error?.localizedDescription ?? "Ocorreu um erro inesperado.")
            }
    }
}

extension View {
    func errorAlert(
        error: Error?,
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(ErrorAlertModifier(error: error, isPresented: isPresented, onDismiss: onDismiss))
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Spacing.xxl) {
            // Generic error
            ErrorView(
                retryAction: { print("Retry") },
                dismissAction: { print("Dismiss") }
            )

            Divider()

            // Network error
            NetworkErrorView(onRetry: { print("Retry") })

            Divider()

            // Permission error
            PermissionErrorView(
                permissionType: .camera,
                onOpenSettings: { print("Settings") }
            )

            Divider()

            // Inline error
            InlineError(message: "Código inválido. Verifique e tente novamente.") {
                print("Dismiss")
            }

            // Error banner
            ErrorBanner(message: "Falha ao salvar. Tente novamente.", isVisible: .constant(true))
        }
        .padding()
    }
    .background(Color.bgPrimary)
}
