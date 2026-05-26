import SwiftUI

struct VelvetAuraCommunityView: View {
    @Environment(\.crystalBlushRouter) private var velvetAuraRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    @State private var velvetAuraFeedMode: VelvetAuraCommunityFeedMode = .forYou
    @State private var velvetAuraCurrentUser: BlushBloomUserModel?
    @State private var velvetAuraAllUsers: [BlushBloomUserModel] = []
    @State private var velvetAuraAllPosts: [VelvetAuraPostModel] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("COMMUNITY")
                .font(GlowMuseTheme.blushBloomSerifFont(size: 19, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                .padding(.top, 60)
                .padding(.horizontal, 20)

            velvetAuraModeSwitcher

            velvetAuraUserStrip

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 18) {
                    if velvetAuraVisiblePosts.isEmpty {
                        velvetAuraEmptyState
                    } else {
                        ForEach(velvetAuraVisiblePosts) { velvetAuraPost in
                            SilkGlowPostCardView(
                                silkGlowPost: velvetAuraPost,
                                silkGlowPublisher: velvetAuraPublisher(for: velvetAuraPost),
                                silkGlowIsLiked: velvetAuraIsPostLiked(velvetAuraPost),
                                silkGlowOpenAction: {
                                    velvetAuraRouter?.push(.silkBloomPostDetail(postID: velvetAuraPost.velvetAuraPostID))
                                },
                                silkGlowLikeAction: {
                                    PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                                        velvetAuraToggleLike(for: velvetAuraPost)
                                    }
                                }
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            velvetAuraLoadCommunityData()
        }
    }

    private var velvetAuraModeSwitcher: some View {
        HStack(spacing: 18) {
            ForEach(VelvetAuraCommunityFeedMode.allCases, id: \.self) { velvetAuraMode in
                PetalLuxeButton(
                    title: velvetAuraMode.title,
                    style: .segmented(isSelected: velvetAuraFeedMode == velvetAuraMode),
                    height: 46
                ) {
                    velvetAuraFeedMode = velvetAuraMode
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
    }

    private var velvetAuraUserStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                if velvetAuraVisibleUsers.isEmpty {
                    Text(velvetAuraFeedMode.emptyUserText)
                        .font(GlowMuseTheme.blushBloomBodyFont(size: 13))
                        .foregroundStyle(GlowMuseTheme.blushBloomMutedText)
                        .frame(height: 78)
                } else {
                    ForEach(velvetAuraVisibleUsers) { velvetAuraUser in
                        Button {
                            velvetAuraRouter?.push(.moonPetalUserProfile(userID: velvetAuraUser.blushBloomUserID))
                        } label: {
                            VStack(spacing: 8) {
                                CrystalBlushUniversalImage(
                                    velvetAuraUser.blushBloomAvatar,
                                    contentMode: .fill,
                                    fallbackSystemName: "person.crop.circle.fill"
                                )
                                .frame(width: 58, height: 58)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.9), lineWidth: 2)
                                )

                                Text(velvetAuraShortName(velvetAuraUser.blushBloomUserName))
                                    .font(GlowMuseTheme.blushBloomBodyFont(size: 13))
                                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                                    .lineLimit(1)
                            }
                            .frame(width: 64)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }

    private var velvetAuraEmptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)

            Text(velvetAuraFeedMode.emptyPostText)
                .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                .foregroundStyle(GlowMuseTheme.blushBloomMutedText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 190)
        .background(GlowMuseTheme.silkBloomSurfaceFill.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 20)
    }

    private var velvetAuraVisibleUsers: [BlushBloomUserModel] {
        guard let velvetAuraCurrentUser else {
            return []
        }

        let velvetAuraBlockedIDs = Set(velvetAuraCurrentUser.blushBloomBlockedIDs)

        switch velvetAuraFeedMode {
        case .forYou:
            return velvetAuraAllUsers.filter { velvetAuraUser in
                velvetAuraUser.blushBloomUserID != velvetAuraCurrentUser.blushBloomUserID
                    && velvetAuraUser.blushBloomIsGuest == false
                    && velvetAuraBlockedIDs.contains(velvetAuraUser.blushBloomUserID) == false
            }

        case .follow:
            let velvetAuraFollowingIDs = Set(velvetAuraCurrentUser.blushBloomFollowingIDs)
            return velvetAuraAllUsers.filter { velvetAuraUser in
                velvetAuraFollowingIDs.contains(velvetAuraUser.blushBloomUserID)
                    && velvetAuraBlockedIDs.contains(velvetAuraUser.blushBloomUserID) == false
            }
        }
    }

    private var velvetAuraVisiblePosts: [VelvetAuraPostModel] {
        guard let velvetAuraCurrentUser else {
            return []
        }

        let velvetAuraBlockedIDs = Set(velvetAuraCurrentUser.blushBloomBlockedIDs)

        switch velvetAuraFeedMode {
        case .forYou:
            return velvetAuraAllPosts.filter { velvetAuraPost in
                velvetAuraBlockedIDs.contains(velvetAuraPost.velvetAuraPublisherID) == false
            }

        case .follow:
            let velvetAuraFollowingIDs = Set(velvetAuraCurrentUser.blushBloomFollowingIDs)
            return velvetAuraAllPosts.filter { velvetAuraPost in
                velvetAuraFollowingIDs.contains(velvetAuraPost.velvetAuraPublisherID)
                    && velvetAuraBlockedIDs.contains(velvetAuraPost.velvetAuraPublisherID) == false
            }
        }
    }

    private func velvetAuraLoadCommunityData() {
        do {
            let velvetAuraDataCenter = RadiantDewLocalDataCenter.shared
            let velvetAuraUsers = try velvetAuraDataCenter.radiantDewUsers.readAll()
            velvetAuraAllUsers = velvetAuraUsers
            velvetAuraAllPosts = try velvetAuraDataCenter.radiantDewPosts.readAll()

            if let velvetAuraCurrentUserID = SilkBloomLoginSessionStore.currentUserID {
                velvetAuraCurrentUser = velvetAuraUsers.first { $0.blushBloomUserID == velvetAuraCurrentUserID }
            } else {
                velvetAuraCurrentUser = nil
            }
        } catch {
            roseMistOverlayCenter.showToast("Community data failed to load.", style: .error)
        }
    }

    private func velvetAuraPublisher(for velvetAuraPost: VelvetAuraPostModel) -> BlushBloomUserModel? {
        velvetAuraAllUsers.first { $0.blushBloomUserID == velvetAuraPost.velvetAuraPublisherID }
    }

    private func velvetAuraIsPostLiked(_ velvetAuraPost: VelvetAuraPostModel) -> Bool {
        velvetAuraCurrentUser?.blushBloomLikedPostIDs.contains(velvetAuraPost.velvetAuraPostID) == true
    }

    private func velvetAuraToggleLike(for velvetAuraPost: VelvetAuraPostModel) {
        guard var velvetAuraCurrentUser else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        do {
            var velvetAuraUpdatedPost = velvetAuraPost

            if let velvetAuraLikedIndex = velvetAuraCurrentUser.blushBloomLikedPostIDs.firstIndex(of: velvetAuraPost.velvetAuraPostID) {
                velvetAuraCurrentUser.blushBloomLikedPostIDs.remove(at: velvetAuraLikedIndex)
                velvetAuraUpdatedPost.velvetAuraLikeCount = max(0, velvetAuraPost.velvetAuraLikeCount - 1)
            } else {
                velvetAuraCurrentUser.blushBloomLikedPostIDs.append(velvetAuraPost.velvetAuraPostID)
                velvetAuraUpdatedPost.velvetAuraLikeCount = velvetAuraPost.velvetAuraLikeCount + 1
            }

            try RadiantDewLocalDataCenter.shared.radiantDewUsers.update(velvetAuraCurrentUser)
            try RadiantDewLocalDataCenter.shared.radiantDewPosts.update(velvetAuraUpdatedPost)

            self.velvetAuraCurrentUser = velvetAuraCurrentUser
            if let velvetAuraPostIndex = velvetAuraAllPosts.firstIndex(where: { $0.velvetAuraPostID == velvetAuraPost.velvetAuraPostID }) {
                velvetAuraAllPosts[velvetAuraPostIndex] = velvetAuraUpdatedPost
            }
        } catch {
            roseMistOverlayCenter.showToast("Like update failed.", style: .error)
        }
    }

    private func velvetAuraShortName(_ velvetAuraName: String) -> String {
        if velvetAuraName.count > 7 {
            return "\(velvetAuraName.prefix(5))..."
        }

        return velvetAuraName
    }
}

private enum VelvetAuraCommunityFeedMode: CaseIterable {
    case forYou
    case follow

    var title: String {
        switch self {
        case .forYou:
            return "FOR YOU"
        case .follow:
            return "FOLLOW"
        }
    }

    var emptyUserText: String {
        switch self {
        case .forYou:
            return "No beauty friends yet."
        case .follow:
            return "Follow someone to see them here."
        }
    }

    var emptyPostText: String {
        switch self {
        case .forYou:
            return "No community posts yet."
        case .follow:
            return "No posts from followed users yet."
        }
    }
}

#Preview {
    ZStack {
        RougeRibbonGuideBackground()
        VelvetAuraCommunityView()
            .padding(.bottom, 92)
            .environmentObject(RoseMistOverlayCenter())
    }
}
