import SwiftUI

public struct RoomsView: View {
    @EnvironmentObject var state: AppState
    @Binding public var selectedRoom: Room?
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
                                Text("Custom Scrims")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)

                                Text("Battle for UC bounties & podium finishes")
                                    .font(.system(size: 13.5, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                        if state.rooms.isEmpty && state.isLoading {
                            ProgressView()
                                .padding(.top, 40)
                        } else if state.rooms.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "gamecontroller.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                Text("No Rooms Available")
                                    .font(.system(size: 17, weight: .semibold))
                                Text("Check back soon or pull down to refresh.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 60)
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(state.rooms) { room in
                                    RoomCardView(room: room, signups: state.signups.filter { $0.roomId == room.id }) {
                                        selectedRoom = room
                                    }
                                }
                            }
                            .padding(.horizontal, 18)
                        }

                        Spacer(minLength: 120)
                    }
                }
                .refreshable {
                    await state.refreshData()
                }
            }
        }
    }
}

public struct RoomCardView: View {
    public var room: Room
    public var signups: [Signup]
    public var onTap: () -> Void

    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 14) {
                // Top row: Mode badge & Status pill
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 11, weight: .bold))
                        Text(room.mode.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(AppTheme.royalBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background {
                        Capsule()
                            .fill(AppTheme.royalBlue.opacity(0.12))
                    }

                    Spacer()

                    // Status pill
                    HStack(spacing: 5) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 6, height: 6)
                        Text(room.status.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background {
                        Capsule()
                            .fill(statusColor.opacity(0.12))
                    }
                }

                // Title
                Text(room.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                // Stats row
                HStack(spacing: 18) {
                    HStack(spacing: 6) {
                        Image(systemName: "cross.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.amberGold)
                        Text("\(Int(room.ucPerKill)) UC / Kill")
                            .font(.system(size: 13.5, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text("\(signups.count)/\(room.maxPlayers) slots")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                }

                // Progress Bar
                GeometryReader { geo in
                    let pct = min(1.0, CGFloat(signups.count) / CGFloat(max(1, room.maxPlayers)))
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.primary.opacity(0.08))
                            .frame(height: 5)

                        Capsule()
                            .fill(pct >= 1.0 ? Color.gray : AppTheme.royalBlue)
                            .frame(width: geo.size.width * pct, height: 5)
                    }
                }
                .frame(height: 5)
            }
            .padding(18)
            .liquidGlassCard(cornerRadius: 22)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var statusColor: Color {
        switch room.status.lowercased() {
        case "open": return AppTheme.emeraldLive
        case "live": return AppTheme.amberGold
        case "full": return Color.gray
        default: return Color.gray
        }
    }
}
