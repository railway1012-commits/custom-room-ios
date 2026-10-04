import SwiftUI

public struct GamerProfileSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var state: AppState

    @State private var ign: String = ""
    @State private var uid: String = ""
    @State private var squad: String = ""
    @State private var discord: String = ""

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 6) {
                        Text("PUBG Gamer Identity")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Text("Update your in-game identity for rapid scrim registration")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 10)

                    VStack(spacing: 14) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .foregroundColor(AppTheme.royalBlue)
                            TextField("PUBG In-Game Name (IGN)*", text: $ign)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .liquidGlassField()

                        HStack(spacing: 12) {
                            Image(systemName: "number")
                                .foregroundColor(AppTheme.amberGold)
                            TextField("Character UID (Numbers only)*", text: $uid)
                                .keyboardType(.numberPad)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .liquidGlassField()

                        HStack(spacing: 12) {
                            Image(systemName: "shield.fill")
                                .foregroundColor(AppTheme.emeraldLive)
                            TextField("Squad / Clan Tag (Optional)", text: $squad)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .liquidGlassField()

                        HStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .foregroundColor(AppTheme.royalBlue)
                            TextField("Discord Username (Optional)", text: $discord)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .liquidGlassField()
                    }

                    BoxCentered {
                        LiquidGlassPillButton(
                            title: "Save Profile",
                            systemImage: "checkmark.circle.fill",
                            variant: .primary,
                            width: 220,
                            height: 48
                        ) {
                            save()
                        }
                    }
                    .padding(.top, 10)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .onAppear {
                ign = state.gamerProfile.defaultIgn
                uid = state.gamerProfile.defaultUid
                squad = state.gamerProfile.defaultSquad
                discord = state.gamerProfile.defaultDiscord
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func save() {
        let profile = GamerProfile(
            defaultIgn: ign.trimmingCharacters(in: .whitespaces),
            defaultUid: uid.trimmingCharacters(in: .whitespaces),
            defaultDiscord: discord.trimmingCharacters(in: .whitespaces),
            defaultSquad: squad.trimmingCharacters(in: .whitespaces)
        )
        state.saveProfile(profile)
        DynamicIslandController.shared.showSuccess("Gamer profile updated!")
        dismiss()
    }
}
