import SwiftUI

// MARK: - Liquid Glass Card Modifier
public struct LiquidGlassCardModifier: ViewModifier {
    public var cornerRadius: CGFloat
    public var shadowRadius: CGFloat
    @Environment(\.colorScheme) var colorScheme

    public func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        colorScheme == .dark ? Color.white.opacity(0.22) : Color.white.opacity(0.65),
                                        colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.06)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.0
                            )
                    }
                    .shadow(
                        color: colorScheme == .dark ? Color.black.opacity(0.45) : Color.black.opacity(0.08),
                        radius: shadowRadius,
                        x: 0,
                        y: 4
                    )
            }
    }
}

public extension View {
    func liquidGlassCard(cornerRadius: CGFloat = 24, shadowRadius: CGFloat = 10) -> some View {
        self.modifier(LiquidGlassCardModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }

    func liquidGlassSurface(cornerRadius: CGFloat = 18) -> some View {
        self.modifier(LiquidGlassCardModifier(cornerRadius: cornerRadius, shadowRadius: 6))
    }
}

// MARK: - Liquid Pill Text Field
public struct LiquidGlassTextField: View {
    @Binding public var text: String
    public var label: String
    public var placeholder: String
    public var systemImage: String?
    public var isSecure: Bool
    public var isNumeric: Bool
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme

    public init(
        text: Binding<String>,
        label: String = "",
        placeholder: String = "",
        systemImage: String? = nil,
        isSecure: Bool = false,
        isNumeric: Bool = false
    ) {
        self._text = text
        self.label = label
        self.placeholder = placeholder
        self.systemImage = systemImage
        self.isSecure = isSecure
        self.isNumeric = isNumeric
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                    .foregroundColor(isFocused ? AppTheme.royalBlue : .secondary)
            }

            HStack(spacing: 12) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isFocused ? AppTheme.royalBlue : .secondary)
                        .frame(width: 22)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .focused($isFocused)
                        .font(.system(size: 15, weight: .regular))
                } else {
                    TextField(placeholder, text: $text)
                        .focused($isFocused)
                        .keyboardType(isNumeric ? .numberPad : .default)
                        .font(.system(size: 15, weight: .regular))
                }
            }
            .padding(.horizontal, 18)
            .frame(height: 50)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                isFocused ? AppTheme.royalBlue : (colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.10)),
                                lineWidth: isFocused ? 1.5 : 1.0
                            )
                    }
            }
        }
    }
}
