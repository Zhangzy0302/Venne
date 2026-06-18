import SwiftUI

struct PearlLuxeVideoCallView: View {
    @Environment(\.crystalBlushRouter) private var pearlLuxeRouter

    let pearlLuxeRoomID: String

    @State private var pearlLuxeCurrentUser: BlushBloomUserModel?
    @State private var pearlLuxeUsers: [BlushBloomUserModel] = []
    @State private var pearlLuxeRoom: MoonPetalChatRoomModel?

    var body: some View {
        ZStack(alignment: .top) {
            RougeRibbonGuideBackground()
                .ignoresSafeArea()

            pearlLuxeHeroBackground

            VStack(spacing: 0) {
                pearlLuxeTopBar

                Spacer()
                    .frame(height: 228)

                pearlLuxeCallerProfile

                Spacer()

                pearlLuxeHangUpButton
                    .padding(.bottom, 114)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            pearlLuxeLoadCallData()
        }
    }

    private var pearlLuxeHeroBackground: some View {
        GeometryReader { pearlLuxeGeometry in
            CrystalBlushUniversalImage(
                pearlLuxeCallUser?.blushBloomAvatar ?? "VENNEMainBg",
                contentMode: .fill,
                fallbackSystemName: "person.crop.circle.fill"
            )
            .frame(width: pearlLuxeGeometry.size.width, height: 430)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.24),
                        Color.white.opacity(0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(height: 430)
    }

    private var pearlLuxeTopBar: some View {
        HStack {
            Button {
                pearlLuxeRouter?.pop()
            } label: {
                Image("VENNECNavBack")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 18)
    }

    private var pearlLuxeCallerProfile: some View {
        VStack(spacing: 18) {
            CrystalBlushUniversalImage(
                pearlLuxeCallUser?.blushBloomAvatar ?? "VENNEDefaultAvatar",
                contentMode: .fill,
                fallbackSystemName: "person.crop.circle.fill"
            )
            .frame(width: 88, height: 88)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.9), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 18, y: 8)

            Text(pearlLuxeCallName)
                .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .black))
                .tracking(0.4)
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

            Text("Calling...")
                .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText)
                .padding(.top, 14)
        }
    }

    private var pearlLuxeHangUpButton: some View {
        Button {
            pearlLuxeRouter?.pop()
        } label: {
            Circle()
                .fill(GlowMuseTheme.velvetAuraAccentGradient)
                .frame(width: 68, height: 68)
                .overlay(
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 27, weight: .bold))
                        .foregroundStyle(.white)
                )
                .shadow(color: GlowMuseTheme.honeyGlowLinkText.opacity(0.24), radius: 18, y: 10)
        }
        .buttonStyle(.plain)
    }

    private var pearlLuxeCallUser: BlushBloomUserModel? {
        guard let pearlLuxeCurrentUserID = pearlLuxeCurrentUser?.blushBloomUserID,
              let pearlLuxeOtherUserID = pearlLuxeRoom?.moonPetalUserIDs.first(where: { $0 != pearlLuxeCurrentUserID }) else {
            return nil
        }

        return pearlLuxeUsers.first { $0.blushBloomUserID == pearlLuxeOtherUserID }
    }

    private var pearlLuxeCallName: String {
        let pearlLuxeName = pearlLuxeCallUser?.blushBloomUserName.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return pearlLuxeName.isEmpty ? "VENNE" : pearlLuxeName.uppercased()
    }

    private func pearlLuxeLoadCallData() {
        do {
            let pearlLuxeDataCenter = RadiantDewLocalDataCenter.shared
            let pearlLuxeLoadedUsers = try pearlLuxeDataCenter.radiantDewUsers.readAll()

            pearlLuxeUsers = pearlLuxeLoadedUsers
            pearlLuxeRoom = try pearlLuxeDataCenter.radiantDewChatRooms.readAll()
                .first { $0.moonPetalRoomID == pearlLuxeRoomID }

            if let pearlLuxeCurrentUserID = SilkBloomLoginSessionStore.currentUserID {
                pearlLuxeCurrentUser = pearlLuxeLoadedUsers.first { $0.blushBloomUserID == pearlLuxeCurrentUserID }
            } else {
                pearlLuxeCurrentUser = nil
            }
        } catch {
            pearlLuxeUsers = []
            pearlLuxeRoom = nil
            pearlLuxeCurrentUser = nil
        }
    }
}

#Preview {
    PearlLuxeVideoCallView(pearlLuxeRoomID: "room_private_dashi_nova")
}
