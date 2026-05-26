import SwiftUI

struct CrystalBlushEulaOverlayView: View {
    var onClose: () -> Void = {}
    var onAgree: () -> Void = {}

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.48)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack() {
                    Text("EULA")
                        .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .bold))
                        .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

                    Spacer()

                    Button(action: onClose) {
                        Circle()
                            .fill(GlowMuseTheme.blushBloomPrimaryText.opacity(0.05))
                            .frame(width: 52, height: 52)
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
                            )
                    }
                    .buttonStyle(.plain)
                }

                Text(crystalBlushEulaContent)
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                    .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText)
                    .lineSpacing(1.5)
                    .padding(.top, 22)
                    .padding(.bottom, 20)

                PetalLuxeButton(title: "AGREE", style: .primary, height: 48, action: onAgree)
                    .padding(.horizontal, 62)
                    .padding(.bottom, 22)
            }
            .padding(.top, 18)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
            .background(
                ZStack(alignment: .bottomTrailing) {
                    Color.white

                    Circle()
                        .stroke(Color(red: 0.94, green: 0.73, blue: 0.86), lineWidth: 1)
                        .frame(width: 170, height: 170)
                        .offset(x: 74, y: 58)
                }.clipShape(
                    CrystalBlushUnevenRoundedRectangle(
                        topLeadingRadius: 32
                    )
                )
            )
            
        }.ignoresSafeArea()
    }

    private var crystalBlushEulaContent: String {
        """
        Welcome to Venne. To make this a better place, the following content is not allowed in the app in particular:
        1. Any content about child harm, pornography related detrimental to children.
        2. Fake and harmful messages about recent or current events.
        3. Any violence, bullying content, publicly promotes pornography and other content.

        If we find any content including and not limited to the above violations your content will be deleted and account will be banned. By clicking the above button, you agree to the Terms of Use and Privacy Policy.
        """
    }
}

private struct CrystalBlushEulaOverlayPreviewHost: View {
    var body: some View {
        ZStack {
            BlushBloomVenneGuideView()
            CrystalBlushEulaOverlayView()
        }
    }
}

#Preview {
    CrystalBlushEulaOverlayPreviewHost()
}
