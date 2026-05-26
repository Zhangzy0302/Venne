import SwiftUI

struct HoneyGlowHomeView: View {
    @Environment(\.crystalBlushRouter) private var honeyGlowRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    var honeyGlowCreatePublishTap: () -> Void = {}

    @State private var honeyGlowChatRooms: [MoonPetalChatRoomModel] = []
    @State private var honeyGlowUsers: [BlushBloomUserModel] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text("HELLO,\nWELCOME TO VENNE!")
                    .font(GlowMuseTheme.blushBloomSerifFont(size: 22, weight: .black))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                    .padding(.top, 8)

                Spacer()

                Button(action: {
                    PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                        honeyGlowCreatePublishTap()
                    }
                }) {
                    Circle()
                        .fill(Color.white.opacity(0.42))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .light))
                                .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)

            Button(action: {
                PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                    honeyGlowRouter?.push(.radiantDewMakeupPreset)
                }
            }) {
                HStack(spacing: 12) {
                    Spacer()
                    Image("VENNECircleDecoration")
                        .resizable()
                        .frame(width: 40, height: 40)

                    Text("Create the makeup you want")
                        .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                        .foregroundStyle(.white)

                    Spacer()
                }
                .padding(.horizontal, 18)
                .frame(height: 68)
                .background(GlowMuseTheme.velvetAuraAccentGradient)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.top, 29)

            Text("DISCOVER")
                .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                .padding(.horizontal, 16)
                .padding(.top, 26)
                .padding(.bottom, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    if honeyGlowGroupChatRooms.isEmpty {
                        honeyGlowEmptyDiscoverCard
                    } else {
                        ForEach(honeyGlowGroupChatRooms) { honeyGlowRoom in
                            Button {
                                PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                                    honeyGlowRouter?.push(.crystalBlushEventGroupChat(roomID: honeyGlowRoom.moonPetalRoomID))
                                }
                            } label: {
                                honeyGlowGroupChatCard(honeyGlowRoom)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }.frame(maxHeight: .infinity)
                .padding(.bottom, 32)
        }
        .onAppear {
            honeyGlowLoadDiscoverRooms()
        }
    }

    private var honeyGlowGroupChatRooms: [MoonPetalChatRoomModel] {
        honeyGlowChatRooms
            .filter(\.moonPetalIsGroupChat)
            .sorted { $0.moonPetalLastMessageSentAt > $1.moonPetalLastMessageSentAt }
    }

    private var honeyGlowEmptyDiscoverCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)

            Text("No event chat rooms yet.")
                .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                .foregroundStyle(GlowMuseTheme.blushBloomMutedText)
        }
        .frame(width: 208, height: 270)
        .background(Color.white.opacity(0.58))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func honeyGlowGroupChatCard(_ honeyGlowRoom: MoonPetalChatRoomModel) -> some View {
        ZStack(alignment: .bottom) {
            CrystalBlushUniversalImage(
                honeyGlowRoom.moonPetalGroupCoverImage.isEmpty ? "VEAOIVChatRoomCover_0" : honeyGlowRoom.moonPetalGroupCoverImage,
                contentMode: .fill,
                fallbackSystemName: "person.3.fill"
            )
            .frame(width: 288)
            .frame(maxHeight: .infinity)
            .clipped()

            LinearGradient(colors: [
                Color(red: 198/255, green: 137/255, blue: 165/255).opacity(0.95),
                Color(red: 198/255, green: 137/255, blue: 165/255).opacity(0)
            ], startPoint: .bottom, endPoint: .top)
            .frame(height: 110)

            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                        )
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Spacer()

                HStack(spacing: -8) {
                    ForEach(Array(honeyGlowRoomMembers(for: honeyGlowRoom).prefix(4))) { honeyGlowUser in
                        CrystalBlushUniversalImage(
                            honeyGlowUser.blushBloomAvatar,
                            contentMode: .fill,
                            fallbackSystemName: "person.crop.circle.fill"
                        )
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                        )
                    }

                }

                Text(honeyGlowRoom.moonPetalGroupRoomName.isEmpty ? "GLOW TALK" : honeyGlowRoom.moonPetalGroupRoomName.uppercased())
                    .font(GlowMuseTheme.blushBloomSerifFont(size: 15, weight: .black))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .padding(.horizontal, 14)

                Text(honeyGlowSubtitle(for: honeyGlowRoom))
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                    .foregroundStyle(.white.opacity(0.88))
                    .lineLimit(1)
                    .padding(.bottom, 18)
                    .padding(.horizontal, 22)
            }
        }
        .frame(width: 288)
        .frame(maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func honeyGlowLoadDiscoverRooms() {
        do {
            let honeyGlowDataCenter = RadiantDewLocalDataCenter.shared
            honeyGlowChatRooms = try honeyGlowDataCenter.radiantDewChatRooms.readAll()
            honeyGlowUsers = try honeyGlowDataCenter.radiantDewUsers.readAll()
        } catch {
            roseMistOverlayCenter.showToast("Event rooms failed to load.", style: .error)
        }
    }

    private func honeyGlowRoomMembers(for honeyGlowRoom: MoonPetalChatRoomModel) -> [BlushBloomUserModel] {
        honeyGlowRoom.moonPetalUserIDs.compactMap { honeyGlowUserID in
            honeyGlowUsers.first { $0.blushBloomUserID == honeyGlowUserID }
        }
    }

    private func honeyGlowSubtitle(for honeyGlowRoom: MoonPetalChatRoomModel) -> String {
        let honeyGlowIntro = honeyGlowRoom.moonPetalGroupRoomIntro.trimmingCharacters(in: .whitespacesAndNewlines)

        if honeyGlowIntro.isEmpty == false {
            return honeyGlowIntro
        }

        return "\(honeyGlowRoom.moonPetalUserIDs.count)+ joined"
    }
}

#Preview {
    ZStack {
        RougeRibbonGuideBackground()
        HoneyGlowHomeView()
            .padding(.bottom, 92)
    }
}
