import SwiftUI
import Combine

@MainActor
public class AppState: ObservableObject {
    @Published public var rooms: [Room] = []
    @Published public var signups: [Signup] = []
    @Published public var currentUser: User?
    @Published public var gamerProfile: GamerProfile
    @Published public var themeMode: AppThemeMode
    @Published public var isSetupCompleted: Bool
    @Published public var hapticsEnabled: Bool
    @Published public var liveSyncEnabled: Bool
    @Published public var isLoading: Bool = false

    private let defaults = UserDefaults.standard

    public init() {
        // Load setup completed state
        self.isSetupCompleted = defaults.bool(forKey: "setup_completed")

        // Load theme mode
        let savedTheme = defaults.string(forKey: "theme_mode") ?? "LIGHT"
        self.themeMode = AppThemeMode(rawValue: savedTheme) ?? .light

        // Load gamer profile
        self.gamerProfile = GamerProfile(
            defaultIgn: defaults.string(forKey: "gamer_ign") ?? "",
            defaultUid: defaults.string(forKey: "gamer_uid") ?? "",
            defaultDiscord: defaults.string(forKey: "gamer_discord") ?? "",
            defaultSquad: defaults.string(forKey: "gamer_squad") ?? ""
        )

        self.hapticsEnabled = defaults.object(forKey: "haptics_enabled") as? Bool ?? true
        self.liveSyncEnabled = defaults.object(forKey: "live_sync_enabled") as? Bool ?? true

        // Load saved user
        if let email = defaults.string(forKey: "user_email"),
           let id = defaults.string(forKey: "user_id") {
            let role = defaults.string(forKey: "user_role") ?? "user"
            self.currentUser = User(id: id, email: email, role: role)
        }
    }

    public func refreshData() async {
        isLoading = true
        do {
            async let fetchedRooms = APIClient.shared.fetchRooms()
            async let fetchedSignups = APIClient.shared.fetchSignups()
            let (r, s) = try await (fetchedRooms, fetchedSignups)
            self.rooms = r
            self.signups = s
        } catch {
            print("Failed to fetch: \(error)")
        }
        isLoading = false
    }

    public func saveProfile(_ profile: GamerProfile) {
        self.gamerProfile = profile
        defaults.set(profile.defaultIgn, forKey: "gamer_ign")
        defaults.set(profile.defaultUid, forKey: "gamer_uid")
        defaults.set(profile.defaultDiscord, forKey: "gamer_discord")
        defaults.set(profile.defaultSquad, forKey: "gamer_squad")
    }

    public func setTheme(_ mode: AppThemeMode) {
        self.themeMode = mode
        defaults.set(mode.rawValue, forKey: "theme_mode")
    }

    public func completeSetup(profile: GamerProfile, theme: AppThemeMode) {
        saveProfile(profile)
        setTheme(theme)
        self.isSetupCompleted = true
        defaults.set(true, forKey: "setup_completed")
    }

    public func skipSetup() {
        self.isSetupCompleted = true
        defaults.set(true, forKey: "setup_completed")
    }

    public func login(email: String, pass: String) async throws {
        let user = try await APIClient.shared.login(email: email, pass: pass)
        self.currentUser = user
        defaults.set(user.id, forKey: "user_id")
        defaults.set(user.email, forKey: "user_email")
        defaults.set(user.role, forKey: "user_role")
    }

    public func signup(email: String, pass: String) async throws {
        let user = try await APIClient.shared.signup(email: email, pass: pass)
        self.currentUser = user
        defaults.set(user.id, forKey: "user_id")
        defaults.set(user.email, forKey: "user_email")
        defaults.set(user.role, forKey: "user_role")
    }

    public func logout() async {
        try? await APIClient.shared.logout()
        self.currentUser = nil
        defaults.removeObject(forKey: "user_id")
        defaults.removeObject(forKey: "user_email")
        defaults.removeObject(forKey: "user_role")
    }

    public func deleteAccountAndData() async {
        try? await APIClient.shared.logout()
        self.currentUser = nil
        defaults.removeObject(forKey: "user_id")
        defaults.removeObject(forKey: "user_email")
        defaults.removeObject(forKey: "user_role")
        // Setup completion is ALWAYS preserved
        defaults.set(true, forKey: "setup_completed")
        self.isSetupCompleted = true
        await refreshData()
    }
}
