import SwiftUI

struct MoonPetalBlacklistView: View {
    @Environment(\.crystalBlushRouter) private var moonPetalRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    @State private var moonPetalCurrentUser: BlushBloomUserModel?
    @State private var moonPetalUsers: [BlushBloomUserModel] = []

    var body: some View {
        HoneyGlowRelationShellView(title: "BLACKLIST") {
            HoneyGlowRelationListView(
                items: moonPetalBlacklistItems,
                actionTitle: "",
                actionSymbol: "minus",
                actionTextOffsetY: -1,
                emptyText: "No blocked users yet.",
                openAction: { moonPetalItem in
                    moonPetalRouter?.push(.moonPetalUserProfile(userID: moonPetalItem.id))
                },
                action: { moonPetalItem in
                    moonPetalRemoveBlockedUser(userID: moonPetalItem.id)
                }
            )
        }
        .onAppear {
            moonPetalLoadUsers()
        }
    }

    private var moonPetalBlacklistItems: [HoneyGlowRelationItem] {
        guard let moonPetalCurrentUser else {
            return []
        }

        return moonPetalCurrentUser.blushBloomBlockedIDs.compactMap { moonPetalUserID in
            moonPetalUsers.first { $0.blushBloomUserID == moonPetalUserID }
        }
        .map(moonPetalRelationItem)
    }

    private func moonPetalLoadUsers() {
        do {
            let moonPetalLoadedUsers = try RadiantDewLocalDataCenter.shared.radiantDewUsers.readAll()
            moonPetalUsers = moonPetalLoadedUsers

            if let moonPetalCurrentUserID = SilkBloomLoginSessionStore.currentUserID {
                moonPetalCurrentUser = moonPetalLoadedUsers.first { $0.blushBloomUserID == moonPetalCurrentUserID }
            } else {
                moonPetalCurrentUser = nil
            }
        } catch {
            roseMistOverlayCenter.showToast("Blacklist data failed to load.", style: .error)
        }
    }

    private func moonPetalRemoveBlockedUser(userID moonPetalUserID: String) {
        guard var moonPetalCurrentUser else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        do {
            moonPetalCurrentUser.blushBloomBlockedIDs.removeAll { $0 == moonPetalUserID }
            try RadiantDewLocalDataCenter.shared.radiantDewUsers.update(moonPetalCurrentUser)
            roseMistOverlayCenter.showToast("Removed from blacklist.", style: .success)
            moonPetalLoadUsers()
        } catch {
            roseMistOverlayCenter.showToast("Remove failed.", style: .error)
        }
    }

    private func moonPetalRelationItem(for moonPetalUser: BlushBloomUserModel) -> HoneyGlowRelationItem {
        HoneyGlowRelationItem(
            id: moonPetalUser.blushBloomUserID,
            name: moonPetalUser.blushBloomUserName.isEmpty ? "VENNE" : moonPetalUser.blushBloomUserName,
            subtitle: moonPetalSubtitle(for: moonPetalUser),
            avatarAddress: moonPetalUser.blushBloomAvatar.isEmpty ? "VENNEDefaultAvatar" : moonPetalUser.blushBloomAvatar
        )
    }

    private func moonPetalSubtitle(for moonPetalUser: BlushBloomUserModel) -> String {
        let moonPetalParts = [
            moonPetalUser.blushBloomLocation.trimmingCharacters(in: .whitespacesAndNewlines),
            moonPetalUser.blushBloomGender.trimmingCharacters(in: .whitespacesAndNewlines)
        ].filter { $0.isEmpty == false }

        return moonPetalParts.isEmpty ? "Blocked beauty profile." : moonPetalParts.joined(separator: " · ")
    }
}

#Preview {
    MoonPetalBlacklistView()
        .environmentObject(RoseMistOverlayCenter())
}
