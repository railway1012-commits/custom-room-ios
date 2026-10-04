import SwiftUI

public struct MainTabView: View {
    @EnvironmentObject var state: AppState
    @State private var selectedTab: MainTab = .rooms
    @Environment(\.colorScheme) var systemColorScheme

    public init() {}

    public var body: some View {
        ZStack {
            // Apply current theme background
            activeThemeBackground
                .ignoresSafeArea()

            // Main Tab Content
            ZStack {
                switch selectedTab {
                case .rooms:
                    RoomsView()
                case .matches:
                    DashboardView()
                case .me:
                    MeSettingsView(selectedTab: $selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Dynamic Island Pill Notification Host (Top Z-Index)
            VStack {
                DynamicIslandHostView()
                    .padding(.top, 4)
                Spacer()
            }
            .zIndex(999)
            .ignoresSafeArea(edges: .top)

            // Floating Liquid Glass Dock (Bottom Z-Index)
            VStack {
                Spacer()
                LiquidFloatingDockView(selectedTab: $selectedTab)
                    .padding(.bottom, 12)
            }
            .zIndex(100)
            .ignoresSafeArea(edges: .bottom)
        }
        // First-time setup wizard presentation (Only if not completed)
        .fullScreenCover(isPresented: Binding(
            get: { !state.isSetupCompleted },
            set: { if !$0 { state.skipSetup() } }
        )) {
            SetupWizardView()
                .environmentObject(state)
        }
        .preferredColorScheme(preferredColorScheme)
        .task {
            await state.refreshData()
        }
    }

    @ViewBuilder
    private var activeThemeBackground: some View {
        switch state.themeMode {
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

    private var preferredColorScheme: ColorScheme? {
        switch state.themeMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}
