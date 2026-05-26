import SwiftUI

struct CrystalBlushFansView: View {
    @Environment(\.crystalBlushRouter) private var crystalBlushRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    @State private var crystalBlushCurrentUser: BlushBloomUserModel?
    @State private var crystalBlushUsers: [BlushBloomUserModel] = []

    var body: some View {
        HoneyGlowRelationShellView(title: "FANS") {
            HoneyGlowRelationListView(
                items: crystalBlushFansItems,
                actionTitle: "",
                actionSymbol: "plus",
                actionTextOffsetY: 0,
                emptyText: "No fans yet.",
                actionVisible: { crystalBlushItem in
                    crystalBlushCurrentUser?.blushBloomFollowingIDs.contains(crystalBlushItem.id) == false
                },
                openAction: { crystalBlushItem in
                    crystalBlushRouter?.push(.moonPetalUserProfile(userID: crystalBlushItem.id))
                },
                action: { crystalBlushItem in
                    crystalBlushFollowFan(userID: crystalBlushItem.id)
                }
            )
        }
        .onAppear {
            crystalBlushLoadUsers()
        }
    }

    private var crystalBlushFansItems: [HoneyGlowRelationItem] {
        guard let crystalBlushCurrentUser else {
            return []
        }

        return crystalBlushCurrentUser.blushBloomFanIDs.compactMap { crystalBlushUserID in
            crystalBlushUsers.first { $0.blushBloomUserID == crystalBlushUserID }
        }
        .map(crystalBlushRelationItem)
    }

    private func crystalBlushLoadUsers() {
        do {
            let crystalBlushLoadedUsers = try RadiantDewLocalDataCenter.shared.radiantDewUsers.readAll()
            crystalBlushUsers = crystalBlushLoadedUsers

            if let crystalBlushCurrentUserID = SilkBloomLoginSessionStore.currentUserID {
                crystalBlushCurrentUser = crystalBlushLoadedUsers.first { $0.blushBloomUserID == crystalBlushCurrentUserID }
            } else {
                crystalBlushCurrentUser = nil
            }
        } catch {
            roseMistOverlayCenter.showToast("Fans data failed to load.", style: .error)
        }
    }

    private func crystalBlushFollowFan(userID crystalBlushUserID: String) {
        guard var crystalBlushCurrentUser else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        guard crystalBlushCurrentUser.blushBloomFollowingIDs.contains(crystalBlushUserID) == false else {
            roseMistOverlayCenter.showToast("Already followed.", style: .normal)
            return
        }

        do {
            crystalBlushCurrentUser.blushBloomFollowingIDs.append(crystalBlushUserID)

            if var crystalBlushTargetUser = crystalBlushUsers.first(where: { $0.blushBloomUserID == crystalBlushUserID }),
               crystalBlushTargetUser.blushBloomFanIDs.contains(crystalBlushCurrentUser.blushBloomUserID) == false {
                crystalBlushTargetUser.blushBloomFanIDs.append(crystalBlushCurrentUser.blushBloomUserID)
                try RadiantDewLocalDataCenter.shared.radiantDewUsers.update(crystalBlushTargetUser)
            }

            try RadiantDewLocalDataCenter.shared.radiantDewUsers.update(crystalBlushCurrentUser)
            roseMistOverlayCenter.showToast("Followed.", style: .success)
            crystalBlushLoadUsers()
        } catch {
            roseMistOverlayCenter.showToast("Follow failed.", style: .error)
        }
    }

    private func crystalBlushRelationItem(for crystalBlushUser: BlushBloomUserModel) -> HoneyGlowRelationItem {
        HoneyGlowRelationItem(
            id: crystalBlushUser.blushBloomUserID,
            name: crystalBlushUser.blushBloomUserName.isEmpty ? "VENNE" : crystalBlushUser.blushBloomUserName,
            subtitle: crystalBlushSubtitle(for: crystalBlushUser),
            avatarAddress: crystalBlushUser.blushBloomAvatar.isEmpty ? "VENNEDefaultAvatar" : crystalBlushUser.blushBloomAvatar
        )
    }

    private func crystalBlushSubtitle(for crystalBlushUser: BlushBloomUserModel) -> String {
        let crystalBlushParts = [
            crystalBlushUser.blushBloomLocation.trimmingCharacters(in: .whitespacesAndNewlines),
            crystalBlushUser.blushBloomGender.trimmingCharacters(in: .whitespacesAndNewlines)
        ].filter { $0.isEmpty == false }

        return crystalBlushParts.isEmpty ? "Beauty friend in Venne." : crystalBlushParts.joined(separator: " · ")
    }
}

#Preview {
    CrystalBlushFansView()
        .environmentObject(RoseMistOverlayCenter())
}
