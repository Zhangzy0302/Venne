import Foundation

enum MoonVelvetPersistentGlobals {
    private static let moonVelvetDidAgreeAgreementKey = "moon_velvet_did_agree_agreement"
    private static let moonVelvetDidAgreeEULAKey = "moon_velvet_did_agree_eula"
    private static let moonVelvetCurrentLoginUserIDKey = "silk_bloom_logged_in_user_id"
    private static let moonVelvetLatestAIImageNameKey = "moon_velvet_latest_ai_image_name"
    private static let moonVelvetUsedAIImageNamesKey = "moon_velvet_used_ai_image_names"

    private static let moonVelvetAIImagePool = (0...5).map { "VENNEAiCreate_\($0)" }

    static var moonVelvetDidAgreeAgreement: Bool {
        get {
            UserDefaults.standard.bool(forKey: moonVelvetDidAgreeAgreementKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: moonVelvetDidAgreeAgreementKey)
        }
    }

    static var moonVelvetDidAgreeEULA: Bool {
        get {
            UserDefaults.standard.bool(forKey: moonVelvetDidAgreeEULAKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: moonVelvetDidAgreeEULAKey)
        }
    }

    static var moonVelvetCurrentLoginUserID: String? {
        get {
            let moonVelvetUserID = UserDefaults.standard.string(forKey: moonVelvetCurrentLoginUserIDKey)
            return moonVelvetUserID?.isEmpty == false ? moonVelvetUserID : nil
        }
        set {
            if let newValue, newValue.isEmpty == false {
                UserDefaults.standard.set(newValue, forKey: moonVelvetCurrentLoginUserIDKey)
            } else {
                UserDefaults.standard.removeObject(forKey: moonVelvetCurrentLoginUserIDKey)
            }
        }
    }

    static func moonVelvetClearLoginUserID() {
        moonVelvetCurrentLoginUserID = nil
    }

    static var moonVelvetLatestAIImageName: String {
        let moonVelvetImageName = UserDefaults.standard.string(forKey: moonVelvetLatestAIImageNameKey)
        return moonVelvetImageName?.isEmpty == false ? moonVelvetImageName! : "VENNEAiCreate_0"
    }

    static func moonVelvetGenerateUniqueAIImageName() -> String {
        var moonVelvetUsedImageNames = UserDefaults.standard.stringArray(forKey: moonVelvetUsedAIImageNamesKey) ?? []
        var moonVelvetAvailableImageNames = moonVelvetAIImagePool.filter { moonVelvetUsedImageNames.contains($0) == false }

        if moonVelvetAvailableImageNames.isEmpty {
            moonVelvetUsedImageNames = []
            moonVelvetAvailableImageNames = moonVelvetAIImagePool
        }

        let moonVelvetSelectedImageName = moonVelvetAvailableImageNames.randomElement() ?? "VENNEAiCreate_0"
        moonVelvetUsedImageNames.append(moonVelvetSelectedImageName)

        UserDefaults.standard.set(moonVelvetSelectedImageName, forKey: moonVelvetLatestAIImageNameKey)
        UserDefaults.standard.set(moonVelvetUsedImageNames, forKey: moonVelvetUsedAIImageNamesKey)

        return moonVelvetSelectedImageName
    }
}
