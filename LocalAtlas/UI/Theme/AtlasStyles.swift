import SwiftUI

struct AtlasPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                LinearGradient(colors: [AtlasTheme.accent, AtlasTheme.accent2], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .foregroundColor(.white)
            .clipShape(Capsule())
            .shadow(color: AtlasTheme.accent.opacity(configuration.isPressed ? 0.0 : 0.6), radius: configuration.isPressed ? 0 : 10, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct AtlasSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AtlasTheme.panelFill)
            .foregroundColor(AtlasTheme.textPrimary)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(AtlasTheme.panelStroke, lineWidth: 0.5))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct AtlasPanel: ViewModifier {
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)
        content
            .padding(12)
            .background(shape.fill(AtlasTheme.panelFill))
            .background(.ultraThinMaterial)
            .clipShape(shape)
            .overlay(shape.stroke(AtlasTheme.panelStroke, lineWidth: 0.8))
            .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
    }
}

struct AtlasTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(10)
            .background(AtlasTheme.panelFill)
            .foregroundColor(AtlasTheme.textPrimary)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AtlasTheme.panelStroke, lineWidth: 0.5)
            )
    }
}

extension View {
    func atlasPanel() -> some View {
        modifier(AtlasPanel())
    }
}
