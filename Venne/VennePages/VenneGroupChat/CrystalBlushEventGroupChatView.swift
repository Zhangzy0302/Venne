import SwiftUI

struct CrystalBlushEventGroupChatView: View {
    @Environment(\.crystalBlushRouter) private var crystalBlushRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    let crystalBlushRoomID: String

    @State private var crystalBlushCurrentUser: BlushBloomUserModel?
    @State private var crystalBlushUsers: [BlushBloomUserModel] = []
    @State private var crystalBlushRoom: MoonPetalChatRoomModel?
    @State private var crystalBlushMessages: [SilkBloomChatMessageModel] = []
    @State private var crystalBlushMessageText = ""
    @State private var crystalBlushShowsModerationSheet = false
    @FocusState private var crystalBlushMessageFocused: Bool

    init(crystalBlushRoomID: String = "room_glow_talk") {
        self.crystalBlushRoomID = crystalBlushRoomID
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            GlowMuseTheme.blushBloomPrimaryText
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    crystalBlushBackground
                        .ignoresSafeArea()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            crystalBlushChatContent
                            Spacer(minLength: 0)
                        }
                    }

                    crystalBlushTopBar
                }
                .clipShape(CrystalBlushUnevenRoundedRectangle(bottomLeadingRadius: 52))
                .ignoresSafeArea()

                crystalBlushComposerBar
            }

            if crystalBlushShowsModerationSheet,
               let crystalBlushTargetUserID = crystalBlushRoomStarterID {
                HoneyVelvetModerationSheet(
                    honeyVelvetTargetUserID: crystalBlushTargetUserID,
                    honeyVelvetOnClose: {
                        crystalBlushShowsModerationSheet = false
                    }
                )
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                crystalBlushMessageFocused = false
            }
        )
        .onAppear {
            crystalBlushLoadRoomData()
        }
    }

    private var crystalBlushBackground: some View {
        GeometryReader { crystalBlushGeo in
            ZStack(alignment: .top) {
                RougeRibbonGuideBackground()
                
                CrystalBlushUniversalImage(
                    crystalBlushRoom?.moonPetalGroupCoverImage ?? "VENNEMainBg",
                    contentMode: .fill,
                    fallbackSystemName: "person.3.fill"
                )
                .frame(width: crystalBlushGeo.size.width, height: crystalBlushGeo.size.height - 100)
                .clipped()
                .mask(
                    LinearGradient(
                        colors: [
                            .black,
                            .black.opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom,
                    )
                )
                
            }
        }
    }

    private var crystalBlushTopBar: some View {
        HStack {
            Button {
                crystalBlushRouter?.pop()
            } label: {
                Image("VENNECNavBack")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
            }
            .buttonStyle(.plain)

            Spacer()

            if crystalBlushCanShowMoreButton {
                Button {
                    PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                        crystalBlushShowsModerationSheet = true
                    }
                } label: {
                    Image("VENNEIconMore")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 52)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 60)
        .padding(.horizontal, 20)
    }

    private var crystalBlushChatContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            crystalBlushRoomCard
                .padding(.top, 130)

            ForEach(crystalBlushVisibleMessages) { crystalBlushMessage in
                crystalBlushMessageBubble(crystalBlushMessage)
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 120)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var crystalBlushRoomCard: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(GlowMuseTheme.velvetAuraAccentGradient)
            .frame(height: 164)
            .overlay(
                VStack(alignment: .leading, spacing: 14) {
                    Text(crystalBlushRoomTitle)
                        .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .black))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(crystalBlushRoomIntro)
                        .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                        .foregroundStyle(.white.opacity(0.92))
                        .lineSpacing(4)
                        .lineLimit(2)

                    HStack(spacing: -8) {
                        ForEach(Array(crystalBlushRoomMembers.prefix(4))) { crystalBlushUser in
                            CrystalBlushUniversalImage(
                                crystalBlushUser.blushBloomAvatar,
                                contentMode: .fill,
                                fallbackSystemName: "person.crop.circle.fill"
                            )
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.9), lineWidth: 1.5)
                            )
                        }

