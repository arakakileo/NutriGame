//
//  ToastView.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import SwiftUI

// MARK: - Toast Type
enum ToastType {
    case success
    case error
    case warning
    case info

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return .accentGreen
        case .error: return .error
        case .warning: return .warning
        case .info: return .accentPurple
        }
    }

    var backgroundColor: Color {
        switch self {
        case .success: return .accentGreen.opacity(0.15)
        case .error: return .error.opacity(0.15)
        case .warning: return .warning.opacity(0.15)
        case .info: return .accentPurple.opacity(0.15)
        }
    }
}

// MARK: - Toast Data
struct ToastData: Identifiable, Equatable {
    let id = UUID()
    let type: ToastType
    let title: String
    let message: String?
    let duration: TimeInterval

    init(
        type: ToastType,
        title: String,
        message: String? = nil,
        duration: TimeInterval = 3.0
    ) {
        self.type = type
        self.title = title
        self.message = message
        self.duration = duration
    }

    static func == (lhs: ToastData, rhs: ToastData) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Toast View
struct ToastView: View {
    let toast: ToastData
    let onDismiss: () -> Void

    @State private var isVisible = false

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon
            Image(systemName: toast.type.icon)
                .font(.system(size: 20))
                .foregroundColor(toast.type.color)

            // Text
            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text(toast.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textPrimary)

                if let message = toast.message {
                    Text(message)
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            // Dismiss button
            Button(action: dismissToast) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .fill(Color.bgSecondary)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .stroke(toast.type.color.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, Spacing.md)
        .offset(y: isVisible ? 0 : -100)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            showToast()
        }
    }

    private func showToast() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isVisible = true
        }

        // Auto dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
            dismissToast()
        }
    }

    private func dismissToast() {
        withAnimation(.easeIn(duration: 0.2)) {
            isVisible = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}

// MARK: - Toast Manager
@MainActor
final class ToastManager: ObservableObject {
    static let shared = ToastManager()

    @Published var currentToast: ToastData?
    private var toastQueue: [ToastData] = []

    private init() {}

    func show(_ toast: ToastData) {
        if currentToast == nil {
            currentToast = toast
            triggerHaptic(for: toast.type)
        } else {
            toastQueue.append(toast)
        }
    }

    func show(
        type: ToastType,
        title: String,
        message: String? = nil,
        duration: TimeInterval = 3.0
    ) {
        show(ToastData(type: type, title: title, message: message, duration: duration))
    }

    func dismiss() {
        currentToast = nil
        showNextToast()
    }

    private func showNextToast() {
        guard !toastQueue.isEmpty else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentToast = self.toastQueue.removeFirst()
            self.triggerHaptic(for: self.currentToast?.type ?? .info)
        }
    }

    private func triggerHaptic(for type: ToastType) {
        switch type {
        case .success:
            HapticManager.shared.success()
        case .error:
            HapticManager.shared.errorOccurred()
        case .warning:
            HapticManager.shared.warning()
        case .info:
            HapticManager.shared.buttonTap()
        }
    }

    // Convenience methods
    func success(_ title: String, message: String? = nil) {
        show(type: .success, title: title, message: message)
    }

    func error(_ title: String, message: String? = nil) {
        show(type: .error, title: title, message: message)
    }

    func warning(_ title: String, message: String? = nil) {
        show(type: .warning, title: title, message: message)
    }

    func info(_ title: String, message: String? = nil) {
        show(type: .info, title: title, message: message)
    }
}

// MARK: - Toast Container View
struct ToastContainerView<Content: View>: View {
    @StateObject private var toastManager = ToastManager.shared
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .top) {
            content

            if let toast = toastManager.currentToast {
                ToastView(toast: toast) {
                    toastManager.dismiss()
                }
                .zIndex(999)
                .padding(.top, Spacing.lg)
            }
        }
    }
}

// MARK: - View Extension
extension View {
    func toastContainer() -> some View {
        ToastContainerView {
            self
        }
    }
}

// MARK: - Snackbar View (Alternative Toast at Bottom)
struct SnackbarView: View {
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    @Binding var isVisible: Bool

    init(
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        isVisible: Binding<Bool>
    ) {
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
        self._isVisible = isVisible
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(message)
                .font(.bodySmall)
                .foregroundColor(.white)

            Spacer()

            if let title = actionTitle, let action = action {
                Button(action: {
                    action()
                    withAnimation {
                        isVisible = false
                    }
                }) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.accentGreen)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color(.darkGray))
        .cornerRadius(CornerRadius.medium)
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.lg)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear {
            // Auto dismiss after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation {
                    isVisible = false
                }
            }
        }
    }
}

// MARK: - Snackbar Modifier
struct SnackbarModifier: ViewModifier {
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    @Binding var isVisible: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content

            if isVisible {
                SnackbarView(
                    message: message,
                    actionTitle: actionTitle,
                    action: action,
                    isVisible: $isVisible
                )
            }
        }
    }
}

extension View {
    func snackbar(
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        isVisible: Binding<Bool>
    ) -> some View {
        modifier(SnackbarModifier(
            message: message,
            actionTitle: actionTitle,
            action: action,
            isVisible: isVisible
        ))
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showSnackbar = false

        var body: some View {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                VStack(spacing: Spacing.lg) {
                    Button("Success Toast") {
                        ToastManager.shared.success("Missão completada!", message: "+50 XP")
                    }
                    .primaryButtonStyle()

                    Button("Error Toast") {
                        ToastManager.shared.error("Erro ao salvar", message: "Tente novamente")
                    }
                    .secondaryButtonStyle()

                    Button("Warning Toast") {
                        ToastManager.shared.warning("Atenção!", message: "Seu streak está em risco")
                    }
                    .secondaryButtonStyle(color: .warning)

                    Button("Info Toast") {
                        ToastManager.shared.info("Dica", message: "Complete todas as missões para o bônus")
                    }
                    .secondaryButtonStyle()

                    Button("Show Snackbar") {
                        showSnackbar = true
                    }
                    .tertiaryButtonStyle()
                }
                .padding()
            }
            .toastContainer()
            .snackbar(
                message: "Foto salva na galeria",
                actionTitle: "Ver",
                action: { print("View gallery") },
                isVisible: $showSnackbar
            )
        }
    }

    return PreviewWrapper()
}
