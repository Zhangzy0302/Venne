import SwiftUI

struct HoneyLuxePrivateChatRoomView: View {
    @Environment(\.crystalBlushRouter) private var honeyLuxeRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    let honeyLuxeRoomID: String

    @State private var honeyLuxeCurrentUser: BlushBloomUserModel?
    @State private var honeyLuxeUsers: [BlushBloomUserModel] = []
    @State private var honeyLuxeRoom: MoonPetalChatRoomModel?
    @State private var honeyLuxeMessages: [SilkBloomChatMessageModel] = []
    @State private var honeyLuxeMessageText = ""
    @State private var honeyLuxeShowsModerationSheet = false
    @FocusState private var honeyLuxeMessageFocused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            GlowMuseTheme.blushBloomPrimaryText
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    RougeRibbonGuideBackground()

                    VStack(spacing: 0) {
                        honeyLuxeTopBar
                        ScrollView(showsIndicators: false) {
                            honeyLuxeMessageStack
                        }
                    }

                    
                }
                .clipShape(CrystalBlushUnevenRoundedRectangle(bottomLeadingRadius: 52))
                .ignoresSafeArea()

                honeyLuxeComposerBar
            }

            if honeyLuxeShowsModerationSheet,
               let honeyLuxeTargetUserID = honeyLuxeOtherUser?.blushBloomUserID {
                HoneyVelvetModerationSheet(
                    honeyVelvetTargetUserID: honeyLuxeTargetUserID,
                    honeyVelvetOnClose: {
                        honeyLuxeShowsModerationSheet = false
                    }
                )
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                honeyLuxeMessageFocused = false
            }
        )
        .onAppear {
            honeyLuxeLoadRoomData()
        }
    }

    private var honeyLuxeTopBar: some View {
        HStack(alignment: .center) {
            Button {
                honeyLuxeRouter?.pop()
            } label: {
                Image("VENNECNavBack")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8)

            honeyLuxeChatHeader

            Spacer()

            if honeyLuxeCanShowMoreButton {
                Button {
                    PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                        honeyLuxeShowsModerationSheet = true
                    }
                } label: {
                    Image("VENNEIconMore")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 52)
                }
                .buttonStyle(.plain)
            } else {
                Color.clear
                    .frame(width: 52, height: 52)
            }
        }
        .padding(.top, 60)
        .padding(.horizontal, 20)
    }

    private var honeyLuxeChatHeader: some View {
        Button {
            if let honeyLuxeOtherUserID = honeyLuxeOtherUser?.blushBloomUserID {
                honeyLuxeRouter?.push(.moonPetalUserProfile(userID: honeyLuxeOtherUserID))
            }
        } label: {
            VStack(spacing: 5) {
                CrystalBlushUniversalImage(
                    honeyLuxeOtherUser?.blushBloomAvatar ?? "VENNEDefaultAvatar",
                    contentMode: .fill,
                    fallbackSystemName: "person.crop.circle.fill"
                )
                .frame(width: 46, height: 46)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.9), lineWidth: 2)
                )

                Text(honeyLuxeShortName(honeyLuxeOtherUser?.blushBloomUserName ?? "Venne"))
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 13))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
            }
            .frame(maxWidth: 150)
        }
        .buttonStyle(.plain)
    }

    private var honeyLuxeMessageStack: some View {
        LazyVStack(spacing: 22) {
            if honeyLuxeVisibleMessages.isEmpty {
                honeyLuxeEmptyMessages
            } else {
                ForEach(honeyLuxeVisibleMessages) { honeyLuxeMessage in
                    honeyLuxeMessageBubble(honeyLuxeMessage)
                }
            }   
        }
        .padding(.top, 10)
        .padding(.horizontal, 18)
        .padding(.bottom, 120)
    }

    private var honeyLuxeEmptyMessages: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)

            Text("Start a private glow chat.")
                .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                .foregroundStyle(GlowMuseTheme.blushBloomMutedText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
    }

    private var honeyLuxeComposerBar: some View {
        HStack(spacing: 14) {
            HStack {
                TextField("", text: $honeyLuxeMessageText, prompt:
                            Text("Say something....")
                                .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                                .foregroundColor(.white.opacity(0.4)))
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                    .foregroundStyle(.white)
                    .tint(.white)
                    .focused($honeyLuxeMessageFocused)
                    .padding(.horizontal, 14)
                    .disabled(honeyLuxeCurrentUser?.blushBloomIsGuest == true)

                honeyLuxeComposerButton(
                    background: AnyShapeStyle(GlowMuseTheme.velvetAuraAccentGradient),
                    imageName: "VENNESendIcon"
                ) {
                    honeyLuxeSendMessage()
                }
            }
            .frame(height: 48)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(GlowMuseTheme.blushBloomPrimaryText)
    }

    private var honeyLuxeVisibleMessages: [SilkBloomChatMessageModel] {
        honeyLuxeMessages
            .filter { $0.silkBloomRoomID == honeyLuxeRoomID }
            .sorted { $0.silkBloomSentAt < $1.silkBloomSentAt }
    }

    private var honeyLuxeOtherUser: BlushBloomUserModel? {
        guard let honeyLuxeCurrentUserID = honeyLuxeCurrentUser?.blushBloomUserID,
              let honeyLuxeOtherUserID = honeyLuxeRoom?.moonPetalUserIDs.first(where: { $0 != honeyLuxeCurrentUserID }) else {
            return nil
        }

        return honeyLuxeUsers.first { $0.blushBloomUserID == honeyLuxeOtherUserID }
    }

    private var honeyLuxeHeaderUsers: [BlushBloomUserModel] {
        guard let honeyLuxeOtherUser else {
            return honeyLuxeUsers.prefix(5).map { $0 }
        }

        let honeyLuxeOtherID = honeyLuxeOtherUser.blushBloomUserID
        let honeyLuxeNearbyUsers = honeyLuxeUsers
            .filter { $0.blushBloomUserID != honeyLuxeOtherID && $0.blushBloomIsGuest == false }
            .prefix(4)

        return Array(honeyLuxeNearbyUsers.prefix(2)) + [honeyLuxeOtherUser] + Array(honeyLuxeNearbyUsers.dropFirst(2))
    }

    private var honeyLuxeCanShowMoreButton: Bool {
        guard let honeyLuxeOtherUserID = honeyLuxeOtherUser?.blushBloomUserID,
              let honeyLuxeCurrentUserID = honeyLuxeCurrentUser?.blushBloomUserID else {
            return false
        }

        return honeyLuxeOtherUserID != honeyLuxeCurrentUserID
    }

    private func honeyLuxeMessageBubble(_ honeyLuxeMessage: SilkBloomChatMessageModel) -> some View {
        let honeyLuxeIsMine = honeyLuxeMessage.silkBloomSenderID == honeyLuxeCurrentUser?.blushBloomUserID

        return HStack(alignment: .bottom, spacing: 10) {
            if honeyLuxeIsMine {
                Spacer(minLength: 54)

                Text(honeyLuxeMessage.silkBloomTextMessage)
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                    .lineSpacing(3)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                let honeyLuxeSender = honeyLuxeSender(for: honeyLuxeMessage)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 10) {
                        CrystalBlushUniversalImage(
                            honeyLuxeSender?.blushBloomAvatar ?? honeyLuxeOtherUser?.blushBloomAvatar ?? "VENNEAppLogo",
                            contentMode: .fill,
                            fallbackSystemName: "person.crop.circle.fill"
                        )
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())

                        Text(honeyLuxeMessage.silkBloomTextMessage)
                            .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                            .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                            .lineSpacing(3)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.96))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    Text(honeyLuxeShortName(honeyLuxeSender?.blushBloomUserName ?? honeyLuxeOtherUser?.blushBloomUserName ?? "Nova"))
                        .font(GlowMuseTheme.blushBloomBodyFont(size: 15))
                        .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                        .padding(.leading, 42)
                }

                Spacer(minLength: 54)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func honeyLuxeComposerButton(
        background: AnyShapeStyle,
        imageName: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Circle()
                .fill(background)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                )
        }
        .buttonStyle(.plain)
    }

    private func honeyLuxeLoadRoomData() {
        do {
            let honeyLuxeDataCenter = RadiantDewLocalDataCenter.shared
            let honeyLuxeLoadedUsers = try honeyLuxeDataCenter.radiantDewUsers.readAll()

            honeyLuxeUsers = honeyLuxeLoadedUsers
            honeyLuxeRoom = try honeyLuxeDataCenter.radiantDewChatRooms.readAll()
                .first { $0.moonPetalRoomID == honeyLuxeRoomID }
            honeyLuxeMessages = try honeyLuxeDataCenter.radiantDewChatMessages.readAll()

            if let honeyLuxeCurrentUserID = SilkBloomLoginSessionStore.currentUserID {
                honeyLuxeCurrentUser = honeyLuxeLoadedUsers.first { $0.blushBloomUserID == honeyLuxeCurrentUserID }
            } else {
                honeyLuxeCurrentUser = nil
            }
        } catch {
            roseMistOverlayCenter.showToast("Private chat failed to load.", style: .error)
        }
    }

    private func honeyLuxeSendMessage() {
        let honeyLuxeTrimmedText = honeyLuxeMessageText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard honeyLuxeTrimmedText.isEmpty == false else {
            return
        }

        guard honeyLuxeCurrentUser?.blushBloomIsGuest != true else {
            roseMistOverlayCenter.showGuestLoginPrompt()
            return
        }

        guard let honeyLuxeCurrentUser else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        do {
            let honeyLuxeNow = Date()
            let honeyLuxeNewMessage = SilkBloomChatMessageModel(
                silkBloomMessageID: "message_private_\(UUID().uuidString)",
                silkBloomRoomID: honeyLuxeRoomID,
                silkBloomSenderID: honeyLuxeCurrentUser.blushBloomUserID,
                silkBloomTextMessage: honeyLuxeTrimmedText,
                silkBloomVoiceMessagePath: "",
                silkBloomVoiceDuration: 0,
                silkBloomSentAt: honeyLuxeNow
            )

            try RadiantDewLocalDataCenter.shared.radiantDewChatMessages.create(honeyLuxeNewMessage)
            honeyLuxeMessages.append(honeyLuxeNewMessage)

            if var honeyLuxeRoom {
                honeyLuxeRoom.moonPetalLastSenderID = honeyLuxeCurrentUser.blushBloomUserID
                honeyLuxeRoom.moonPetalLastMessageText = honeyLuxeTrimmedText
                honeyLuxeRoom.moonPetalLastMessageSentAt = honeyLuxeNow
                try RadiantDewLocalDataCenter.shared.radiantDewChatRooms.update(honeyLuxeRoom)
                self.honeyLuxeRoom = honeyLuxeRoom
            }

            honeyLuxeMessageText = ""
        } catch {
            roseMistOverlayCenter.showToast("Message send failed.", style: .error)
        }
    }

    private func honeyLuxeSender(for honeyLuxeMessage: SilkBloomChatMessageModel) -> BlushBloomUserModel? {
        honeyLuxeUsers.first { $0.blushBloomUserID == honeyLuxeMessage.silkBloomSenderID } ?? honeyLuxeOtherUser
    }

    private func honeyLuxeShortName(_ honeyLuxeName: String) -> String {
        if honeyLuxeName.count > 7 {
            return "\(honeyLuxeName.prefix(5))..."
        }

        return honeyLuxeName
    }
}

#Preview {
    HoneyLuxePrivateChatRoomView(honeyLuxeRoomID: "room_private_dashi_nova")
        .environmentObject(RoseMistOverlayCenter())
}
