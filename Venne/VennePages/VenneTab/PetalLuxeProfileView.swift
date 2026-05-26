import SwiftUI

struct PetalLuxeProfileView: View {
    @Environment(\.crystalBlushRouter) private var petalLuxeRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    @State private var petalLuxeCurrentUser: BlushBloomUserModel?
    @State private var petalLuxeMyPosts: [VelvetAuraPostModel] = []

    var body: some View {
        GeometryReader { petalLuxeGeo in
            petalLuxeContent(width: petalLuxeSafeWidth(petalLuxeGeo.size.width))
        }
        .onAppear {
            petalLuxeLoadProfileData()
        }
    }

    private func petalLuxeContent(width petalLuxeWidth: CGFloat) -> some View {
        ZStack(alignment: .top) {
            Image("VENNECGuideBg")
                .resizable()
                .scaledToFill()
                .frame(width: petalLuxeWidth, height: UIScreen.main.bounds.height)
                .ignoresSafeArea()
                .clipped()
            
            GeometryReader { _ in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        petalLuxeUserHeader
                        petalLuxeMetricsRow
                        petalLuxeWalletCard(width: petalLuxeWidth)
                        petalLuxePostSection(width: petalLuxeWidth)
                    }
                    .padding(.bottom, 128)
                }
            }
            

