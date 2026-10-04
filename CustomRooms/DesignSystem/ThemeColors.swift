import SwiftUI

public struct AppTheme {
    public static let royalBlue = Color(red: 37/255, green: 99/255, blue: 235/255)
    public static let amberGold = Color(red: 245/255, green: 158/255, blue: 11/255)
    public static let amberGoldBg = Color(red: 254/255, green: 243/255, blue: 199/255)
    public static let emeraldLive = Color(red: 16/255, green: 185/255, blue: 129/255)
    public static let emeraldLiveBg = Color(red: 236/255, green: 253/255, blue: 245/255)
    public static let crimsonAlert = Color(red: 239/255, green: 68/255, blue: 68/255)
    public static let crimsonAlertBg = Color(red: 254/255, green: 242/255, blue: 242/255)

    // Dynamic background colors
    public static let lightBackground = Color(red: 248/255, green: 249/255, blue: 250/255)
    public static let darkBackground = Color(red: 9/255, green: 13/255, blue: 22/255)
}

public enum AppThemeMode: String, CaseIterable, Codable {
    case light = "LIGHT"
    case dark = "DARK"
    case system = "SYSTEM"

    public var title: String {
        switch self {
        case .light: return "☀️ Light"
        case .dark: return "🌙 Dark"
        case .system: return "⚙️ System"
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}
