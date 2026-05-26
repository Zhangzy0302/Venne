import SwiftUI

struct SilkGlowPostCardView: View {
    let silkGlowPost: VelvetAuraPostModel
    let silkGlowPublisher: BlushBloomUserModel?
    var silkGlowHeight: CGFloat = 374
    var silkGlowIsLiked = false
    var silkGlowOpenAction: () -> Void = {}
    var silkGlowLikeAction: () -> Void = {}

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { silkGlowGeo in
                CrystalBlushUniversalImage(
                    silkGlowCoverImageName,
                    contentMode: .fill,
                    fallbackSystemName: "photo.fill"
                )
                .frame(width: silkGlowGeo.size.width, height: silkGlowHeight)
                .clipped()
            }

            LinearGradient(
                colors: [
                    Color.black.opacity(0.08),
                    Color.black.opacity(0.04),
                    Color.black.opacity(0.52)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    Color(red: 198 / 255, green: 137 / 255, blue: 165 / 255).opacity(0.92),
                    Color(red: 198 / 255, green: 137 / 255, blue: 165 / 255).opacity(0)
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 118)

            VStack(spacing: 0) {
                HStack {
                    silkGlowPublisherBadge
                    Spacer()
                }
                .padding(.top, 18)
                .padding(.horizontal, 16)

                Spacer()

                HStack {
                    silkGlowPagerDots

                    Spacer()

                    HStack(spacing: 12) {
                        silkGlowLikeButton
                        silkGlowCircleAction(imageName: "VENNECNavMessage")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                HStack {
                    Text(silkGlowPost.velvetAuraCopywritingContent)
                        .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                        .foregroundStyle(.white.opacity(0.96))
                        .lineLimit(1)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 18)
            }
        }
        .frame(height: silkGlowHeight)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onTapGesture(perform: silkGlowOpenAction)
    }

    private var silkGlowPublisherBadge: some View {
        HStack(spacing: 8) {
            CrystalBlushUniversalImage(
                silkGlowPublisher?.blushBloomAvatar ?? "VENNEAppLogo",
                contentMode: .fill,
                fallbackSystemName: "person.crop.circle.fill"
            )
            .frame(width: 20, height: 20)
            .clipShape(Circle())

            Text(silkGlowPublisherName)
                .font(GlowMuseTheme.blushBloomBodyFont(size: 13))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .frame(height: 30)
        .background(Color.white.opacity(0.82))
        .clipShape(Capsule())
    }

    private var silkGlowPagerDots: some View {
        HStack(spacing: 5) {
            Capsule()
                .fill(Color.white)
                .frame(width: 28, height: 8)

            ForEach(0..<max(0, min(silkGlowPost.velvetAuraImageList.count - 1, 3)), id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(0.65))
                    .frame(width: 8, height: 8)
            }
        }
    }

    private func silkGlowCircleAction(imageName: String) -> some View {
        Circle()
            .fill(Color.black.opacity(0.82))
            .frame(width: 48, height: 48)
            .overlay {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
    }

    private var silkGlowLikeButton: some View {
        Button(action: silkGlowLikeAction) {
            Circle()
                .fill(Color.black.opacity(0.82))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: silkGlowIsLiked ? "heart.fill" : "heart")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(silkGlowIsLiked ? GlowMuseTheme.honeyGlowLinkText : Color.white)
                }
        }
        .buttonStyle(.plain)
    }

    private var silkGlowCoverImageName: String {
        silkGlowPost.velvetAuraImageList.first ?? "VENNEAppLogo"
    }

    private var silkGlowPublisherName: String {
        guard let silkGlowPublisher else {
            return "Venne..."
        }

        if silkGlowPublisher.blushBloomUserName.count > 8 {
            return "\(silkGlowPublisher.blushBloomUserName.prefix(6))..."
        }

        return silkGlowPublisher.blushBloomUserName
    }
}

#Preview {
    SilkGlowPostCardView(
        silkGlowPost: VelvetAuraPostModel(
            velvetAuraPostID: "preview_post",
            velvetAuraPublisherID: "preview_user",
            velvetAuraImageList: ["VAOIVPost_3"],
            velvetAuraCopywritingContent: "Just wrapped up today's shoot.",
            velvetAuraLikeCount: 103
        ),
        silkGlowPublisher: BlushBloomUserModel(
            blushBloomUserID: "preview_user",
            blushBloomEmail: "preview@venne.local",
            blushBloomPassword: "123456",
            blushBloomAvatar: "VEOPWAva_1",
            blushBloomUserName: "Sophi",
            blushBloomBirthdayDate: Date(),
            blushBloomLocation: "LA",
            blushBloomGender: "Female",
            blushBloomFanIDs: [],
            blushBloomFollowingIDs: [],
            blushBloomBlockedIDs: [],
            blushBloomCoinCount: 0,
            blushBloomIsGuest: false
        )
    )
    .padding()
    .background(RougeRibbonGuideBackground())
}
