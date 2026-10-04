import SwiftUI
import Combine

public enum IslandType {
    case info
    case processing
    case success
    case error

    var icon: String {
        switch self {
        case .info: return "info.circle.fill"
        case .processing: return "arrow.triangle.2.circlepath"
        case .success: return "checkmark.circle.fill"
        case .error: return "exclamationmark.circle.fill"
        }
    }

    var tintColor: Color {
        switch self {
        case .info: return AppTheme.amberGold
        case .processing: return Color.blue
        case .success: return AppTheme.emeraldLive
        case .error: return AppTheme.crimsonAlert
        }
    }
}

public struct IslandNotification: Identifiable, Equatable {
    public let id = UUID()
    public let type: IslandType
    public let title: String
    public let message: String?
    public let duration: TimeInterval

    public init(type: IslandType, title: String, message: String? = nil, duration: TimeInterval = 3.0) {
        self.type = type
        self.title = title
        self.message = message
        self.duration = duration
    }
}

public class DynamicIslandController: ObservableObject {
    @Published public var currentNotification: IslandNotification?
    private var dismissTask: AnyCancellable?

    public static let shared = DynamicIslandController()

    public func showSuccess(_ title: String, message: String? = nil) {
        post(IslandNotification(type: .success, title: title, message: message))
    }

    public func showError(_ title: String, message: String? = nil) {
        post(IslandNotification(type: .error, title: title, message: message, duration: 4.0))
    }

    public func showInfo(_ title: String, message: String? = nil) {
        post(IslandNotification(type: .info, title: title, message: message))
    }

    public func showProcessing(_ title: String, message: String? = nil) {
        post(IslandNotification(type: .processing, title: title, message: message, duration: 0))
    }

    public func dismiss() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            currentNotification = nil
        }
    }

    private func post(_ notification: IslandNotification) {
        dismissTask?.cancel()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
            currentNotification = notification
        }

        if notification.duration > 0 {
            dismissTask = Just(())
                .delay(for: .seconds(notification.duration), scheduler: RunLoop.main)
                .sink { [weak self] in
                    self?.dismiss()
                }
        }
    }
}

public struct DynamicIslandHostView: View {
    @ObservedObject var controller = DynamicIslandController.shared

    public var body: some View {
        VStack {
            if let notification = controller.currentNotification {
                HStack(spacing: 12) {
                    Image(systemName: notification.type.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(notification.type.tintColor)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(notification.title)
                            .font(.system(size: 13.5, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        if let message = notification.message {
                            Text(message)
                                .font(.system(size: 11.5, weight: .regular))
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background {
                    Capsule()
                        .fill(Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.96))
                        .overlay {
                            Capsule()
                                .strokeBorder(Color.white.opacity(0.20), lineWidth: 0.8)
                        }
                        .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 6)
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.7).combined(with: .opacity).combined(with: .move(edge: .top)),
                    removal: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .top))
                ))
                .onTapGesture {
                    controller.dismiss()
                }
            }
            Spacer()
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.72), value: controller.currentNotification)
    }
}
