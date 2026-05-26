import SwiftUI

struct BlushBloomFollowView: View {
    @Environment(\.crystalBlushRouter) private var blushBloomRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    @State private var blushBloomCurrentUser: BlushBloomUserModel?
    @State private var blushBloomUsers: [BlushBloomUserModel] = []

    var body: some View {
        HoneyGlowRelationShellView(title: "FOLLOW") {
            HoneyGlowRelationListView(
                items: blushBloomFollowItems,
                actionTitle: "",
                actionSymbol: "minus",
                actionTextOffsetY: -1,
                emptyText: "No following users yet.",
                openAction: { blushBloomItem in
                    blushBloomRouter?.push(.moonPetalUserProfile(userID: blushBloomItem.id))
                },
                action: { blushBloomItem in
                    blushBloomUnfollow(userID: blushBloomItem.id)
                }
            )
        }
        .onAppear {
            blushBloomLoadUsers()
        }
    }

    private var blushBloomFollowItems: [HoneyGlowRelationItem] {
        guard let blushBloomCurrentUser else {
            return []
        }

        return blushBloomCurrentUser.blushBloomFollowingIDs.compactMap { blushBloomUserID in
            blushBloomUsers.first { $0.blushBloomUserID == blushBloomUserID }
        }
        .map(blushBloomRelationItem)
    }

    private func blushBloomLoadUsers() {
        do {
            let blushBloomLoadedUsers = try RadiantDewLocalDataCenter.shared.radiantDewUsers.readAll()
            blushBloomUsers = blushBloomLoadedUsers

            if let blushBloomCurrentUserID = SilkBloomLoginSessionStore.currentUserID {
                blushBloomCurrentUser = blushBloomLoadedUsers.first { $0.blushBloomUserID == blushBloomCurrentUserID }
            } else {
                blushBloomCurrentUser = nil
            }
        } catch {
            roseMistOverlayCenter.showToast("Follow data failed to load.", style: .error)
        }
    }

    private func blushBloomUnfollow(userID blushBloomUserID: String) {
        guard var blushBloomCurrentUser else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        do {
            blushBloomCurrentUser.blushBloomFollowingIDs.removeAll { $0 == blushBloomUserID }

            if var blushBloomTargetUser = blushBloomUsers.first(where: { $0.blushBloomUserID == blushBloomUserID }) {
                blushBloomTargetUser.blushBloomFanIDs.removeAll { $0 == blushBloomCurrentUser.blushBloomUserID }
                try RadiantDewLocalDataCenter.shared.radiantDewUsers.update(blushBloomTargetUser)
            }

            try RadiantDewLocalDataCenter.shared.radiantDewUsers.update(blushBloomCurrentUser)
            roseMistOverlayCenter.showToast("Unfollowed.", style: .success)
            blushBloomLoadUsers()
        } catch {
            roseMistOverlayCenter.showToast("Unfollow failed.", style: .error)
        }
    }

    private func blushBloomRelationItem(for blushBloomUser: BlushBloomUserModel) -> HoneyGlowRelationItem {
        HoneyGlowRelationItem(
            id: blushBloomUser.blushBloomUserID,
            name: blushBloomUser.blushBloomUserName.isEmpty ? "VENNE" : blushBloomUser.blushBloomUserName,
            subtitle: blushBloomSubtitle(for: blushBloomUser),
            avatarAddress: blushBloomUser.blushBloomAvatar.isEmpty ? "VENNEDefaultAvatar" : blushBloomUser.blushBloomAvatar
        )
    }

    private func blushBloomSubtitle(for blushBloomUser: BlushBloomUserModel) -> String {
        let blushBloomLocation = blushBloomUser.blushBloomLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        let blushBloomGender = blushBloomUser.blushBloomGender.trimmingCharacters(in: .whitespacesAndNewlines)
        return [blushBloomLocation, blushBloomGender].filter { $0.isEmpty == false }.joined(separator: " · ").isEmpty
            ? "Beauty friend in Venne."
            : [blushBloomLocation, blushBloomGender].filter { $0.isEmpty == false }.joined(separator: " · ")
    }
}

#Preview {
    BlushBloomFollowView()
        .environmentObject(RoseMistOverlayCenter())
}
