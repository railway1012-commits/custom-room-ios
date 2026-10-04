import SwiftUI

public struct SetupWizardView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) var systemColorScheme

    @State private var currentStep: Int = 1
    
    // Auth Step 2
    @State private var authMode: AuthMode = .signIn
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isAuthLoading: Bool = false
    
    // Gamer Identity Step 3
    @State private var ign: String = ""
    @State private var uid: String = ""
    @State private var squad: String = ""
    @State private var discord: String = ""

    // Preferences Step 4
    @State private var selectedTheme: AppThemeMode = .light
    @State private var hapticsOn: Bool = true
    @State private var liveSyncOn: Bool = true

    enum AuthMode {
        case signIn
        case signUp
    }

    public init() {}

    public var body: some View {
        ZStack {
            // Background according to selected theme preview
            themeBackground
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.25), value: selectedTheme)

            VStack(spacing: 0) {
                // Top Header with Step indicator and optional Back button
                topBar
                    .padding(.top, 16)
                    .padding(.horizontal, 24)

                // Step Content in ScrollView with Keyboard Avoidance
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 24) {
                            switch currentStep {
                            case 1:
                                step1WelcomeView
                            case 2:
                                step2AuthView
                            case 3:
                                step3GamerIdentityView
                            case 4:
                                step4PreferencesView
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                }

                Spacer()

                // Persistent Bottom Navigation Area (Consistent Button Placement & Width)
                bottomActionBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            selectedTheme = state.themeMode
            ign = state.gamerProfile.defaultIgn
            uid = state.gamerProfile.defaultUid
            squad = state.gamerProfile.defaultSquad
            discord = state.gamerProfile.defaultDiscord
            hapticsOn = state.hapticsEnabled
            liveSyncOn = state.liveSyncEnabled
        }
    }

    // MARK: - Background
    @ViewBuilder
    private var themeBackground: some View {
        switch selectedTheme {
        case .dark:
            AppTheme.darkBackground
        case .light:
            AppTheme.lightBackground
        case .system:
            if systemColorScheme == .dark {
                AppTheme.darkBackground
            } else {
                AppTheme.lightBackground
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            if currentStep > 1 {
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        currentStep -= 1
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                        Text("Back")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.royalBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .liquidGlassCard(cornerRadius: 16)
                }
            } else {
                Spacer().frame(width: 70)
            }

            Spacer()

            // Step Indicator dots
            HStack(spacing: 8) {
                ForEach(1...4, id: \.self) { step in
                    Capsule()
                        .fill(step == currentStep ? AppTheme.royalBlue : Color.gray.opacity(0.3))
                        .frame(width: step == currentStep ? 22 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: currentStep)
                }
            }

            Spacer()

            // Step 1 NEVER has a skip button (user requested: "when user is in first step why there is a skip button here it should nt be")
            if currentStep >= 2 {
                Button(action: {
                    skipAllSetup()
                }) {
                    Text("Skip All")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
            } else {
                Spacer().frame(width: 70)
            }
        }
    }

    // MARK: - Step 1: Welcome & Overview
    private var step1WelcomeView: some View {
        VStack(spacing: 24) {
            // Hero Icon
            ZStack {
                Circle()
                    .fill(AppTheme.royalBlue.opacity(0.12))
                    .frame(width: 110, height: 110)

                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.royalBlue, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.top, 10)

            VStack(spacing: 8) {
                Text("Synch Arena")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)

                Text("PUBG Scrims & Tournament Platform")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 16) {
                featureBullet(
                    icon: "flame.fill",
                    tint: AppTheme.amberGold,
                    title: "Live Scrim Tracking",
                    desc: "Real-time slot reservations with instant live room updates."
                )

                featureBullet(
                    icon: "key.fill",
                    tint: AppTheme.royalBlue,
                    title: "Instant Room Key Access",
                    desc: "Room ID & password reveal instantly when the host broadcasts."
                )

                featureBullet(
                    icon: "trophy.fill",
                    tint: AppTheme.emeraldLive,
                    title: "UC Prize Pool Bounties",
                    desc: "Compete, earn UC rewards, and track your match statistics."
                )
            }
            .padding(18)
            .liquidGlassCard(cornerRadius: 24)
        }
    }

    private func featureBullet(icon: String, tint: Color, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(tint.opacity(0.14))
                .frame(width: 38, height: 38)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(tint)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(desc)
                    .font(.system(size: 12.5))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }

    // MARK: - Step 2: Sign In / Create Account
    private var step2AuthView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text(authMode == .signIn ? "Player Sign In" : "Create Gamer Account")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Sync your match registrations and tournament stats across all devices")
                    .font(.system(size: 13.5))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Mode Selector
            LiquidGlassSegmentedPicker(
                options: ["Sign In", "Create Account"],
                selectedIndex: Binding(
                    get: { authMode == .signIn ? 0 : 1 },
                    set: { authMode = $0 == 0 ? .signIn : .signUp }
                )
            )

            VStack(spacing: 14) {
                // Email field
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

                // Password field
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(AppTheme.royalBlue)
                    SecureField("Password (min 6 chars)", text: $password)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .liquidGlassField()
            }

            // Google Sign In option
            LiquidGlassGoogleButton {
                DynamicIslandController.shared.showNotice("Google Sign-In integration ready")
            }

            Text("Or continue as a guest player without creating an account now")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Step 3: Gamer Identity
    private var step3GamerIdentityView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text("Gamer Identity")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Auto-fill your slot registrations so you never miss a room drop")
                    .font(.system(size: 13.5))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 14) {
                // In-Game Name
                HStack(spacing: 12) {
                    Image(systemName: "person.fill")
                        .foregroundColor(AppTheme.royalBlue)
                    TextField("PUBG In-Game Name (IGN)*", text: $ign)
                        .textInputAutocapitalization(.words)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .liquidGlassField()

                // Character UID
                HStack(spacing: 12) {
                    Image(systemName: "number")
                        .foregroundColor(AppTheme.amberGold)
                    TextField("Character UID (Numbers only)*", text: $uid)
                        .keyboardType(.numberPad)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .liquidGlassField()

                // Squad Name
                HStack(spacing: 12) {
                    Image(systemName: "shield.fill")
                        .foregroundColor(AppTheme.emeraldLive)
                    TextField("Squad / Clan Tag (Optional)", text: $squad)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .liquidGlassField()

                // Discord Handle
                HStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .foregroundColor(AppTheme.royalBlue)
                    TextField("Discord Username (Optional)", text: $discord)
                        .textInputAutocapitalization(.never)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .liquidGlassField()
            }

            Text("These credentials stay on your device and auto-populate tournament signup forms.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Step 4: Preferences (Applied Instantly)
    private var step4PreferencesView: some View {
        VStack(spacing: 22) {
            VStack(spacing: 6) {
                Text("App Preferences")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Theme, tactile feedback and live updates apply instantly")
                    .font(.system(size: 13.5))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Theme selector with instant apply
            VStack(alignment: .leading, spacing: 10) {
                Text("APPEARANCE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)

                LiquidGlassSegmentedPicker(
                    options: ["Light", "Dark", "System"],
                    selectedIndex: Binding(
                        get: {
                            switch selectedTheme {
                            case .light: return 0
                            case .dark: return 1
                            case .system: return 2
                            }
                        },
                        set: {
                            let newTheme: AppThemeMode
                            switch $0 {
                            case 0: newTheme = .light
                            case 1: newTheme = .dark
                            default: newTheme = .system
                            }
                            selectedTheme = newTheme
                            state.setTheme(newTheme)
                        }
                    )
                )
            }

            // Accessibility & Features
            VStack(spacing: 14) {
                Toggle(isOn: $hapticsOn) {
                    HStack(spacing: 12) {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(AppTheme.royalBlue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Haptic Feedback")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                            Text("Tactile clicks when pressing buttons & switching tabs")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .tint(AppTheme.royalBlue)
                .onChange(of: hapticsOn) { newValue in
                    state.hapticsEnabled = newValue
                    UserDefaults.standard.set(newValue, forKey: "haptics_enabled")
                }

                Divider().opacity(0.4)

                Toggle(isOn: $liveSyncOn) {
                    HStack(spacing: 12) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .foregroundColor(AppTheme.emeraldLive)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Live Scrim Refresh")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                            Text("Poll room status and credentials in the background")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .tint(AppTheme.royalBlue)
                .onChange(of: liveSyncOn) { newValue in
                    state.liveSyncEnabled = newValue
                    UserDefaults.standard.set(newValue, forKey: "live_sync_enabled")
                }
            }
            .padding(16)
            .liquidGlassCard(cornerRadius: 20)
        }
    }

    // MARK: - Consistent Bottom Action Bar
    private var bottomActionBar: some View {
        HStack {
            Spacer()
            
            LiquidGlassPillButton(
                title: actionButtonTitle,
                systemImage: actionButtonIcon,
                variant: .primary,
                isLoading: isAuthLoading,
                width: 220,
                height: 50
            ) {
                handleNextAction()
            }
            
            Spacer()
        }
    }

    private var actionButtonTitle: String {
        switch currentStep {
        case 1:
            return "Get Started"
        case 2:
            return authMode == .signIn ? "Sign In & Continue" : "Create & Continue"
        case 3:
            return "Save & Continue"
        case 4:
            return "Finish Setup"
        default:
            return "Next"
        }
    }

    private var actionButtonIcon: String? {
        switch currentStep {
        case 1:
            return "arrow.right"
        case 2:
            return isAuthLoading ? nil : "arrow.right"
        case 3:
            return "arrow.right"
        case 4:
            return "checkmark"
        default:
            return "arrow.right"
        }
    }

    private func handleNextAction() {
        switch currentStep {
        case 1:
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentStep = 2
            }
        case 2:
            if !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty {
                // Perform auth
                Task {
                    isAuthLoading = true
                    do {
                        if authMode == .signIn {
                            try await state.login(email: email.trimmingCharacters(in: .whitespaces), pass: password)
                            DynamicIslandController.shared.showSuccess("Welcome back!")
                        } else {
                            try await state.signup(email: email.trimmingCharacters(in: .whitespaces), pass: password)
                            DynamicIslandController.shared.showSuccess("Account created!")
                        }
                        isAuthLoading = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            currentStep = 3
                        }
                    } catch {
                        isAuthLoading = false
                        DynamicIslandController.shared.showError(error.localizedDescription)
                    }
                }
            } else {
                // Continued as guest
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    currentStep = 3
                }
            }
        case 3:
            let profile = GamerProfile(
                defaultIgn: ign.trimmingCharacters(in: .whitespaces),
                defaultUid: uid.trimmingCharacters(in: .whitespaces),
                defaultDiscord: discord.trimmingCharacters(in: .whitespaces),
                defaultSquad: squad.trimmingCharacters(in: .whitespaces)
            )
            state.saveProfile(profile)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentStep = 4
            }
        case 4:
            // Finish Setup - persist everything and dismiss forever
            let profile = GamerProfile(
                defaultIgn: ign.trimmingCharacters(in: .whitespaces),
                defaultUid: uid.trimmingCharacters(in: .whitespaces),
                defaultDiscord: discord.trimmingCharacters(in: .whitespaces),
                defaultSquad: squad.trimmingCharacters(in: .whitespaces)
            )
            state.completeSetup(profile: profile, theme: selectedTheme)
            DynamicIslandController.shared.showSuccess("Welcome to Synch Arena!")
        default:
            break
        }
    }

    private func skipAllSetup() {
        let profile = GamerProfile(
            defaultIgn: ign.trimmingCharacters(in: .whitespaces),
            defaultUid: uid.trimmingCharacters(in: .whitespaces),
            defaultDiscord: discord.trimmingCharacters(in: .whitespaces),
            defaultSquad: squad.trimmingCharacters(in: .whitespaces)
        )
        state.completeSetup(profile: profile, theme: selectedTheme)
        DynamicIslandController.shared.showNotice("Setup skipped. Configure anytime in Me tab.")
    }
}
