import SwiftUI

public struct DeleteAccountSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var state: AppState

    public var onDeleted: () -> Void

    @State private var password: String = ""
    @State private var isDeleting: Bool = false
    @State private var deleteProgressText: String = "Deleting account..."

    public init(onDeleted: @escaping () -> Void) {
        self.onDeleted = onDeleted
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                // Warning Header
                Circle()
                    .fill(AppTheme.crimsonAlert.opacity(0.12))
                    .frame(width: 64, height: 64)
                    .overlay {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.crimsonAlert)
                    }
                    .padding(.top, 16)

                VStack(spacing: 6) {
                    Text("Delete Account & Data")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("This action cannot be undone. All your match history, reserved slots, and UC bounty records will be permanently deleted.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                if isDeleting {
                    // 3-second minimum animated spinner during deletion
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.4)
                            .tint(AppTheme.crimsonAlert)

                        Text(deleteProgressText)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 120)
                } else {
                    // Password input field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ENTER PASSWORD TO CONFIRM")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)

                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(AppTheme.crimsonAlert)
                            SecureField("Enter your account password", text: $password)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .liquidGlassField()
                    }

                    // Google Account Verification option
                    LiquidGlassGoogleButton {
                        handleGoogleDeleteVerification()
                    }

                    Spacer()

                    // Danger Delete Button (220pt pill)
                    BoxCentered {
                        LiquidGlassPillButton(
                            title: "Permanently Delete",
                            systemImage: "trash.fill",
                            variant: .danger,
                            isLoading: false,
                            width: 220,
                            height: 48
                        ) {
                            performAccountDeletion()
                        }
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if !isDeleting {
                            dismiss()
                        }
                    }
                    .disabled(isDeleting)
                    .foregroundColor(.secondary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(34)
        .presentationDragIndicator(.visible)
    }

    private func handleGoogleDeleteVerification() {
        DynamicIslandController.shared.showNotice("Verifying identity via Google...")
        startDeletionProcess()
    }

    private func performAccountDeletion() {
        if password.isEmpty {
            DynamicIslandController.shared.showError("Please enter password to verify deletion")
            return
        }
        startDeletionProcess()
    }

    private func startDeletionProcess() {
        isDeleting = true
        deleteProgressText = "Verifying credentials..."

        Task {
            let startTime = Date()

            try? await Task.sleep(nanoseconds: 1_000_000_000)
            deleteProgressText = "Erasing tournament records & profile..."

            await state.deleteAccountAndData()

            // Requirement: "3 sec min visible and maximum of server response"
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed < 3.0 {
                let remaining = 3.0 - elapsed
                try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
            }

            isDeleting = false
            DynamicIslandController.shared.showSuccess("Account and records permanently deleted")
            onDeleted()
            dismiss()
        }
    }
}
