import SwiftUI

// MARK: - Support Sheet
public struct SupportSheetView: View {
    @Environment(\.dismiss) var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 6) {
                        Text("Player Support")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        Text("Get help with room keys, tournament slots, or prize payouts")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 10)

                    VStack(spacing: 14) {
                        supportCard(
                            icon: "envelope.fill",
                            tint: AppTheme.royalBlue,
                            title: "Email Support",
                            subtitle: "support@synchapp.dev",
                            badge: "Avg reply: 20 min"
                        )

                        supportCard(
                            icon: "bubble.left.and.bubble.right.fill",
                            tint: AppTheme.emeraldLive,
                            title: "Live Discord Mod Desk",
                            subtitle: "Instant help from tournament admins",
                            badge: "Online 24/7"
                        )

                        supportCard(
                            icon: "shield.checkerboard",
                            tint: AppTheme.amberGold,
                            title: "Dispute & Fair Play",
                            subtitle: "Report cheaters or incorrect match results",
                            badge: "Priority"
                        )
                    }

                    BoxCentered {
                        LiquidGlassPillButton(
                            title: "Contact Support Team",
                            systemImage: "paperplane.fill",
                            variant: .primary,
                            width: 220,
                            height: 48
                        ) {
                            DynamicIslandController.shared.showSuccess("Support ticket initiated")
                            dismiss()
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.foregroundColor(.secondary)
                }
            }
        .presentationDetents([.medium, .large])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(34)
        .presentationDragIndicator(.visible)
    }

    private func supportCard(icon: String, tint: Color, title: String, subtitle: String, badge: String) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(tint.opacity(0.14))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(tint)
                }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Spacer()
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(tint)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(tint.opacity(0.12)))
                }
                Text(subtitle)
                    .font(.system(size: 12.5))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .liquidGlassCard(cornerRadius: 18)
    }
}

// MARK: - Feedback Sheet
public struct FeedbackSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var rating: Int = 5
    @State private var comment: String = ""
    @State private var isSubmitting: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("Help & Feedback")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("How is your tournament and scrim experience?")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 10)

                // Star Rating
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { star in
                        Button(action: { rating = star }) {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.system(size: 28))
                                .foregroundColor(star <= rating ? AppTheme.amberGold : Color.gray.opacity(0.3))
                        }
                    }
                }
                .padding(.vertical, 8)

                // Comment area
                VStack(alignment: .leading, spacing: 6) {
                    Text("TELL US MORE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    TextEditor(text: $comment)
                        .frame(height: 120)
                        .padding(12)
                        .liquidGlassCard(cornerRadius: 16)
                }

                Spacer()

                BoxCentered {
                    LiquidGlassPillButton(
                        title: "Send Feedback",
                        systemImage: "arrow.up.circle.fill",
                        variant: .primary,
                        isLoading: isSubmitting,
                        width: 220,
                        height: 48
                    ) {
                        isSubmitting = true
                        Task {
                            try? await Task.sleep(nanoseconds: 800_000_000)
                            isSubmitting = false
                            DynamicIslandController.shared.showSuccess("Thank you for your feedback!")
                            dismiss()
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(.secondary)
                }
            }
        .presentationDetents([.medium, .large])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(34)
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Discord Sheet
public struct DiscordSheetView: View {
    @Environment(\.dismiss) var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Circle()
                    .fill(Color(hex: "5865F2").opacity(0.15))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 34))
                            .foregroundColor(Color(hex: "5865F2"))
                    }
                    .padding(.top, 20)

                VStack(spacing: 8) {
                    Text("Official Discord Community")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text("Connect with 15,000+ competitive PUBG players, find teammates, and get live room password pings")
                        .font(.system(size: 13.5))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 12) {
                    discordPerk(title: "Instant Room Key Pings", icon: "bell.badge.fill")
                    discordPerk(title: "Scrim Voice Channels & Team Finder", icon: "waveform")
                    discordPerk(title: "Weekly UC Giveaways & Bounties", icon: "gift.fill")
                }
                .padding(18)
                .liquidGlassCard(cornerRadius: 20)

                Spacer()

                BoxCentered {
                    LiquidGlassPillButton(
                        title: "Open Discord Server",
                        systemImage: "arrow.up.right",
                        variant: .primary,
                        width: 220,
                        height: 48
                    ) {
                        if let url = URL(string: "https://discord.gg/synch") {
                            UIApplication.shared.open(url)
                        }
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, 24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.foregroundColor(.secondary)
                }
            }
        .presentationDetents([.medium, .large])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(34)
        .presentationDragIndicator(.visible)
    }

    private func discordPerk(title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.royalBlue)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
            Spacer()
        }
    }
}

