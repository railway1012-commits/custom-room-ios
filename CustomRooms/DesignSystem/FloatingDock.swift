import SwiftUI
import UIKit

public enum MainTab: Int, CaseIterable {
    case rooms = 0
    case matches = 1
    case me = 2

    var title: String {
        switch self {
        case .rooms: return "Rooms"
        case .matches: return "Matches"
        case .me: return "Me"
        }
    }

    var icon: String {
        switch self {
        case .rooms: return "gamecontroller.fill"
        case .matches: return "trophy.fill"
        case .me: return "person.fill"
        }
    }
}

public struct LiquidFloatingDockView: View {
    @Binding public var selectedTab: MainTab
    @Namespace private var animation
    @Environment(\.colorScheme) var colorScheme

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                let isSelected = selectedTab == tab

                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        selectedTab = tab
                    }
                    let haptic = UISelectionFeedbackGenerator()
                    haptic.selectionChanged()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: .semibold))

                        if isSelected {
                            Text(tab.title)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .foregroundColor(isSelected ? .white : .secondary)
                    .padding(.horizontal, isSelected ? 16 : 14)
                    .padding(.vertical, 10)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(AppTheme.royalBlue)
                                .shadow(color: AppTheme.royalBlue.opacity(0.35), radius: 6, x: 0, y: 3)
                                .matchedGeometryEffect(id: "activeDockTab", in: animation)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(6)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .strokeBorder(
                            colorScheme == .dark ? Color.white.opacity(0.18) : Color.black.opacity(0.08),
                            lineWidth: 1
                        )
                }
                .shadow(
                    color: colorScheme == .dark ? Color.black.opacity(0.5) : Color.black.opacity(0.12),
                    radius: 16,
                    x: 0,
                    y: 6
                )
        }
    }
}
