import SwiftUI

struct MoonPetalUserProfileView: View {
    @Environment(\.crystalBlushRouter) private var moonPetalRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    let moonPetalUserID: String

    @State private var moonPetalUser: BlushBloomUserModel?
    @State private var moonPetalCurrentUser: BlushBloomUserModel?
    @State private var moonPetalUsers: [BlushBloomUserModel] = []
    @State private var moonPetalPosts: [VelvetAuraPostModel] = []
    @State private var moonPetalShowsModerationSheet = false

    init(moonPetalUserID: String = "") {
        self.moonPetalUserID = moonPetalUserID
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            GlowMuseTheme.blushBloomPrimaryText
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    GeometryReader { geo in
                        Image("VENNECGuideBg")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                    }
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            moonPetalProfileContent
                        }
                    }
                    moonPetalTopBar
                }
                .clipShape(CrystalBlushUnevenRoundedRectangle(bottomLeadingRadius: 52))
                .ignoresSafeArea()

                if moonPetalIsViewingSelf == false {
                    moonPetalActionBar
                }
            }

            if moonPetalShowsModerationSheet {
                HoneyVelvetModerationSheet(
                    honeyVelvetTargetUserID: moonPetalUserID,
                    honeyVelvetOnClose: {
                        moonPetalShowsModerationSheet = false
                    }
                )
            }
        }
        .onAppear {
            moonPetalLoadProfileData()
        }
    }

    private var moonPetalTopBar: some View {
        HStack {
            Button {
                moonPetalRouter?.pop()
            } label: {
                Image("VENNECNavBack")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
            }
            .buttonStyle(.plain)

            Spacer()

            if moonPetalIsViewingSelf == false {
                Button {
                    PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                        moonPetalShowsModerationSheet = true
                    }
                } label: {
                    Image("VENNEIconMore")
                        .resizable()
                        .frame(width: 52, height: 52)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 60)
    }


    private var moonPetalProfileContent: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                CrystalBlushUniversalImage(
                    moonPetalUser?.blushBloomAvatar ?? "VENNEAppLogo",
                    contentMode: .fill,
                    fallbackSystemName: "person.crop.circle.fill"
                )
                .frame(width: 66, height: 66)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.92), lineWidth: 3)
                )

                Text(moonPetalShortName(moonPetalUser?.blushBloomUserName ?? "Venne"))
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 15))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
            }.padding(.top, 130)

            HStack {
                MoonPetalProfileMetricView(value: "\(moonPetalVisiblePosts.count)", title: "Post")
                Spacer()
                MoonPetalProfileMetricView(value: "\(moonPetalUser?.blushBloomFanIDs.count ?? 0)", title: "Fans")
                Spacer()
                MoonPetalProfileMetricView(value: "\(moonPetalUser?.blushBloomFollowingIDs.count ?? 0)", title: "Following")
            }
            .padding(.horizontal, 36)
            .padding(.top, 8)

            HStack {
                Text("POST")
                    .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .bold))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)

            LazyVStack(spacing: 18) {
                if moonPetalVisiblePosts.isEmpty {
                    moonPetalEmptyPostState
                } else {
                    ForEach(moonPetalVisiblePosts) { moonPetalPost in
                        SilkGlowPostCardView(
                            silkGlowPost: moonPetalPost,
                            silkGlowPublisher: moonPetalUser,
                            silkGlowIsLiked: moonPetalCurrentUser?.blushBloomLikedPostIDs.contains(moonPetalPost.velvetAuraPostID) == true,
                            silkGlowOpenAction: {
                                moonPetalRouter?.push(.silkBloomPostDetail(postID: moonPetalPost.velvetAuraPostID))
                            },
                            silkGlowLikeAction: {
                                PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                                    moonPetalToggleLike(for: moonPetalPost)
                                }
                            }
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.top, 18)
            .padding(.bottom, 120)
        }
    }

    private var moonPetalEmptyPostState: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)

            Text("No posts yet.")
                .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                .foregroundStyle(GlowMuseTheme.blushBloomMutedText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(GlowMuseTheme.silkBloomSurfaceFill.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 20)
    }

    private var moonPetalActionBar: some View {
        HStack(spacing: 14) {
            MoonPetalBottomActionButton(
                title: moonPetalIsFollowing ? "FOLLOWING" : "FOLLOW",
                icon: moonPetalIsFollowing ? "checkmark" : "plus",
                style: .secondary,
                action: {
                    PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                        moonPetalToggleFollow()
                    }
                }
            )

            MoonPetalBottomActionButton(
                title: "CHAT",
                imageName: "VENNECNavMessage",
                style: .primary,
                action: {
                    PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                        moonPetalOpenPrivateChat()
                    }
                }
            )
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 20)
        .background(GlowMuseTheme.blushBloomPrimaryText)
    }

    private var moonPetalVisiblePosts: [VelvetAuraPostModel] {
        guard let moonPetalProfileUserID = moonPetalUser?.blushBloomUserID else {
            return []
        }

        return moonPetalPosts.filter { $0.velvetAuraPublisherID == moonPetalProfileUserID }
    }

    private var moonPetalIsFollowing: Bool {
        guard let moonPetalTargetUserID = moonPetalUser?.blushBloomUserID else {
            return false
        }

        return moonPetalCurrentUser?.blushBloomFollowingIDs.contains(moonPetalTargetUserID) == true
    }

    private var moonPetalIsViewingSelf: Bool {
        moonPetalUser?.blushBloomUserID == moonPetalCurrentUser?.blushBloomUserID
    }

    private func moonPetalLoadProfileData() {
        do {
            let moonPetalDataCenter = RadiantDewLocalDataCenter.shared
            let moonPetalLoadedUsers = try moonPetalDataCenter.radiantDewUsers.readAll()
            moonPetalUsers = moonPetalLoadedUsers
            moonPetalPosts = try moonPetalDataCenter.radiantDewPosts.readAll()

            if let moonPetalCurrentUserID = SilkBloomLoginSessionStore.currentUserID {
                moonPetalCurrentUser = moonPetalLoadedUsers.first { $0.blushBloomUserID == moonPetalCurrentUserID }
            } else {
                moonPetalCurrentUser = nil
            }

            if moonPetalUserID.isEmpty {
                moonPetalUser = moonPetalLoadedUsers.first { $0.blushBloomUserID != moonPetalCurrentUser?.blushBloomUserID }
            } else {
                moonPetalUser = moonPetalLoadedUsers.first { $0.blushBloomUserID == moonPetalUserID }
            }
        } catch {
            roseMistOverlayCenter.showToast("User profile failed to load.", style: .error)
        }
    }

    private func moonPetalToggleFollow() {
        guard var moonPetalCurrentUser else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        guard var moonPetalTargetUser = moonPetalUser else {
            roseMistOverlayCenter.showToast("User profile failed to load.", style: .error)
            return
        }

        guard moonPetalCurrentUser.blushBloomUserID != moonPetalTargetUser.blushBloomUserID else {
            roseMistOverlayCenter.showToast("This is your own profile.", style: .normal)
            return
        }

        do {
            if let moonPetalFollowingIndex = moonPetalCurrentUser.blushBloomFollowingIDs.firstIndex(of: moonPetalTargetUser.blushBloomUserID) {
                moonPetalCurrentUser.blushBloomFollowingIDs.remove(at: moonPetalFollowingIndex)
                moonPetalTargetUser.blushBloomFanIDs.removeAll { $0 == moonPetalCurrentUser.blushBloomUserID }
                roseMistOverlayCenter.showToast("Unfollowed.", style: .normal)
            } else {
                moonPetalCurrentUser.blushBloomFollowingIDs.append(moonPetalTargetUser.blushBloomUserID)

                if moonPetalTargetUser.blushBloomFanIDs.contains(moonPetalCurrentUser.blushBloomUserID) == false {
                    moonPetalTargetUser.blushBloomFanIDs.append(moonPetalCurrentUser.blushBloomUserID)
                }

                roseMistOverlayCenter.showToast("Followed.", style: .success)
            }

            try RadiantDewLocalDataCenter.shared.radiantDewUsers.update(moonPetalCurrentUser)
            try RadiantDewLocalDataCenter.shared.radiantDewUsers.update(moonPetalTargetUser)

            self.moonPetalCurrentUser = moonPetalCurrentUser
            self.moonPetalUser = moonPetalTargetUser

            if let moonPetalCurrentIndex = moonPetalUsers.firstIndex(where: { $0.blushBloomUserID == moonPetalCurrentUser.blushBloomUserID }) {
                moonPetalUsers[moonPetalCurrentIndex] = moonPetalCurrentUser
            }

            if let moonPetalTargetIndex = moonPetalUsers.firstIndex(where: { $0.blushBloomUserID == moonPetalTargetUser.blushBloomUserID }) {
                moonPetalUsers[moonPetalTargetIndex] = moonPetalTargetUser
            }
        } catch {
            roseMistOverlayCenter.showToast("Follow update failed.", style: .error)
        }
    }

    private func moonPetalOpenPrivateChat() {
        guard let moonPetalCurrentUser else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        guard let moonPetalTargetUser = moonPetalUser else {
            roseMistOverlayCenter.showToast("User profile failed to load.", style: .error)
            return
        }

        guard moonPetalCurrentUser.blushBloomUserID != moonPetalTargetUser.blushBloomUserID else {
            roseMistOverlayCenter.showToast("This is your own profile.", style: .normal)
            return
        }

        guard moonPetalCanOpenMutualPrivateChat(
            currentUser: moonPetalCurrentUser,
            targetUser: moonPetalTargetUser
        ) else {
            roseMistOverlayCenter.showMutualFollowPrompt()
            return
        }

        do {
            let moonPetalRoomID = try moonPetalPrivateRoomID(
                currentUserID: moonPetalCurrentUser.blushBloomUserID,
                targetUserID: moonPetalTargetUser.blushBloomUserID
            )

            moonPetalRouter?.push(.honeyLuxePrivateChatRoom(roomID: moonPetalRoomID))
        } catch {
            roseMistOverlayCenter.showToast("Chat room failed to open.", style: .error)
        }
    }

    private func moonPetalCanOpenMutualPrivateChat(
        currentUser moonPetalCurrentUser: BlushBloomUserModel,
        targetUser moonPetalTargetUser: BlushBloomUserModel
    ) -> Bool {
        moonPetalCurrentUser.blushBloomFollowingIDs.contains(moonPetalTargetUser.blushBloomUserID)
            && moonPetalTargetUser.blushBloomFollowingIDs.contains(moonPetalCurrentUser.blushBloomUserID)
    }

    private func moonPetalPrivateRoomID(currentUserID moonPetalCurrentUserID: String, targetUserID moonPetalTargetUserID: String) throws -> String {
        let moonPetalRooms = try RadiantDewLocalDataCenter.shared.radiantDewChatRooms.readAll()
        let moonPetalMemberSet = Set([moonPetalCurrentUserID, moonPetalTargetUserID])

        if let moonPetalExistingRoom = moonPetalRooms.first(where: { moonPetalRoom in
            moonPetalRoom.moonPetalIsGroupChat == false
                && Set(moonPetalRoom.moonPetalUserIDs) == moonPetalMemberSet
                && moonPetalRoom.moonPetalUserIDs.count == 2
        }) {
            return moonPetalExistingRoom.moonPetalRoomID
        }

        let moonPetalRoom = MoonPetalChatRoomModel(
            moonPetalRoomID: "room_private_\(moonPetalCurrentUserID)_\(moonPetalTargetUserID)_\(UUID().uuidString)",
            moonPetalUserIDs: [moonPetalCurrentUserID, moonPetalTargetUserID],
            moonPetalLastMessageSentAt: Date(),
            moonPetalLastSenderID: moonPetalCurrentUserID,
            moonPetalLastMessageText: "",
            moonPetalUnreadMessageCount: 0,
            moonPetalIsGroupChat: false,
            moonPetalGroupCoverImage: "",
            moonPetalGroupRoomName: "",
            moonPetalGroupRoomIntro: ""
        )

        try RadiantDewLocalDataCenter.shared.radiantDewChatRooms.create(moonPetalRoom)
        return moonPetalRoom.moonPetalRoomID
    }

    private func moonPetalToggleLike(for moonPetalPost: VelvetAuraPostModel) {
        guard var moonPetalCurrentUser else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        do {
            var moonPetalUpdatedPost = moonPetalPost

            if let moonPetalLikedIndex = moonPetalCurrentUser.blushBloomLikedPostIDs.firstIndex(of: moonPetalPost.velvetAuraPostID) {
                moonPetalCurrentUser.blushBloomLikedPostIDs.remove(at: moonPetalLikedIndex)
                moonPetalUpdatedPost.velvetAuraLikeCount = max(0, moonPetalPost.velvetAuraLikeCount - 1)
            } else {
                moonPetalCurrentUser.blushBloomLikedPostIDs.append(moonPetalPost.velvetAuraPostID)
                moonPetalUpdatedPost.velvetAuraLikeCount = moonPetalPost.velvetAuraLikeCount + 1
            }

            try RadiantDewLocalDataCenter.shared.radiantDewUsers.update(moonPetalCurrentUser)
            try RadiantDewLocalDataCenter.shared.radiantDewPosts.update(moonPetalUpdatedPost)

            self.moonPetalCurrentUser = moonPetalCurrentUser
            if let moonPetalPostIndex = moonPetalPosts.firstIndex(where: { $0.velvetAuraPostID == moonPetalPost.velvetAuraPostID }) {
                moonPetalPosts[moonPetalPostIndex] = moonPetalUpdatedPost
            }
        } catch {
            roseMistOverlayCenter.showToast("Like update failed.", style: .error)
        }
    }

    private func moonPetalShortName(_ moonPetalName: String) -> String {
        if moonPetalName.count > 7 {
            return "\(moonPetalName.prefix(5))..."
        }

        return moonPetalName
    }
}

private struct MoonPetalProfileMetricView: View {
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
        }.frame(maxWidth: .infinity)
    }
}

private struct MoonPetalBottomActionButton: View {
    enum HoneyGlowStyle {
        case primary
        case secondary
    }

    let title: String
    var icon: String? = nil
    var imageName: String? = nil
    let style: HoneyGlowStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(iconColor)
                }

                if let imageName {
                    Image(imageName)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(iconColor)
                        .frame(width: 22, height: 22)
                }

                Text(title)
                    .font(GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .bold))
                    .foregroundStyle(textColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(backgroundStyle)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var textColor: Color {
        switch style {
        case .primary:
            .white
        case .secondary:
            .white.opacity(0.94)
        }
    }

    private var iconColor: Color {
        switch style {
        case .primary:
            .white
        case .secondary:
            GlowMuseTheme.honeyGlowLinkText
        }
    }

    @ViewBuilder
    private var backgroundStyle: some View {
        switch style {
        case .primary:
            GlowMuseTheme.velvetAuraAccentGradient
        case .secondary:
            Color.white.opacity(0.12)
        }
    }
}

#Preview {
    MoonPetalUserProfileView()
}
