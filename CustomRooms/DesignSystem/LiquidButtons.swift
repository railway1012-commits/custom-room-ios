import SwiftUI
import UIKit

public enum ButtonVariant {
    case primary
    case secondary
    case danger
}

public struct LiquidGlassPillButton: View {
    public var title: String
    public var systemImage: String?
    public var variant: ButtonVariant
    public var isLoading: Bool
    public var isEnabled: Bool
    public var width: CGFloat?
    public var height: CGFloat
    public var action: () -> Void

    @State private var isPressed = false
    @Environment(\.colorScheme) var colorScheme

    public init(
        title: String,
        systemImage: String? = nil,
        variant: ButtonVariant = .primary,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        width: CGFloat? = 220,
        height: CGFloat = 48,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.variant = variant
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.width = width
        self.height = height
        self.action = action
    }

    public var body: some View {
        Button(action: {
            guard isEnabled && !isLoading else { return }
            let haptic = UIImpactFeedbackGenerator(style: .medium)
            haptic.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.9)
                } else if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .semibold))
                }

                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundColor(textColor)
            .frame(maxWidth: width ?? .infinity)
            .frame(height: height)
            .background {
                Capsule()
                    .fill(backgroundColor)
                    .overlay {
                        Capsule()
                            .strokeBorder(borderColor, lineWidth: 1.0)
                    }
                    .shadow(
                        color: variant == .primary ? AppTheme.royalBlue.opacity(0.3) : Color.black.opacity(0.06),
                        radius: 8,
                        x: 0,
                        y: 3
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.94 : 1.0)
        .opacity(isEnabled ? 1.0 : 0.5)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    private var backgroundColor: AnyShapeStyle {
        if !isEnabled {
            return AnyShapeStyle(Color.gray.opacity(0.2))
        }
        switch variant {
        case .primary:
            return AnyShapeStyle(AppTheme.royalBlue)
        case .secondary:
            return AnyShapeStyle(.ultraThinMaterial)
        case .danger:
            return AnyShapeStyle(AppTheme.crimsonAlert)
        }
    }

    private var borderColor: Color {
        if !isEnabled { return .clear }
        switch variant {
        case .primary:
            return Color.white.opacity(0.3)
        case .secondary:
            return colorScheme == .dark ? Color.white.opacity(0.16) : Color.black.opacity(0.08)
        case .danger:
            return Color.white.opacity(0.3)
        }
    }

    private var textColor: Color {
        if !isEnabled { return .secondary }
        switch variant {
        case .primary, .danger:
            return .white
        case .secondary:
            return .primary
        }
    }
}

// MARK: - Apple Glass Segmented Selector
public struct LiquidGlassSegmentedPicker<T: Hashable>: View {
    public var options: [T]
    @Binding public var selection: T
    public var titleProvider: (T) -> String

    @Namespace private var animation
    @Environment(\.colorScheme) var colorScheme

    public init(
        options: [T],
        selection: Binding<T>,
        titleProvider: @escaping (T) -> String = { "\($0)" }
    ) {
        self.options = options
        self._selection = selection
        self.titleProvider = titleProvider
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                let isSelected = selection == option
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selection = option
                    }
                    let haptic = UISelectionFeedbackGenerator()
                    haptic.selectionChanged()
                }) {
                    Text(titleProvider(option))
                        .font(.system(size: 13.5, weight: isSelected ? .semibold : .medium, design: .rounded))
                        .foregroundColor(isSelected ? (colorScheme == .dark ? .white : .black) : .secondary)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(colorScheme == .dark ? Color.white.opacity(0.18) : Color.white)
                                    .shadow(color: Color.black.opacity(0.10), radius: 4, x: 0, y: 2)
                                    .matchedGeometryEffect(id: "segmentPill", in: animation)
                            }
                        }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .strokeBorder(colorScheme == .dark ? Color.white.opacity(0.10) : Color.black.opacity(0.06), lineWidth: 1)
                }
        }
    }
}

// MARK: - Google Sign In Button
public struct GoogleSignInButtonView: View {
    public var isLoading: Bool
    public var action: () -> Void

    public init(isLoading: Bool = false, action: @escaping () -> Void) {
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: {
            guard !isLoading else { return }
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.impactOccurred()
            action()
        }) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "g.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.blue)
                }
                Text("Continue with Google")
                    .font(.system(size: 14.5, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule()
                            .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
                    }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension LiquidGlassSegmentedPicker where T == Int {
    public init(options: [String], selectedIndex: Binding<Int>) {
        self.options = Array(0..<options.count)
        self._selection = selectedIndex
        self.titleProvider = { options[$0] }
    }
}

public typealias LiquidGlassGoogleButton = GoogleSignInButtonView
