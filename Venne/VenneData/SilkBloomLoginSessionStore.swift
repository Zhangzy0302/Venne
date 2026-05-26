import Foundation

enum SilkBloomLoginSessionStore {
    static var currentUserID: String? {
        MoonVelvetPersistentGlobals.moonVelvetCurrentLoginUserID
    }

    static func saveLoggedInUserID(_ silkBloomUserID: String) {
        MoonVelvetPersistentGlobals.moonVelvetCurrentLoginUserID = silkBloomUserID
    }

    static func clearLoggedInUserID() {
        MoonVelvetPersistentGlobals.moonVelvetClearLoginUserID()
    }
}
