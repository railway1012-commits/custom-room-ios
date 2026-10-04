import SwiftUI
import UIKit

public enum MainTab: Int, CaseIterable {
    case rooms = 0
    case matches = 1
    case me = 2

    public var title: String {
        switch self {
        case .rooms: return "Rooms"
        case .matches: return "Matches"
        case .me: return "Me"
        }
    }

    public var icon: String {
        switch self {
        case .rooms: return "gamecontroller.fill"
        case .matches: return "trophy.fill"
        case .me: return "person.crop.circle.fill"
        }
    }
}

public struct LiquidFloatingDockView: View {
    @Binding public var selectedTab: MainTab
    public var onSearchTapped: (() -> Void)? = nil

    @Namespace private var animation
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var state: AppState

    public init(selectedTab: Binding<MainTab>, onSearchTapped: (() -> Void)? = nil) {
        self._selectedTab = selectedTab
        self.onSearchTapped = onSearchTapped
    }

    public var body: some View {
        HStack(spacing: 10) {
            // Main Floating Island Capsule Bar (Phone Keypad Dock style)
            HStack(spacing: 4) {
                ForEach(MainTab.allCases, id: \.self) { tab in
                    let isSelected = selectedTab == tab

                    Button(action: {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.75)) {
                            selectedTab = tab
                        }
                        if state.hapticsEnabled {
                            UISelectionFeedbackGenerator().selectionChanged()
                        }
                    }) {
                        ZStack {
                            // Active Tab Pill Highlight (Exact match to Keypad highlight in iOS Phone app)
                            if isSelected {
                                Capsule()
                                    .fill(
                                        colorScheme == .dark
                                            ? Color.white.opacity(0.14)
                                            : Color.white
                                    )
                                    .overlay {
                                        Capsule()
                                            .strokeBorder(
                                                colorScheme == .dark
                                                    ? Color.white.opacity(0.18)
                                                    : Color.black.opacity(0.06),
                                                lineWidth: 0.75
                                            )
                                    }
                                    .shadow(
                                        color: colorScheme == .dark
                                            ? Color.black.opacity(0.35)
                                            : Color.black.opacity(0.08),
                                        radius: 4,
                                        x: 0,
                                        y: 2
                                    )
                                    .frame(width: 76, height: 46)
                                    .matchedGeometryEffect(id: "activeTabCapsule", in: animation)
                            }

                            // Tab Icon + Label
                            VStack(spacing: 2) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundColor(
                                            isSelected
                                                ? AppTheme.royalBlue
                                                : (colorScheme == .dark ? Color.white.opacity(0.65) : Color.black.opacity(0.55))
                                        )

                                    // Badge on Rooms if live rooms exist
                                    if tab == .rooms && state.rooms.contains(where: { $0.status.lowercased() == "open" || $0.status.lowercased() == "live" }) {
                                        Circle()
                                            .fill(AppTheme.crimsonAlert)
                                            .frame(width: 7, height: 7)
                                            .offset(x: 5, y: -2)
                                    }
                                }
                                .frame(height: 22)

                                Text(tab.title)
                                    .font(.system(size: 11, weight: isSelected ? .bold : .medium, design: .rounded))
                                    .foregroundColor(
                                        isSelected
                                            ? AppTheme.royalBlue
                                            : (colorScheme == .dark ? Color.white.opacity(0.65) : Color.black.opacity(0.55))
                                    )
                            }
                        }
                        .frame(width: 76, height: 46)
                        .contentShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 6)
            .frame(height: 58)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        colorScheme == .dark ? Color.white.opacity(0.24) : Color.white.opacity(0.85),
                                        colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.0
                            )
                    }
                    .shadow(
                        color: colorScheme == .dark ? Color.black.opacity(0.4) : Color.black.opacity(0.12),
                        radius: 16,
                        x: 0,
                        y: 6
                    )
            }

            // Companion Floating Circular Glass Search Button (Matches Search circle in Phone app)
            Button(action: {
                if state.hapticsEnabled {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                if let onSearchTapped = onSearchTapped {
                    onSearchTapped()
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = .rooms
                        state.isSearchPresented.toggle()
                    }
                }
            }) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            colorScheme == .dark ? Color.white.opacity(0.24) : Color.white.opacity(0.85),
                                            colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.08)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.0
                                )
                        }
                        .shadow(
                            color: colorScheme == .dark ? Color.black.opacity(0.4) : Color.black.opacity(0.12),
                            radius: 16,
                            x: 0,
                            y: 6
                        )

                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(
                            state.isSearchPresented
                                ? AppTheme.royalBlue
                                : (colorScheme == .dark ? .white : .primary)
                        )
                }
                .frame(width: 58, height: 58)
                .contentShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(height: 58)
    }
}
