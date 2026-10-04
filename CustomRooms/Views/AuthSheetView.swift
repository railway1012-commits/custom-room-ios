import SwiftUI

public struct AuthSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var state: AppState

    @State private var isSignUp: Bool = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.clear

                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 6) {
                        Text(isSignUp ? "Create Player Account" : "Welcome Back")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Text(isSignUp ? "Join PUBG tournaments, track UC bounties & sync across devices" : "Sign in to manage your registrations and tournament results")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)

                    // Mode switch
                    LiquidGlassSegmentedPicker(
                        options: [false, true],
                        selection: $isSignUp,
                        titleProvider: { $0 ? "Create Account" : "Sign In" }
                    )

                    // Form inputs (All pill shaped)
                    VStack(spacing: 14) {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(AppTheme.royalBlue)
                            TextField("Email address", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .liquidGlassField()

                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(AppTheme.royalBlue)
                            SecureField("Password (min 6 characters)", text: $password)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .liquidGlassField()

                        if isSignUp {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(AppTheme.emeraldLive)
                                SecureField("Confirm Password", text: $confirmPassword)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .liquidGlassField()
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }

                    // Primary Action Button (220pt pill button)
                    BoxCentered {
                        LiquidGlassPillButton(
                            title: isSignUp ? "Create Account" : "Sign In",
                            systemImage: isSignUp ? "person.badge.plus" : "arrow.right.circle.fill",
                            variant: .primary,
                            isLoading: isLoading,
                            width: 220,
                            height: 48
                        ) {
                            submitAuth()
                        }
                    }

                    // Divider
                    HStack {
                        Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                        Text("OR").font(.system(size: 11, weight: .bold)).foregroundColor(.secondary)
                        Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                    }

                    // Google Sign-In
                    LiquidGlassGoogleButton {
                        DynamicIslandController.shared.showNotice("Google Sign-In ready")
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        clearForm()
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .onDisappear {
                // Ensure credentials are cleared upon dismiss so no lingering text remains
                clearForm()
            }
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(34)
        .presentationDragIndicator(.visible)
    }

    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
    }

    private func submitAuth() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            DynamicIslandController.shared.showError("Please enter email and password")
            return
        }

        if isSignUp && password != confirmPassword {
            DynamicIslandController.shared.showError("Passwords do not match")
            return
        }

        Task {
            isLoading = true
            do {
                if isSignUp {
                    try await state.signup(email: trimmedEmail, pass: password)
                    DynamicIslandController.shared.showSuccess("Account created successfully!")
                } else {
                    try await state.login(email: trimmedEmail, pass: password)
                    DynamicIslandController.shared.showSuccess("Signed in successfully!")
                }
                isLoading = false
                clearForm()
                dismiss()
            } catch {
                isLoading = false
                DynamicIslandController.shared.showError(error.localizedDescription)
            }
        }
    }
}
