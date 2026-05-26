import SwiftUI

struct SilkBloomPostDetailView: View {
    @Environment(\.crystalBlushRouter) private var silkBloomRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    let silkBloomPostID: String

    @State private var silkBloomPost: VelvetAuraPostModel?
    @State private var silkBloomPublisher: BlushBloomUserModel?
    @State private var silkBloomCurrentUser: BlushBloomUserModel?
    @State private var silkBloomComments: [HoneyGlowCommentModel] = []
    @State private var silkBloomUsers: [BlushBloomUserModel] = []
    @State private var silkBloomCommentText = ""
    @State private var silkBloomSelectedImageIndex = 0
    @State private var silkBloomShowsModerationSheet = false
    @FocusState private var silkBloomCommentFocused: Bool

    init(silkBloomPostID: String = "post_blush_002") {
        self.silkBloomPostID = silkBloomPostID
    }

    var body: some View {
        ZStack(alignment: .top) {
            GlowMuseTheme.blushBloomPrimaryText
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    RougeRibbonGuideBackground()
                        .ignoresSafeArea()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            silkBloomHeroSection
                            silkBloomCaptionSection
                        }
                    }
                }
                .clipShape(
                    CrystalBlushUnevenRoundedRectangle(
                        bottomLeadingRadius: 40,
                        bottomTrailingRadius: 0
                    )
                )

                silkBloomCommentComposer
            }
            .ignoresSafeArea(edges: .top)

            HStack {
                silkBloomChromeCircleButton(imageName: "VENNECNavBack")
                Spacer()
                if silkBloomCanShowMoreButton {
                    silkBloomChromeCircleButton(imageName: "VENNEIconMore")
                }
            }
            .padding(.top, 12)
            .padding(.horizontal, 18)

            if silkBloomShowsModerationSheet,
               let silkBloomTargetUserID = silkBloomPublisher?.blushBloomUserID {
                HoneyVelvetModerationSheet(
                    honeyVelvetTargetUserID: silkBloomTargetUserID,
                    honeyVelvetOnClose: {
                        silkBloomShowsModerationSheet = false
                    }
                )
            }
        }
        .onAppear {
            silkBloomLoadPostDetail()
        }
        .onTapGesture {
            silkBloomCommentFocused = false
        }
    }

    @ViewBuilder
    private var silkBloomHeroSection: some View {
        GeometryReader { silkBloomGeo in
            ZStack(alignment: .bottom) {
                TabView(selection: $silkBloomSelectedImageIndex) {
                    ForEach(Array(silkBloomHeroImages.enumerated()), id: \.offset) { silkBloomIndex, silkBloomImageAddress in
                        CrystalBlushUniversalImage(
                            silkBloomImageAddress,
                            contentMode: .fill,
                            fallbackSystemName: "photo.fill"
                        )
                        .frame(width: silkBloomGeo.size.width, height: silkBloomGeo.size.height)
                        .clipped()
                        .tag(silkBloomIndex)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                if silkBloomHeroImages.count > 1 {
                    silkBloomHeroPageIndicator
                        .padding(.bottom, 18)
                }
            }
        }
        .frame(height: 468)
        .clipShape(
            CrystalBlushUnevenRoundedRectangle(
                bottomLeadingRadius: 40,
                bottomTrailingRadius: 40
            )
        )
    }

    private var silkBloomHeroPageIndicator: some View {
        HStack(spacing: 7) {
            ForEach(silkBloomHeroImages.indices, id: \.self) { silkBloomIndex in
                Capsule()
                    .fill(silkBloomSelectedImageIndex == silkBloomIndex ? Color.white : Color.white.opacity(0.55))
                    .frame(
                        width: silkBloomSelectedImageIndex == silkBloomIndex ? 26 : 8,
                        height: 8
                    )
                    .animation(.easeInOut(duration: 0.2), value: silkBloomSelectedImageIndex)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.16))
        .clipShape(Capsule())
    }

    private var silkBloomCaptionSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            silkBloomPublisherBadge

            Text(silkBloomPost?.velvetAuraCopywritingContent ?? "This post is no longer available.")
                .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                .lineSpacing(1.5)

            Text("\(silkBloomComments.count) COMMENTS")
                .font(GlowMuseTheme.blushBloomSerifFont(size: 15, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

            LazyVStack(alignment: .leading, spacing: 14) {
                ForEach(silkBloomComments) { silkBloomComment in
                    silkBloomCommentRow(silkBloomComment)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 128)
    }

    private var silkBloomPublisherBadge: some View {
        HStack(spacing: 8) {
            CrystalBlushUniversalImage(
                silkBloomPublisher?.blushBloomAvatar ?? "VENNEAppLogo",
                contentMode: .fill,
                fallbackSystemName: "person.crop.circle.fill"
            )
            .frame(width: 22, height: 22)
            .clipShape(Circle())

            Text(silkBloomShortName(silkBloomPublisher?.blushBloomUserName ?? "Venne"))
                .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 6)
        .frame(width: 92, height: 32)
        .background(Color.white.opacity(0.92))
        .clipShape(Capsule())
        .onTapGesture {
            if let postUserId = silkBloomPost?.velvetAuraPublisherID {
                silkBloomRouter?.push(.moonPetalUserProfile(userID: postUserId))
            }
            
        }
    }

    private func silkBloomCommentRow(_ silkBloomComment: HoneyGlowCommentModel) -> some View {
        let silkBloomCommentUser = silkBloomUsers.first { $0.blushBloomUserID == silkBloomComment.honeyGlowPublisherID }

        return VStack(alignment: .leading) {
            HStack(spacing: 12) {
                Button {
                    silkBloomRouter?.push(.moonPetalUserProfile(userID: silkBloomComment.honeyGlowPublisherID))
                } label: {
                    CrystalBlushUniversalImage(
                        silkBloomCommentUser?.blushBloomAvatar ?? "VENNEAppLogo",
                        contentMode: .fill,
                        fallbackSystemName: "person.crop.circle.fill"
                    )
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 1))
                }
                .buttonStyle(.plain)

                Text(silkBloomShortName(silkBloomCommentUser?.blushBloomUserName ?? "Venne"))
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
            }

            Text(silkBloomComment.honeyGlowContent)
                .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                .padding(12)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.leading, 48)
        }
        .padding(.trailing, 20)
    }

    private var silkBloomCommentComposer: some View {
        HStack(spacing: 16) {
            HStack {
                TextField("", text: $silkBloomCommentText, prompt:
                            Text("Say something....")
                                .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                                .foregroundColor(.white.opacity(0.4)))
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                    .foregroundStyle(.white)
                    .tint(GlowMuseTheme.velvetAuraCursorTint)
                    .focused($silkBloomCommentFocused)
                    .padding(.horizontal, 14)
                    .disabled(silkBloomCurrentUser?.blushBloomIsGuest == true)

                silkBloomComposerActionButton(
                    background: AnyShapeStyle(GlowMuseTheme.velvetAuraAccentGradient),
                    image: AnyView(
                        Image("VENNESendIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    ),
                    action: silkBloomSendComment
                )
            }
            .frame(height: 48)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())

            silkBloomComposerActionButton(
                background: AnyShapeStyle(Color.white.opacity(0.14)),
                image: AnyView(
                    Image(systemName: silkBloomIsLiked ? "heart.fill" : "heart")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(silkBloomIsLiked ? GlowMuseTheme.honeyGlowLinkText : Color.white)
                ),
                action: silkBloomToggleLike
            )
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(GlowMuseTheme.blushBloomPrimaryText)
    }

    private func silkBloomChromeCircleButton(imageName: String) -> some View {
        Button {
            if imageName == "VENNECNavBack" {
                silkBloomRouter?.pop()
            } else if imageName == "VENNEIconMore" {
                PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                    silkBloomShowsModerationSheet = true
                }
            }
        } label: {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
        }
        .buttonStyle(.plain)
    }

    private func silkBloomComposerActionButton(
        background: AnyShapeStyle,
        image: AnyView,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Circle()
                .fill(background)
                .frame(width: 48, height: 48)
                .overlay(image)
        }
        .buttonStyle(.plain)
    }

    private var silkBloomIsLiked: Bool {
        guard let silkBloomPost else {
            return false
        }

        return silkBloomCurrentUser?.blushBloomLikedPostIDs.contains(silkBloomPost.velvetAuraPostID) == true
    }

    private var silkBloomCanShowMoreButton: Bool {
        guard let silkBloomPublisherID = silkBloomPublisher?.blushBloomUserID,
              let silkBloomCurrentUserID = silkBloomCurrentUser?.blushBloomUserID else {
            return false
        }

        return silkBloomPublisherID != silkBloomCurrentUserID
    }

    private var silkBloomHeroImages: [String] {
        let silkBloomImages = silkBloomPost?.velvetAuraImageList.filter {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        } ?? []

        return silkBloomImages.isEmpty ? ["VENNEAppLogo"] : silkBloomImages
    }

    private func silkBloomLoadPostDetail() {
        do {
            let silkBloomDataCenter = RadiantDewLocalDataCenter.shared
            let silkBloomLoadedUsers = try silkBloomDataCenter.radiantDewUsers.readAll()
            silkBloomUsers = silkBloomLoadedUsers
            silkBloomPost = try silkBloomDataCenter.radiantDewPosts.read(id: silkBloomPostID)
            silkBloomSelectedImageIndex = 0

            if let silkBloomPublisherID = silkBloomPost?.velvetAuraPublisherID {
                silkBloomPublisher = silkBloomLoadedUsers.first { $0.blushBloomUserID == silkBloomPublisherID }
            }

            if let silkBloomCurrentUserID = SilkBloomLoginSessionStore.currentUserID {
                silkBloomCurrentUser = silkBloomLoadedUsers.first { $0.blushBloomUserID == silkBloomCurrentUserID }
            }

            let silkBloomBlockedUserIDs = Set(silkBloomCurrentUser?.blushBloomBlockedIDs ?? [])

            silkBloomComments = try silkBloomDataCenter.radiantDewComments
                .readAll()
                .filter {
                    $0.honeyGlowVideoID == silkBloomPostID
                        && silkBloomBlockedUserIDs.contains($0.honeyGlowPublisherID) == false
                }
                .sorted { $0.honeyGlowCommentedAt < $1.honeyGlowCommentedAt }
        } catch {
            roseMistOverlayCenter.showToast("Post detail failed to load.", style: .error)
        }
    }

    private func silkBloomToggleLike() {
        guard let silkBloomPost else {
            return
        }

        guard silkBloomCurrentUser?.blushBloomIsGuest != true else {
            roseMistOverlayCenter.showGuestLoginPrompt()
            return
        }

        guard var silkBloomCurrentUser else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        do {
            var silkBloomUpdatedPost = silkBloomPost

            if let silkBloomLikedIndex = silkBloomCurrentUser.blushBloomLikedPostIDs.firstIndex(of: silkBloomPost.velvetAuraPostID) {
                silkBloomCurrentUser.blushBloomLikedPostIDs.remove(at: silkBloomLikedIndex)
                silkBloomUpdatedPost.velvetAuraLikeCount = max(0, silkBloomPost.velvetAuraLikeCount - 1)
            } else {
                silkBloomCurrentUser.blushBloomLikedPostIDs.append(silkBloomPost.velvetAuraPostID)
                silkBloomUpdatedPost.velvetAuraLikeCount = silkBloomPost.velvetAuraLikeCount + 1
            }

            try RadiantDewLocalDataCenter.shared.radiantDewUsers.update(silkBloomCurrentUser)
            try RadiantDewLocalDataCenter.shared.radiantDewPosts.update(silkBloomUpdatedPost)
            self.silkBloomCurrentUser = silkBloomCurrentUser
            self.silkBloomPost = silkBloomUpdatedPost
        } catch {
            roseMistOverlayCenter.showToast("Like update failed.", style: .error)
        }
    }

    private func silkBloomSendComment() {
        let silkBloomTrimmedComment = silkBloomCommentText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard silkBloomTrimmedComment.isEmpty == false else {
            return
        }

        guard silkBloomCurrentUser?.blushBloomIsGuest != true else {
            roseMistOverlayCenter.showGuestLoginPrompt()
            return
        }

        guard let silkBloomCurrentUser else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        do {
            let silkBloomNewComment = HoneyGlowCommentModel(
                honeyGlowCommentID: "comment_\(UUID().uuidString)",
                honeyGlowVideoID: silkBloomPostID,
                honeyGlowPublisherID: silkBloomCurrentUser.blushBloomUserID,
                honeyGlowContent: silkBloomTrimmedComment,
                honeyGlowCommentedAt: Date()
            )

            try RadiantDewLocalDataCenter.shared.radiantDewComments.create(silkBloomNewComment)
            silkBloomComments.append(silkBloomNewComment)
            silkBloomCommentText = ""
            silkBloomCommentFocused = false
        } catch {
            roseMistOverlayCenter.showToast("Comment failed to send.", style: .error)
        }
    }

    private func silkBloomShortName(_ silkBloomName: String) -> String {
        if silkBloomName.count > 8 {
            return "\(silkBloomName.prefix(6))..."
        }

        return silkBloomName
    }
}

#Preview {
    SilkBloomPostDetailView()
        .environmentObject(RoseMistOverlayCenter())
}
