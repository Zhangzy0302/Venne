import SwiftUI

struct PetalLuxeButton: View {
    enum VelvetAuraStyle {
        case primary
        case secondary
        case segmented(isSelected: Bool)
    }

    let title: String
    let style: VelvetAuraStyle
    var height: CGFloat = 50
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(buttonFont)
                .tracking(buttonTracking)
                .foregroundStyle(titleColor)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(backgroundStyle)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var buttonFont: Font {
        switch style {
        case .primary:
            GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .bold)
        case .secondary:
            GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .bold)
        case .segmented:
            GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .bold)
        }
    }

    private var buttonTracking: CGFloat {
        switch style {
        case .primary:
            0.5
        case .secondary:
            0
        case .segmented:
            0
        }
    }

    private var titleColor: Color {
        switch style {
        case .primary:
            .white
        case .secondary:
            GlowMuseTheme.blushBloomPrimaryText
        case .segmented(let isSelected):
            isSelected ? .white : GlowMuseTheme.blushBloomPrimaryText
        }
    }

    @ViewBuilder
    private var backgroundStyle: some View {
        switch style {
        case .primary:
            GlowMuseTheme.velvetAuraAccentGradient
        case .secondary:
            GlowMuseTheme.silkBloomSurfaceFill
        case .segmented(let isSelected):
            if isSelected {
                GlowMuseTheme.velvetAuraAccentGradient
            } else {
                GlowMuseTheme.velvetAuraMutedGradient
            }
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary:
            GlowMuseTheme.velvetAuraPrimaryShadow
        case .secondary, .segmented:
            .clear
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .primary:
            18
        case .secondary, .segmented:
            0
        }
    }

    private var shadowYOffset: CGFloat {
        switch style {
        case .primary:
            10
        case .secondary, .segmented:
            0
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PetalLuxeButton(title: "GET STARTED", style: .primary) {}
        PetalLuxeButton(title: "CONTINUE WITH GUEST", style: .secondary) {}
        PetalLuxeButton(title: "SIGN IN", style: .segmented(isSelected: true), height: 48) {}
    }
    .padding()
    .background(Color.gray.opacity(0.12))
}
