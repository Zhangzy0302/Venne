import SwiftUI

struct BlushBloomVenneGuideView: View {
    @Environment(\.crystalBlushRouter) private var blushBloomRouter

    var body: some View {
        ZStack {
            
            blushBloomBackgroundLayer

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 332)

                Image("VENNEAppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 108, height: 108)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: Color.white.opacity(0.55), radius: 24, y: 10)

                Text("VENNE")
                    .font(GlowMuseTheme.blushBloomSerifFont(size: 26, weight: .black))
                    .tracking(0.8)
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                    .padding(.top, 18)

                Spacer()

                PetalLuxeButton(title: "GET STARTED", style: .primary, height: 54) {
                    blushBloomRouter?.push(.velvetAuraAuthPortal)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 166)
            }
        }
        .ignoresSafeArea()
        .background(Color.white)
    }

    private var blushBloomBackgroundLayer: some View {
        GeometryReader { glowMuseGeometry in
            ZStack(alignment: .top) {
                Image("VENNECGuideBg")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .clipped()
            }
        }
    }

}

#Preview {
    BlushBloomVenneGuideView()
}