//                        Circle()
//                            .fill(Color.black.opacity(0.28))
//                            .frame(width: 36, height: 36)
//                            .overlay(
//                                Text("+\(max(0, crystalBlushRoomMemberCount - 4))")
//                                    .font(GlowMuseTheme.blushBloomSerifFont(size: 14, weight: .bold))
//                                    .foregroundStyle(.white)
//                            )

                        Text("\(crystalBlushRoomMemberCount) joined")
                            .font(GlowMuseTheme.blushBloomBodyFont(size: 15))
                            .foregroundStyle(.white)
                            .padding(.leading, 12)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
            )
    }

    private var crystalBlushComposerBar: some View {
        HStack(spacing: 16) {
            HStack {
                TextField("", text: $crystalBlushMessageText, prompt:
                            Text("Say something....")
                                .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                                .foregroundColor(.white.opacity(0.4)))
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                    .foregroundStyle(.white)
                    .tint(.white)
                    .focused($crystalBlushMessageFocused)
                    .padding(.horizontal, 14)
                    .disabled(crystalBlushCurrentUser?.blushBloomIsGuest == true)

                crystalBlushComposerButton(
                    background: AnyShapeStyle(GlowMuseTheme.velvetAuraAccentGradient),
                    imageName: "VENNESendIcon",
                    action: crystalBlushSendMessage
                )
            }
            .frame(height: 48)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())

        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(GlowMuseTheme.blushBloomPrimaryText)
    }

    private var crystalBlushVisibleMessages: [SilkBloomChatMessageModel] {
        let crystalBlushBlockedUserIDs = crystalBlushBlockedUserIDSet

        return crystalBlushMessages
            .filter {
                $0.silkBloomRoomID == crystalBlushRoomID
                    && crystalBlushBlockedUserIDs.contains($0.silkBloomSenderID) == false
            }
            .sorted { $0.silkBloomSentAt < $1.silkBloomSentAt }
    }

    private var crystalBlushRoomMembers: [BlushBloomUserModel] {
        guard let crystalBlushRoom else {
            return []
        }

        let crystalBlushBlockedUserIDs = crystalBlushBlockedUserIDSet

        return crystalBlushRoom.moonPetalUserIDs
            .filter { crystalBlushBlockedUserIDs.contains($0) == false }
            .compactMap { crystalBlushUserID in
                crystalBlushUsers.first { $0.blushBloomUserID == crystalBlushUserID }
            }
    }

    private var crystalBlushRoomMemberCount: Int {
        crystalBlushRoomMembers.count
    }

    private var crystalBlushBlockedUserIDSet: Set<String> {
        Set(crystalBlushCurrentUser?.blushBloomBlockedIDs ?? [])
    }

    private var crystalBlushRoomStarterID: String? {
        crystalBlushRoom?.moonPetalUserIDs.first
    }

    private var crystalBlushCanShowMoreButton: Bool {
        guard let crystalBlushStarterID = crystalBlushRoomStarterID,
              let crystalBlushCurrentUserID = crystalBlushCurrentUser?.blushBloomUserID else {
            return false
        }

        return crystalBlushStarterID != crystalBlushCurrentUserID
    }

    private var crystalBlushRoomTitle: String {
        let crystalBlushName = crystalBlushRoom?.moonPetalGroupRoomName.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return crystalBlushName.isEmpty ? "GLOW TALK" : crystalBlushName.uppercased()
    }

    private var crystalBlushRoomIntro: String {
        let crystalBlushIntro = crystalBlushRoom?.moonPetalGroupRoomIntro.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return crystalBlushIntro.isEmpty ? "A space to chat while showing off your daily glow-up looks." : crystalBlushIntro
    }

    private func crystalBlushMessageBubble(_ crystalBlushMessage: SilkBloomChatMessageModel) -> some View {
        let crystalBlushIsMine = crystalBlushMessage.silkBloomSenderID == crystalBlushCurrentUser?.blushBloomUserID

        return HStack(alignment: .bottom, spacing: 10) {
            if crystalBlushIsMine {
                Spacer(minLength: 46)

                Text(crystalBlushMessage.silkBloomTextMessage)
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                    .lineSpacing(3)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                let crystalBlushSender = crystalBlushSender(for: crystalBlushMessage)

                VStack(alignment: .leading, spacing: 8) {
                    Text(crystalBlushMessage.silkBloomTextMessage)
                        .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                        .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                        .lineSpacing(3)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.96))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.leading, 42)
                    
                    HStack(spacing: 8) {
                        CrystalBlushUniversalImage(
                            crystalBlushSender?.blushBloomAvatar ?? "VENNEAppLogo",
                            contentMode: .fill,
                            fallbackSystemName: "person.crop.circle.fill"
                        )
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        
                        Text(crystalBlushShortName(crystalBlushSender?.blushBloomUserName ?? "Nova"))
                            .font(GlowMuseTheme.blushBloomBodyFont(size: 15))
                            .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                            
                    }

                }

                Spacer(minLength: 46)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func crystalBlushComposerButton(
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

    private func crystalBlushLoadRoomData() {
        do {
            let crystalBlushDataCenter = RadiantDewLocalDataCenter.shared
            let crystalBlushLoadedUsers = try crystalBlushDataCenter.radiantDewUsers.readAll()
            let crystalBlushLoadedRooms = try crystalBlushDataCenter.radiantDewChatRooms.readAll()

            crystalBlushUsers = crystalBlushLoadedUsers
            crystalBlushRoom = crystalBlushLoadedRooms.first { $0.moonPetalRoomID == crystalBlushRoomID }
            crystalBlushMessages = try crystalBlushDataCenter.radiantDewChatMessages.readAll()

            if let crystalBlushCurrentUserID = SilkBloomLoginSessionStore.currentUserID {
                crystalBlushCurrentUser = crystalBlushLoadedUsers.first { $0.blushBloomUserID == crystalBlushCurrentUserID }
            } else {
                crystalBlushCurrentUser = nil
            }
        } catch {
            roseMistOverlayCenter.showToast("Group chat failed to load.", style: .error)
        }
    }

    private func crystalBlushSendMessage() {
        let crystalBlushTrimmedText = crystalBlushMessageText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard crystalBlushTrimmedText.isEmpty == false else {
            return
        }

        guard crystalBlushCurrentUser?.blushBloomIsGuest != true else {
            roseMistOverlayCenter.showGuestLoginPrompt()
            return
        }

        guard let crystalBlushCurrentUser else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        do {
            let crystalBlushNow = Date()
            let crystalBlushNewMessage = SilkBloomChatMessageModel(
                silkBloomMessageID: "message_group_\(UUID().uuidString)",
                silkBloomRoomID: crystalBlushRoomID,
                silkBloomSenderID: crystalBlushCurrentUser.blushBloomUserID,
                silkBloomTextMessage: crystalBlushTrimmedText,
                silkBloomVoiceMessagePath: "",
                silkBloomVoiceDuration: 0,
                silkBloomSentAt: crystalBlushNow
            )

            try RadiantDewLocalDataCenter.shared.radiantDewChatMessages.create(crystalBlushNewMessage)
            crystalBlushMessages.append(crystalBlushNewMessage)

            if var crystalBlushRoom {
                if crystalBlushRoom.moonPetalUserIDs.contains(crystalBlushCurrentUser.blushBloomUserID) == false {
                    crystalBlushRoom.moonPetalUserIDs.append(crystalBlushCurrentUser.blushBloomUserID)
                }

                crystalBlushRoom.moonPetalLastSenderID = crystalBlushCurrentUser.blushBloomUserID
                crystalBlushRoom.moonPetalLastMessageText = crystalBlushTrimmedText
                crystalBlushRoom.moonPetalLastMessageSentAt = crystalBlushNow
                try RadiantDewLocalDataCenter.shared.radiantDewChatRooms.update(crystalBlushRoom)
                self.crystalBlushRoom = crystalBlushRoom
            }

            crystalBlushMessageText = ""
        } catch {
            roseMistOverlayCenter.showToast("Message send failed.", style: .error)
        }
    }

    private func crystalBlushSender(for crystalBlushMessage: SilkBloomChatMessageModel) -> BlushBloomUserModel? {
        crystalBlushUsers.first { $0.blushBloomUserID == crystalBlushMessage.silkBloomSenderID }
    }

    private func crystalBlushShortName(_ crystalBlushName: String) -> String {
        if crystalBlushName.count > 7 {
            return "\(crystalBlushName.prefix(5))..."
        }

        return crystalBlushName
    }
}

#Preview {
    CrystalBlushEventGroupChatView()
        .environmentObject(RoseMistOverlayCenter())
}