// MARK: - FAQ Sheet
public struct FaqSheetView: View {
    @Environment(\.dismiss) var dismiss

    public init() {}

    let faqs: [(q: String, a: String)] = [
        ("When is the room key revealed?", "The Room ID and Password are automatically published by the tournament host approximately 5 to 10 minutes before the scheduled match time. If you have reserved a slot, they will reveal directly in the Room Details view."),
        ("How are UC prize pool bounties distributed?", "UC rewards are transferred directly to winning team leaders via in-game PUBG Mobile ID within 24 hours of match completion. Verify your UID in your Me tab profile."),
        ("Can I reserve a slot without creating an account?", "Yes! You can reserve slots directly as a guest player. However, creating an account syncs your stats and payout records across all your devices."),
        ("What happens if a room match is cancelled?", "If a room is cancelled by the tournament host, any reserved slots are released immediately and notified via Dynamic Island.")
    ]

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Frequently Asked Questions")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .padding(.top, 10)

                    ForEach(faqs, id: \.q) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.q)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)

                            Text(item.a)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .lineSpacing(3)
                        }
                        .padding(16)
                        .liquidGlassCard(cornerRadius: 18)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.foregroundColor(.secondary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(34)
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Legal Doc Sheet
public struct LegalDocSheetView: View {
    @Environment(\.dismiss) var dismiss
    public var title: String

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .padding(.top, 10)

                    Text("Effective Date: October 2026")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)

                    Divider().padding(.vertical, 4)

                    Text(contentForTitle(title))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineSpacing(5)
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }.foregroundColor(.secondary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(34)
        .presentationDragIndicator(.visible)
    }

    private func contentForTitle(_ t: String) -> String {
        switch t {
        case "Privacy Policy":
            return "Synch Arena respects your privacy. We collect minimal personal data including your email address and PUBG Mobile player identity (In-Game Name and Character UID) solely to facilitate tournament registrations, verify match results, and disburse prize pool bounties. We do not sell, rent, or trade your personal information to third parties. All communication between your device and our servers is secured using TLS 1.3 encryption."
        case "Terms of Service":
            return "By using Synch Arena, you agree to comply with all tournament rules, fair play guidelines, and service conditions. You represent that your PUBG Mobile account credentials belong to you and that you will not engage in unauthorized exploitation, botting, or disruption of scrim matches. Synch Arena reserves the right to suspend or terminate accounts found violating these terms."
        case "Fair Play & Anti-Cheat Policy":
            return "Synch Arena enforces a strict zero-tolerance policy against cheating, third-party software, radar hacks, teaming with rival squads, or any unfair competitive advantages. Matches are subject to review by tournament moderators. Accounts caught utilizing prohibited software will be permanently banned from all Synch tournaments and prize pools."
        case "Tournament Rulebook":
            return "All PUBG Mobile scrims hosted on Synch Arena follow standard competitive esports scoring rules (placement points + kill points). Players must join the assigned in-game custom room at least 3 minutes before the scheduled start time. Late arrivals forfeit their slot. Disconnections during drop phase will be handled at the host's discretion."
        default:
            return "Please visit https://rooms.synchapp.dev for complete information regarding tournament rules and policies."
        }
    }
}
