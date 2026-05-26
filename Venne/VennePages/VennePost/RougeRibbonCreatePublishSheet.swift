import SwiftUI

struct RougeRibbonCreatePublishSheet: View {
    var onClose: () -> Void = {}
    var onPostTap: () -> Void = {}
    var onChatRoomTap: () -> Void = {}

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.52)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(alignment: .leading, spacing: 0) {
                HStack() {
                    Text("CREATE/PUBLISH")
                        .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .bold))
                        .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

                    Spacer()

                    Button(action: onClose) {
                        Circle()
                            .fill(Color(red: 0.96, green: 0.96, blue: 0.97))
                            .frame(width: 46, height: 46)
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .regular))
                                    .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
                            )
                    }
                    .buttonStyle(.plain)
                }

                HStack(alignment: .top, spacing: 28) {
                    blushBloomCreateItem(
                        imageName: "VENNEPostLogo",
                        title: "POST",
                        action: onPostTap
                    )

                    blushBloomCreateItem(
                        imageName: "VENNECreateChatRoomLogo",
                        title: "EVENT CHAT ROOM",
                        action: onChatRoomTap
                    )
                }
                .padding(.top, 30)
                .padding(.bottom, 54)
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 18)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                ZStack(alignment: .topLeading) {
                    Color.white

                    Circle()
                        .stroke(Color(red: 0.80, green: 0.90, blue: 0.97), lineWidth: 1)
                        .frame(width: 182, height: 182)
                        .offset(x: -96, y: -62)

                    Circle()
                        .stroke(Color(red: 0.94, green: 0.73, blue: 0.86), lineWidth: 1)
                        .frame(width: 168, height: 168)
                        .offset(x: 238, y: -36)

                    Circle()
                        .stroke(Color(red: 0.94, green: 0.73, blue: 0.86), lineWidth: 1)
                        .frame(width: 186, height: 186)
                        .offset(x: 250, y: 164)
                }
            )
            .clipShape(
                CrystalBlushUnevenRoundedRectangle(
                    topLeadingRadius: 30,
                    topTrailingRadius: 30
                )
            )
        }.ignoresSafeArea()
    }

    private func blushBloomCreateItem(
        imageName: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack(alignment: .bottomLeading) {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 106, height: 106)
                        .rotationEffect(.degrees(15))
                        .frame(width: 106, height: 120)
                        .background(
                            LinearGradient(colors: [
                                Color(red: 247/255, green: 238/255, blue: 247/255),
                                Color(red: 243/255, green: 214/255, blue: 231/255),
                                Color(red: 215/255, green: 247/255, blue: 229/255)
                            ], startPoint: .bottomLeading, endPoint: .topTrailing)
                            .clipShape(RoundedRectangle(cornerRadius: 17))
                        )

                    Capsule()
                        .fill(GlowMuseTheme.velvetAuraAccentGradient)
                        .frame(width: 58, height: 34)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 17, weight: .light))
                                .foregroundStyle(.white)
                        )
                        .offset(x: -8, y: 6)
                }
                

                Text(title)
                    .font(GlowMuseTheme.blushBloomSerifFont(size: 15, weight: .black))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 110)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

private struct RougeRibbonCreatePublishSheetPreviewHost: View {
    var body: some View {
        ZStack {
            HoneyGlowHomeView()
            RougeRibbonCreatePublishSheet()
        }
    }
}

#Preview {
    RougeRibbonCreatePublishSheetPreviewHost()
}
