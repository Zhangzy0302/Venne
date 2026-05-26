import SwiftUI

enum GlowMuseTheme {
    static let blushBloomFontName = "TeXGyreAdventor-Regular"

    static let velvetAuraAccentGradient = LinearGradient(
        colors: [
            Color(red: 0.67, green: 0.86, blue: 0.93),
            Color(red: 0.82, green: 0.52, blue: 0.87),
            Color(red: 0.93, green: 0.43, blue: 0.63),
            Color(red: 0.98, green: 0.61, blue: 0.46)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let velvetAuraMutedGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.96),
            Color.white.opacity(0.96)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let blushBloomPrimaryText = Color(red: 23/255, green: 25/255, blue: 27/255)
    static let blushBloomSecondaryText = Color.black.opacity(0.78)
    static let blushBloomMutedText = Color.black.opacity(0.70)
    static let velvetAuraCursorTint = Color.black
    static let honeyGlowLinkText = Color(red: 0.91, green: 0.52, blue: 0.77)
    static let moonPetalFieldFill = Color.white.opacity(0.48)
    static let silkBloomSurfaceFill = Color.white.opacity(0.92)
    static let crystalBlushSelectionFill = Color(red: 0.91, green: 0.45, blue: 0.70)
    static let crystalBlushRing = Color.white.opacity(0.95)
    static let velvetAuraPrimaryShadow = Color(red: 0.89, green: 0.48, blue: 0.67).opacity(0.28)

    static func blushBloomSerifFont(size: CGFloat, weight: Font.Weight) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    static func blushBloomBodyFont(size: CGFloat) -> Font {
        .custom(blushBloomFontName, size: size)
    }
}