            HStack {
                Spacer()
                Button {
                    PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                        petalLuxeRouter?.push(.radiantDewSetting)
                    }
                } label: {
                    Image("VENNESetting")
                        .resizable()
                        .frame(width: 52, height: 52)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 20)
            }
            .padding(.top, 60)
        }
    }

    private var petalLuxeUserHeader: some View {
        Button {
            PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                petalLuxeRouter?.push(.velvetAuraEditProfile)
            }
        } label: {
            VStack(spacing: 10) {
                ZStack(alignment: .bottomTrailing) {
                    CrystalBlushUniversalImage(
                        petalLuxeAvatarAddress,
                        contentMode: .fill,
                        fallbackSystemName: "person.crop.circle.fill"
                    )
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.92), lineWidth: 2))

                    Circle()
                        .fill(GlowMuseTheme.blushBloomPrimaryText.opacity(0.86))
                        .frame(width: 22, height: 22)
                        .overlay(
                            Image(systemName: "pencil")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.white)
                        )
                        .offset(x: 4, y: 2)
                }

                Text(petalLuxeDisplayName)
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 15))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 130)
    }

    private var petalLuxeMetricsRow: some View {
        HStack {
            PetalLuxeProfileMetricView(value: "\(petalLuxeMyPosts.count)", title: "Post")
                .frame(maxWidth: .infinity)
            Spacer()
            Button {
                PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                    petalLuxeRouter?.push(.crystalBlushFans)
                }
            } label: {
                PetalLuxeProfileMetricView(value: "\(petalLuxeCurrentUser?.blushBloomFanIDs.count ?? 0)", title: "Fans")
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            Spacer()
            Button {
                PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                    petalLuxeRouter?.push(.blushBloomFollow)
                }
            } label: {
                PetalLuxeProfileMetricView(value: "\(petalLuxeCurrentUser?.blushBloomFollowingIDs.count ?? 0)", title: "Following")
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 40)
        .padding(.top, 44)
    }

    private func petalLuxeWalletCard(width petalLuxeWidth: CGFloat) -> some View {
        Button {
            PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                petalLuxeRouter?.push(.silkBloomRecharge)
            }
        } label: {
            Image("VENNEWalletBg")
                .resizable()
                .frame(width: max(0, petalLuxeWidth - 40), height: 92)
                .overlay(
                    HStack(spacing: 0) {
                        Image("VENNEDiamond")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .padding(.leading, 28)
                            .padding(.trailing, 48)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("MY WALLET")
                                .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                            Text("\(petalLuxeCurrentUser?.blushBloomCoinCount ?? 0)")
                                .font(GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .padding(.leading, 14)

                        Spacer()

                        Circle()
                            .fill(Color.white.opacity(0.28))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image("VENNECSettingArrow")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundStyle(.white)
                                    .frame(width: 16, height: 16)
                            )
                            .padding(.trailing, 18)
                    }
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 28)
    }

    private func petalLuxePostSection(width petalLuxeWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("POST")
                .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .bold))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                .padding(.horizontal, 20)

            if petalLuxeMyPosts.isEmpty {
                petalLuxeEmptyPostState(width: petalLuxeWidth)
            } else {
                LazyVStack(spacing: 18) {
                    ForEach(petalLuxeMyPosts) { petalLuxePost in
                        SilkGlowPostCardView(
                            silkGlowPost: petalLuxePost,
                            silkGlowPublisher: petalLuxeCurrentUser,
                            silkGlowIsLiked: petalLuxeIsPostLiked(petalLuxePost),
                            silkGlowOpenAction: {
                                petalLuxeRouter?.push(.silkBloomPostDetail(postID: petalLuxePost.velvetAuraPostID))
                            },
                            silkGlowLikeAction: {
                                PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                                    petalLuxeToggleLike(for: petalLuxePost)
                                }
                            }
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .padding(.top, 26)
    }

    private func petalLuxeEmptyPostState(width petalLuxeWidth: CGFloat) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)

            Text("No posts yet.")
                .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                .foregroundStyle(GlowMuseTheme.blushBloomMutedText)
        }
        .frame(width: max(0, petalLuxeWidth - 40), height: 160)
        .background(GlowMuseTheme.silkBloomSurfaceFill.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 20)
    }

    private func petalLuxeSafeWidth(_ petalLuxeWidth: CGFloat) -> CGFloat {
        guard petalLuxeWidth.isFinite, petalLuxeWidth > 0 else {
            return UIScreen.main.bounds.width
        }

        return petalLuxeWidth
    }

    private var petalLuxeAvatarAddress: String {
        let petalLuxeAvatar = petalLuxeCurrentUser?.blushBloomAvatar.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return petalLuxeAvatar.isEmpty ? "VENNEAppLogo" : petalLuxeAvatar
    }

    private var petalLuxeDisplayName: String {
        let petalLuxeName = petalLuxeCurrentUser?.blushBloomUserName.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return petalLuxeName.isEmpty ? "Venne User" : petalLuxeName
    }

    private func petalLuxeLoadProfileData() {
        do {
            guard let petalLuxeCurrentUserID = SilkBloomLoginSessionStore.currentUserID else {
                petalLuxeCurrentUser = nil
                petalLuxeMyPosts = []
                return
            }

            let petalLuxeDataCenter = RadiantDewLocalDataCenter.shared
            let petalLuxeUsers = try petalLuxeDataCenter.radiantDewUsers.readAll()
            let petalLuxePosts = try petalLuxeDataCenter.radiantDewPosts.readAll()

            petalLuxeCurrentUser = petalLuxeUsers.first { $0.blushBloomUserID == petalLuxeCurrentUserID }
            petalLuxeMyPosts = petalLuxePosts.filter { $0.velvetAuraPublisherID == petalLuxeCurrentUserID }
        } catch {
            roseMistOverlayCenter.showToast("Profile data failed to load.", style: .error)
        }
    }

    private func petalLuxeIsPostLiked(_ petalLuxePost: VelvetAuraPostModel) -> Bool {
        petalLuxeCurrentUser?.blushBloomLikedPostIDs.contains(petalLuxePost.velvetAuraPostID) == true
    }

    private func petalLuxeToggleLike(for petalLuxePost: VelvetAuraPostModel) {
        guard var petalLuxeCurrentUser else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        do {
            var petalLuxeUpdatedPost = petalLuxePost

            if let petalLuxeLikedIndex = petalLuxeCurrentUser.blushBloomLikedPostIDs.firstIndex(of: petalLuxePost.velvetAuraPostID) {
                petalLuxeCurrentUser.blushBloomLikedPostIDs.remove(at: petalLuxeLikedIndex)
                petalLuxeUpdatedPost.velvetAuraLikeCount = max(0, petalLuxePost.velvetAuraLikeCount - 1)
            } else {
                petalLuxeCurrentUser.blushBloomLikedPostIDs.append(petalLuxePost.velvetAuraPostID)
                petalLuxeUpdatedPost.velvetAuraLikeCount = petalLuxePost.velvetAuraLikeCount + 1
            }

            try RadiantDewLocalDataCenter.shared.radiantDewUsers.update(petalLuxeCurrentUser)
            try RadiantDewLocalDataCenter.shared.radiantDewPosts.update(petalLuxeUpdatedPost)

            self.petalLuxeCurrentUser = petalLuxeCurrentUser
            if let petalLuxePostIndex = petalLuxeMyPosts.firstIndex(where: { $0.velvetAuraPostID == petalLuxePost.velvetAuraPostID }) {
                petalLuxeMyPosts[petalLuxePostIndex] = petalLuxeUpdatedPost
            }
        } catch {
            roseMistOverlayCenter.showToast("Like update failed.", style: .error)
        }
    }
}

private struct PetalLuxeProfileMetricView: View {
    let value: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(GlowMuseTheme.blushBloomSerifFont(size: 17, weight: .bold))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
            Text(title)
                .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
        }
    }
}

#Preview {
    ZStack {
        RougeRibbonGuideBackground()
        PetalLuxeProfileView()
            .padding(.bottom, 92)
            .environmentObject(RoseMistOverlayCenter())
    }
}
