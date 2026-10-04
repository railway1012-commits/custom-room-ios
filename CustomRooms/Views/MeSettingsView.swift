import SwiftUI
import UIKit

public struct MeSettingsView: View {
    @EnvironmentObject var state: AppState
    @Binding public var selectedTab: MainTab
    @Environment(\.colorScheme) var colorScheme

    @State private var showAuthSheet = false
    @State private var showProfileSheet = false
    @State private var showDeleteVerifySheet = false
    @State private var showSupportSheet = false
    @State private var showFeedbackSheet = false
    @State private var showDiscordSheet = false
    @State private var showFaqSheet = false
    @State private var legalDocTitle: String? = nil

    @State private var isLoggingOut = false

    public var body: some View {
        NavigationStack {
            ZStack {
                (colorScheme == .dark ? AppTheme.darkBackground : AppTheme.lightBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Top title
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Me")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)

                                Text("Your gamer profile & app preferences")
                                    .font(.system(size: 13.5, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                        // Hero Profile Card
                        VStack(spacing: 14) {
                            Circle()
                                .fill(
                                    state.currentUser?.isOwner == true ? LinearGradient(colors: [AppTheme.amberGold, Color.orange], startPoint: .top, endPoint: .bottom) :
                                    state.currentUser != nil ? LinearGradient(colors: [AppTheme.royalBlue, Color.blue], startPoint: .top, endPoint: .bottom) :
                                    LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                                )
                                .frame(width: 80, height: 80)
                                .overlay {
                                    if let user = state.currentUser {
                                        Text(String(user.email.prefix(1)).uppercased())
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white)
                                    } else {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(.white)
                                    }
                                }
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)

                            VStack(spacing: 4) {
                                Text(state.currentUser?.email ?? "Guest Player")
                                    .font(.system(size: 19, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)

                                if let user = state.currentUser {
                                    Text(user.isOwner ? "👑 TOURNAMENT HOST" : "PLAYER")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(user.isOwner ? AppTheme.amberGold : AppTheme.royalBlue)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 3)
                                        .background(Capsule().fill(user.isOwner ? AppTheme.amberGold.opacity(0.12) : AppTheme.royalBlue.opacity(0.12)))
                                } else {
                                    Text("Sign in to reserve slots & earn UC bounties")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                            }

                            if state.currentUser != nil {
                                LiquidGlassPillButton(
                                    title: "Edit PUBG Profile",
                                    systemImage: "pencil",
                                    variant: .secondary,
                                    width: 180,
                                    height: 40
                                ) {
                                    showProfileSheet = true
                                }
                            } else {
                                LiquidGlassPillButton(
                                    title: "Sign In / Sign Up",
                                    systemImage: "person.fill",
                                    variant: .primary,
                                    width: 180,
                                    height: 40
                                ) {
                                    showAuthSheet = true
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(22)
                        .liquidGlassCard(cornerRadius: 26)
                        .padding(.horizontal, 18)

                        // Section 1: Gamer Identity
                        SettingsSectionView(title: "Gamer Identity") {
                            SettingsRowView(
                                icon: "gamecontroller.fill",
                                title: "Saved PUBG Profile",
                                subtitle: state.gamerProfile.defaultIgn.isEmpty ? "Set your IGN & UID for 1-tap entry" : "\(state.gamerProfile.defaultIgn) • UID: \(state.gamerProfile.defaultUid)",
                                tint: AppTheme.royalBlue
                            ) {
                                showProfileSheet = true
                            }
                        }

                        // Section 2: Preferences
                        SettingsSectionView(title: "Preferences") {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(AppTheme.amberGold)
                                    Text("Theme Mode")
                                        .font(.system(size: 14.5, weight: .semibold, design: .rounded))
                                }

                                LiquidGlassSegmentedPicker(
                                    options: AppThemeMode.allCases,
                                    selection: $state.themeMode,
                                    titleProvider: { $0.title }
                                )
                                .onChange(of: state.themeMode) { newMode in
                                    state.setTheme(newMode)
                                    DynamicIslandController.shared.showSuccess("Theme set to \(newMode.rawValue)")
                                }
                            }
                            .padding(.vertical, 8)

                            Divider().opacity(0.4)

                            Toggle(isOn: $state.liveSyncEnabled) {
                                HStack(spacing: 12) {
                                    Image(systemName: "bolt.fill")
                                        .foregroundColor(AppTheme.emeraldLive)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Real-Time Live Sync")
                                            .font(.system(size: 14.5, weight: .medium, design: .rounded))
                                        Text("Instant slot updates & kill payouts")
                                            .font(.system(size: 11.5))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .tint(AppTheme.emeraldLive)
                            .padding(.vertical, 4)

                            Divider().opacity(0.4)

                            Toggle(isOn: $state.hapticsEnabled) {
                                HStack(spacing: 12) {
                                    Image(systemName: "hand.tap.fill")
                                        .foregroundColor(Color.purple)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Tactile Spring Haptics")
                                            .font(.system(size: 14.5, weight: .medium, design: .rounded))
                                        Text("Vibrate on taps and slot selections")
                                            .font(.system(size: 11.5))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .tint(AppTheme.royalBlue)
                            .padding(.vertical, 4)
                        }

                        // Section 3: Help & Feedback
                        SettingsSectionView(title: "Help & Feedback") {
                            SettingsRowView(icon: "questionmark.circle.fill", title: "Customer Support", subtitle: "Official email assistance & dispute resolution", tint: Color.blue) {
                                showSupportSheet = true
                            }
                            Divider().opacity(0.4)
                            SettingsRowView(icon: "envelope.fill", title: "Send Feedback", subtitle: "Submit suggestions or report bugs", tint: AppTheme.emeraldLive) {
                                showFeedbackSheet = true
                            }
                            Divider().opacity(0.4)
                            SettingsRowView(icon: "bubble.left.and.bubble.right.fill", title: "Community Discord", subtitle: "Join 15,000+ competitive scrim players", tint: Color.indigo) {
                                showDiscordSheet = true
                            }
                            Divider().opacity(0.4)
                            SettingsRowView(icon: "info.circle.fill", title: "Frequently Asked Questions", subtitle: "Rules, slot locks, and UC payouts", tint: AppTheme.amberGold) {
                                showFaqSheet = true
                            }
                        }

                        // Section 4: Legal & Policies
                        SettingsSectionView(title: "Legal & Policies") {
                            SettingsRowView(icon: "shield.fill", title: "Privacy Policy", subtitle: "Security of your data and credentials", tint: Color.blue) {
                                legalDocTitle = "Privacy Policy"
                            }
                            Divider().opacity(0.4)
                            SettingsRowView(icon: "doc.text.fill", title: "Terms of Service", subtitle: "Platform rules & player guidelines", tint: Color.purple) {
                                legalDocTitle = "Terms of Service"
                            }
                            Divider().opacity(0.4)
                            SettingsRowView(icon: "scope", title: "Fair Play & Anti-Cheat Rules", subtitle: "Zero-tolerance hacking and emulator policies", tint: AppTheme.crimsonAlert) {
                                legalDocTitle = "Fair Play Rules"
                            }
                        }

                        // Section 5: Account Actions (Logged-in only!)
                        if state.currentUser != nil {
                            SettingsSectionView(title: "Account & Data") {
                                SettingsRowView(icon: "trash.fill", title: "Delete Account & Data", subtitle: "Permanently erase tournament records & profile", tint: AppTheme.crimsonAlert) {
                                    showDeleteVerifySheet = true
                                }
                            }

                            // Compact pill Log Out button
                            BoxCentered {
                                LiquidGlassPillButton(
                                    title: isLoggingOut ? "Logging out..." : "Log Out",
                                    systemImage: isLoggingOut ? nil : "rectangle.portrait.and.arrow.right",
                                    variant: .secondary,
                                    isLoading: isLoggingOut,
                                    width: 220,
                                    height: 48
                                ) {
                                    logOut()
                                }
                            }
                            .padding(.top, 4)
                        }

                        Spacer(minLength: 120)
                    }
                }
            }
        }
        .sheet(isPresented: $showAuthSheet) { AuthSheetView() }
        .sheet(isPresented: $showProfileSheet) { GamerProfileSheetView() }
        .sheet(isPresented: $showDeleteVerifySheet) { DeleteAccountSheetView(onDeleted: { selectedTab = .rooms }) }
        .sheet(isPresented: $showSupportSheet) { SupportSheetView() }
        .sheet(isPresented: $showFeedbackSheet) { FeedbackSheetView() }
        .sheet(isPresented: $showDiscordSheet) { DiscordSheetView() }
        .sheet(isPresented: $showFaqSheet) { FaqSheetView() }
        .sheet(item: Binding(get: { legalDocTitle.map { IdentifiableString(id: $0) } }, set: { legalDocTitle = $0?.id })) { item in
            LegalDocSheetView(title: item.id)
        }
    }

    private func logOut() {
        Task {
            isLoggingOut = true
            let startTime = Date()
            await state.logout()
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed < 1.5 {
                try? await Task.sleep(nanoseconds: UInt64((1.5 - elapsed) * 1_000_000_000))
            }
            isLoggingOut = false
            DynamicIslandController.shared.showSuccess("Logged out successfully")
            selectedTab = .rooms
        }
    }
}

public struct IdentifiableString: Identifiable {
    public let id: String
}

public struct SettingsSectionView<Content: View>: View {
    public var title: String
    @ViewBuilder public var content: () -> Content

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11.5, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            .padding(16)
            .liquidGlassCard(cornerRadius: 22)
            .padding(.horizontal, 18)
        }
    }
}

public struct SettingsRowView: View {
    public var icon: String
    public var title: String
    public var subtitle: String?
    public var tint: Color
    public var action: () -> Void

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Circle()
                    .fill(tint.opacity(0.14))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(tint)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14.5, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
