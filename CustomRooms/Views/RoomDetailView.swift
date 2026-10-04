import SwiftUI
import UIKit

public struct RoomDetailView: View {
    public var room: Room
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var ign: String = ""
    @State private var uid: String = ""
    @State private var discord: String = ""
    @State private var squad: String = ""
    @State private var isSubmitting: Bool = false

    public var body: some View {
        NavigationStack {
            ZStack {
                (colorScheme == .dark ? AppTheme.darkBackground : AppTheme.lightBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Room Banner Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(room.mode.uppercased())
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.royalBlue)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(AppTheme.royalBlue.opacity(0.12)))

                                Spacer()

                                Text("\(Int(room.ucPerKill)) UC / KILL")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.amberGold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(AppTheme.amberGold.opacity(0.12)))
                            }

                            Text(room.title)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)

                            // Capacity
                            let signups = state.signups.filter { $0.roomId == room.id }
                            Text("\(signups.count) of \(room.maxPlayers) slots confirmed")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(20)
                        .liquidGlassCard(cornerRadius: 24)

                        // Credentials Card (if revealed)
                        if room.revealDetails, let rid = room.roomId, let rpass = room.roomPassword {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "key.fill")
                                        .foregroundColor(AppTheme.emeraldLive)
                                    Text("Match Credentials")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                    Spacer()
                                }

                                HStack(spacing: 12) {
                                    CredentialBox(label: "Room ID", value: rid)
                                    CredentialBox(label: "Password", value: rpass)
                                }
                            }
                            .padding(18)
                            .liquidGlassCard(cornerRadius: 22)
                        }

                        // Registration Form
                        let mySignup = state.signups.first { $0.roomId == room.id && $0.createdById == (state.currentUser?.id ?? "") }
                        if let mySignup = mySignup {
                            // Already registered
                            VStack(spacing: 10) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(AppTheme.emeraldLive)
                                Text("You are Registered!")
                                    .font(.system(size: 18, weight: .bold))
                                Text("IGN: \(mySignup.ign) • UID: \(mySignup.uid)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(24)
                            .liquidGlassCard(cornerRadius: 24)
                        } else {
                            // Join Match Form
                            VStack(spacing: 14) {
                                HStack {
                                    Text("Join Match")
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                    Spacer()
                                    if !state.gamerProfile.defaultIgn.isEmpty {
                                        Button(action: {
                                            ign = state.gamerProfile.defaultIgn
                                            uid = state.gamerProfile.defaultUid
                                            discord = state.gamerProfile.defaultDiscord
                                            squad = state.gamerProfile.defaultSquad
                                            DynamicIslandController.shared.showInfo("Autofilled from PUBG Profile")
                                        }) {
                                            Text("⚡ Autofill")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(AppTheme.royalBlue)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(Capsule().fill(AppTheme.royalBlue.opacity(0.12)))
                                        }
                                    }
                                }

                                LiquidGlassTextField(text: $ign, label: "PUBG In-Game Name (IGN) *", placeholder: "e.g. Mortal_Sniper", systemImage: "person.fill")
                                LiquidGlassTextField(text: $uid, label: "PUBG Numeric UID *", placeholder: "e.g. 5183920194", systemImage: "number", isNumeric: true)
                                LiquidGlassTextField(text: $discord, label: "Discord Handle (Optional)", placeholder: "e.g. mortal#1234", systemImage: "bubble.left.and.bubble.right.fill")
                                LiquidGlassTextField(text: $squad, label: "Squad Name (Optional)", placeholder: "e.g. Team Soul", systemImage: "shield.fill")

                                BoxCentered {
                                    LiquidGlassPillButton(
                                        title: "Register for Room",
                                        systemImage: "checkmark",
                                        isLoading: isSubmitting,
                                        isEnabled: !ign.trimmingCharacters(in: .whitespaces).isEmpty && !uid.trimmingCharacters(in: .whitespaces).isEmpty,
                                        width: 220,
                                        height: 48
                                    ) {
                                        register()
                                    }
                                }
                                .padding(.top, 6)
                            }
                            .padding(20)
                            .liquidGlassCard(cornerRadius: 24)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                }
            }
            .navigationTitle("Match Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppTheme.royalBlue)
                }
            }
        }
        .onAppear {
            if !state.gamerProfile.defaultIgn.isEmpty {
                ign = state.gamerProfile.defaultIgn
                uid = state.gamerProfile.defaultUid
                discord = state.gamerProfile.defaultDiscord
                squad = state.gamerProfile.defaultSquad
            }
        }
    }

    private func register() {
        Task {
            isSubmitting = true
            let startTime = Date()
            do {
                _ = try await APIClient.shared.createSignup(
                    roomId: room.id,
                    ign: ign.trimmingCharacters(in: .whitespaces),
                    uid: uid.trimmingCharacters(in: .whitespaces),
                    discord: discord.trimmingCharacters(in: .whitespaces),
                    squad: squad.trimmingCharacters(in: .whitespaces)
                )
                let elapsed = Date().timeIntervalSince(startTime)
                if elapsed < 1.5 {
                    try? await Task.sleep(nanoseconds: UInt64((1.5 - elapsed) * 1_000_000_000))
                }
                await state.refreshData()
                DynamicIslandController.shared.showSuccess("Registered for tournament room!")
            } catch {
                DynamicIslandController.shared.showError("Registration failed. Please retry.")
            }
            isSubmitting = false
        }
    }
}

public struct CredentialBox: View {
    public var label: String
    public var value: String

    public var body: some View {
        Button(action: {
            UIPasteboard.general.string = value
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.impactOccurred()
            DynamicIslandController.shared.showSuccess("Copied \(label)")
        }) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                HStack {
                    Text(value)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.royalBlue)
                }
            }
            .padding(12)
            .liquidGlassSurface(cornerRadius: 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

public struct BoxCentered<Content: View>: View {
    @ViewBuilder public var content: () -> Content

    public var body: some View {
        HStack {
            Spacer()
            content()
            Spacer()
        }
    }
}
