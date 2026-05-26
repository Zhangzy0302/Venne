import Foundation

enum PeachMistGuestAccessGuard {
    static func peachMistIsGuestSession() -> Bool {
        guard let peachMistCurrentUserID = SilkBloomLoginSessionStore.currentUserID else {
            return true
        }

        do {
            let peachMistCurrentUser = try RadiantDewLocalDataCenter.shared.radiantDewUsers.read(id: peachMistCurrentUserID)
            return peachMistCurrentUser?.blushBloomIsGuest == true
        } catch {
            return true
        }
    }

    @MainActor
    static func peachMistRequireMemberAccess(
        overlayCenter peachMistOverlayCenter: RoseMistOverlayCenter,
        action peachMistAction: () -> Void
    ) {
        if peachMistIsGuestSession() {
            peachMistOverlayCenter.showGuestLoginPrompt()
        } else {
            peachMistAction()
        }
    }
}
