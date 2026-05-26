import SwiftUI

struct HoneyGlowAISurface<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack(alignment: .top) {
            RougeRibbonGuideBackground()
                .ignoresSafeArea()

            HoneyGlowAISparkleCluster()

            content
        }
        .clipShape(CrystalBlushUnevenRoundedRectangle(bottomLeadingRadius: 52))
        .ignoresSafeArea()
    }
}

struct HoneyGlowAITitleBar<Trailing: View>: View {
    @Environment(\.crystalBlushRouter) private var honeyGlowRouter

    let title: String
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack(spacing: 12) {
            Button {
                honeyGlowRouter?.pop()
            } label: {
                Image("VENNECNavBack")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
            }
            .buttonStyle(.plain)

            Text(title)
                .font(GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

            Spacer()

            trailing
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }
}

struct HoneyGlowAISparkleCluster: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 14) {
                Image(systemName: "sparkle")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)

                Image(systemName: "sparkle")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
                    .padding(.top, 42)
            }
            .offset(x: 42, y: 92)
            .rotationEffect(.degrees(12))
        }
    }
}

struct HoneyGlowAIArtworkCard: View {
    let imageName: String
    var size: CGSize

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
