import SwiftUI

struct GlowMuseChatHubView: View {
    @Environment(\.crystalBlushRouter) private var glowMuseRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    @State private var glowMuseCurrentUser: BlushBloomUserModel?
    @State private var glowMuseAllUsers: [BlushBloomUserModel] = []
    @State private var glowMusePrivateRooms: [MoonPetalChatRoomModel] = []

    var body: some View {
        GeometryReader { glowMuseGeo in
            glowMuseContent(width: glowMuseSafeWidth(glowMuseGeo.size.width))
        }
        .onAppear {
            glowMuseLoadChatUsers()
        }
    }

    private func glowMuseContent(width glowMuseWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("CHAT")
                .font(GlowMuseTheme.blushBloomSerifFont(size: 20, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                .padding(.top, 60)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    if glowMuseMutualFollowUsers.isEmpty {
                        Text("No mutual beauty friends yet.")
                            .font(GlowMuseTheme.blushBloomBodyFont(size: 13))
                            .foregroundStyle(GlowMuseTheme.blushBloomMutedText)
                            .frame(width: max(0, glowMuseWidth - 40), height: 78, alignment: .leading)
                    } else {
                        ForEach(glowMuseMutualFollowUsers) { glowMuseUser in
                            Button {
                                PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                                    glowMuseRouter?.push(.moonPetalUserProfile(userID: glowMuseUser.blushBloomUserID))
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    CrystalBlushUniversalImage(
                                        glowMuseUser.blushBloomAvatar,
                                        contentMode: .fill,
                                        fallbackSystemName: "person.crop.circle.fill"
                                    )
                                    .frame(width: 58, height: 58)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.9), lineWidth: 2)
                                    )

                                    Text(glowMuseShortName(glowMuseUser.blushBloomUserName))
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
                .padding(.top, 18)
            }

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 14) {
                    if glowMuseVisiblePrivateRooms.isEmpty {
                        glowMuseEmptyRoomState()
                    } else {
                        ForEach(glowMuseVisiblePrivateRooms) { glowMuseRoom in
                            Button {
                                PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                                    glowMuseRouter?.push(.honeyLuxePrivateChatRoom(roomID: glowMuseRoom.moonPetalRoomID))
                                }
                            } label: {
                                glowMusePrivateRoomCard(glowMuseRoom)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.top, 28)
                .padding(.bottom, 24)
            }

            Spacer()
        }
    }

    private var glowMuseMutualFollowUsers: [BlushBloomUserModel] {
        guard let glowMuseCurrentUser else {
            return []
        }

        let glowMuseMyFollowingIDs = Set(glowMuseCurrentUser.blushBloomFollowingIDs)
        let glowMuseBlockedIDs = Set(glowMuseCurrentUser.blushBloomBlockedIDs)

        return glowMuseAllUsers.filter { glowMuseUser in
            glowMuseUser.blushBloomUserID != glowMuseCurrentUser.blushBloomUserID
                && glowMuseUser.blushBloomIsGuest == false
                && glowMuseBlockedIDs.contains(glowMuseUser.blushBloomUserID) == false
                && glowMuseMyFollowingIDs.contains(glowMuseUser.blushBloomUserID)
                && glowMuseUser.blushBloomFollowingIDs.contains(glowMuseCurrentUser.blushBloomUserID)
        }
    }

    private var glowMuseVisiblePrivateRooms: [MoonPetalChatRoomModel] {
        guard let glowMuseCurrentUser else {
            return []
        }

        let glowMuseBlockedIDs = Set(glowMuseCurrentUser.blushBloomBlockedIDs)

        return glowMusePrivateRooms
            .filter { glowMuseRoom in
                guard glowMuseRoom.moonPetalIsGroupChat == false,
                      glowMuseRoom.moonPetalUserIDs.contains(glowMuseCurrentUser.blushBloomUserID),
                      let glowMuseOtherUser = glowMuseOtherUser(in: glowMuseRoom) else {
                    return false
                }

                return glowMuseBlockedIDs.contains(glowMuseOtherUser.blushBloomUserID) == false
            }
            .sorted { $0.moonPetalLastMessageSentAt > $1.moonPetalLastMessageSentAt }
    }

