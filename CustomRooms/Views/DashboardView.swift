import SwiftUI

public struct DashboardView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.colorScheme) var colorScheme

    public var body: some View {
        NavigationStack {
            ZStack {
                (colorScheme == .dark ? AppTheme.darkBackground : AppTheme.lightBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("My Matches")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)

                                Text("Tournament stats & prize payout tracker")
                                    .font(.system(size: 13.5, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                        let mySignups = state.signups.filter { $0.createdById == (state.currentUser?.id ?? "") }
                        let totalKills = mySignups.reduce(0) { $0 + $1.kills }
                        let totalUc = mySignups.reduce(0.0) { $0 + $1.ucAmount }

                        // Stat counters row
                        HStack(spacing: 12) {
                            StatBox(title: "Matches", value: "\(mySignups.count)", icon: "gamecontroller.fill", tint: AppTheme.royalBlue)
                            StatBox(title: "Total Kills", value: "\(totalKills)", icon: "scope", tint: AppTheme.crimsonAlert)
                            StatBox(title: "UC Won", value: "\(Int(totalUc))", icon: "cross.fill", tint: AppTheme.amberGold)
                        }
                        .padding(.horizontal, 18)

                        if mySignups.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.secondary)
                                Text("No Match History")
                                    .font(.system(size: 17, weight: .semibold))
                                Text("Register for an open room to track your performance.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 40)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(mySignups) { signup in
                                    let room = state.rooms.first { $0.id == signup.roomId }
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack {
                                            Text(room?.title ?? "Tournament Match")
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .lineLimit(1)
                                            Spacer()
                                            Text(signup.payoutStatus)
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(signup.payoutStatus == "Sent" ? AppTheme.emeraldLive : AppTheme.amberGold)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(Capsule().fill(Color.primary.opacity(0.06)))
                                        }

                                        HStack(spacing: 16) {
                                            Text("\(signup.kills) Kills")
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.secondary)

                                            Text("\(Int(signup.ucAmount)) UC Prize")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(AppTheme.amberGold)

                                            Spacer()

                                            Text("IGN: \(signup.ign)")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(16)
                                    .liquidGlassCard(cornerRadius: 18)
                                }
                            }
                            .padding(.horizontal, 18)
                        }

                        Spacer(minLength: 120)
                    }
                }
            }
        }
    }
}

public struct StatBox: View {
    public var title: String
    public var value: String
    public var icon: String
    public var tint: Color

    public var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(tint)

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .liquidGlassCard(cornerRadius: 20)
    }
}