    private func glowMuseEmptyRoomState() -> some View {
        VStack(spacing: 10) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)

            HStack{
                Spacer()
                Text("No private chats yet.")
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                    .foregroundStyle(GlowMuseTheme.blushBloomMutedText)
                Spacer()
            }
        }
        .frame(height: 130)
        .background(GlowMuseTheme.silkBloomSurfaceFill.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.horizontal, 20)
    }

    private func glowMuseLoadChatUsers() {
        do {
            let glowMuseDataCenter = RadiantDewLocalDataCenter.shared
            let glowMuseUsers = try RadiantDewLocalDataCenter.shared.radiantDewUsers.readAll()
            glowMuseAllUsers = glowMuseUsers
            glowMusePrivateRooms = try glowMuseDataCenter.radiantDewChatRooms.readAll()

            if let glowMuseCurrentUserID = SilkBloomLoginSessionStore.currentUserID {
                glowMuseCurrentUser = glowMuseUsers.first { $0.blushBloomUserID == glowMuseCurrentUserID }
            } else {
                glowMuseCurrentUser = nil
            }
        } catch {
            roseMistOverlayCenter.showToast("Chat users failed to load.", style: .error)
        }
    }

    private func glowMusePrivateRoomCard(_ glowMuseRoom: MoonPetalChatRoomModel) -> some View {
        let glowMuseOtherUser = glowMuseOtherUser(in: glowMuseRoom)

        return RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Color.white.opacity(0.82))
            .frame(height: 95)
            .overlay(alignment: .topTrailing) {
                if glowMuseRoom.moonPetalUnreadMessageCount > 0 {
                    Capsule()
                        .fill(GlowMuseTheme.velvetAuraAccentGradient)
                        .frame(width: 58, height: 34)
                        .overlay(
                            Text("\(glowMuseRoom.moonPetalUnreadMessageCount)")
                                .font(GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .offset(x: 6, y: -6)
                }
            }
            .overlay(
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        CrystalBlushUniversalImage(
                            glowMuseOtherUser?.blushBloomAvatar ?? "VENNEAppLogo",
                            contentMode: .fill,
                            fallbackSystemName: "person.crop.circle.fill"
                        )
                        .frame(width: 26, height: 26)
                        .clipShape(Circle())

                        Text(glowMuseOtherUser?.blushBloomUserName.uppercased() ?? "VENNE")
                            .font(GlowMuseTheme.blushBloomSerifFont(size: 14, weight: .black))
                            .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                            .lineLimit(1)
                        Spacer()
                    }

                Text(glowMuseRoom.moonPetalLastMessageText.isEmpty ? "Say hi and start glowing." : glowMuseRoom.moonPetalLastMessageText)
                        .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                        .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                        .lineLimit(1)
                }
                .frame(alignment: .leading)
                .padding(.horizontal, 18)
            )
    }

    private func glowMuseSafeWidth(_ glowMuseWidth: CGFloat) -> CGFloat {
        guard glowMuseWidth.isFinite, glowMuseWidth > 0 else {
            return UIScreen.main.bounds.width
        }

        return glowMuseWidth
    }

    private func glowMuseOtherUser(in glowMuseRoom: MoonPetalChatRoomModel) -> BlushBloomUserModel? {
        guard let glowMuseCurrentUserID = glowMuseCurrentUser?.blushBloomUserID else {
            return nil
        }

        guard let glowMuseOtherUserID = glowMuseRoom.moonPetalUserIDs.first(where: { $0 != glowMuseCurrentUserID }) else {
            return nil
        }

        return glowMuseAllUsers.first { $0.blushBloomUserID == glowMuseOtherUserID }
    }

    private func glowMuseShortName(_ glowMuseName: String) -> String {
        if glowMuseName.count > 7 {
            return "\(glowMuseName.prefix(5))..."
        }

        return glowMuseName
    }
}

#Preview {
    ZStack {
        RougeRibbonGuideBackground()
        GlowMuseChatHubView()
            .padding(.bottom, 92)
    }
}
