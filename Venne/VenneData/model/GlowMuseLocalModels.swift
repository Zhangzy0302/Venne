import Foundation

struct BlushBloomUserModel: CrystalBlushLocalPersistable, Hashable {
    static let crystalBlushStorageFileName = "blush_bloom_users.json"

    var id: String { blushBloomUserID }

    var blushBloomUserID: String
    var blushBloomEmail: String
    var blushBloomPassword: String
    var blushBloomAvatar: String
    var blushBloomUserName: String
    var blushBloomBirthdayDate: Date
    var blushBloomLocation: String
    var blushBloomGender: String
    var blushBloomFanIDs: [String]
    var blushBloomFollowingIDs: [String]
    var blushBloomBlockedIDs: [String]
    var blushBloomCoinCount: Int
    var blushBloomIsGuest: Bool
    var blushBloomLikedPostIDs: [String] = []
    var blushBloomAboutMe: String = ""
}

extension BlushBloomUserModel {
    private enum CodingKeys: String, CodingKey {
        case blushBloomUserID
        case blushBloomEmail
        case blushBloomPassword
        case blushBloomAvatar
        case blushBloomUserName
        case blushBloomBirthdayDate
        case blushBloomLocation
        case blushBloomGender
        case blushBloomFanIDs
        case blushBloomFollowingIDs
        case blushBloomBlockedIDs
        case blushBloomCoinCount
        case blushBloomIsGuest
        case blushBloomLikedPostIDs
        case blushBloomAboutMe
    }

    init(from decoder: Decoder) throws {
        let blushBloomContainer = try decoder.container(keyedBy: CodingKeys.self)
        blushBloomUserID = try blushBloomContainer.decode(String.self, forKey: .blushBloomUserID)
        blushBloomEmail = try blushBloomContainer.decode(String.self, forKey: .blushBloomEmail)
        blushBloomPassword = try blushBloomContainer.decode(String.self, forKey: .blushBloomPassword)
        blushBloomAvatar = try blushBloomContainer.decode(String.self, forKey: .blushBloomAvatar)
        blushBloomUserName = try blushBloomContainer.decode(String.self, forKey: .blushBloomUserName)
        blushBloomBirthdayDate = try blushBloomContainer.decode(Date.self, forKey: .blushBloomBirthdayDate)
        blushBloomLocation = try blushBloomContainer.decode(String.self, forKey: .blushBloomLocation)
        blushBloomGender = try blushBloomContainer.decode(String.self, forKey: .blushBloomGender)
        blushBloomFanIDs = try blushBloomContainer.decode([String].self, forKey: .blushBloomFanIDs)
        blushBloomFollowingIDs = try blushBloomContainer.decode([String].self, forKey: .blushBloomFollowingIDs)
        blushBloomBlockedIDs = try blushBloomContainer.decode([String].self, forKey: .blushBloomBlockedIDs)
        blushBloomCoinCount = try blushBloomContainer.decode(Int.self, forKey: .blushBloomCoinCount)
        blushBloomIsGuest = try blushBloomContainer.decode(Bool.self, forKey: .blushBloomIsGuest)
        blushBloomLikedPostIDs = try blushBloomContainer.decodeIfPresent([String].self, forKey: .blushBloomLikedPostIDs) ?? []
        blushBloomAboutMe = try blushBloomContainer.decodeIfPresent(String.self, forKey: .blushBloomAboutMe) ?? ""
    }
}

struct VelvetAuraPostModel: CrystalBlushLocalPersistable, Hashable {
    static let crystalBlushStorageFileName = "velvet_aura_posts.json"

    var id: String { velvetAuraPostID }

    var velvetAuraPostID: String
    var velvetAuraPublisherID: String
    var velvetAuraImageList: [String]
    var velvetAuraCopywritingContent: String
    var velvetAuraLikeCount: Int
}

struct HoneyGlowCommentModel: CrystalBlushLocalPersistable, Hashable {
    static let crystalBlushStorageFileName = "honey_glow_comments.json"

    var id: String { honeyGlowCommentID }

    var honeyGlowCommentID: String
    var honeyGlowVideoID: String
    var honeyGlowPublisherID: String
    var honeyGlowContent: String
    var honeyGlowCommentedAt: Date
}

struct MoonPetalChatRoomModel: CrystalBlushLocalPersistable, Hashable {
    static let crystalBlushStorageFileName = "moon_petal_chat_rooms.json"

    var id: String { moonPetalRoomID }

    var moonPetalRoomID: String
    var moonPetalUserIDs: [String]
    var moonPetalLastMessageSentAt: Date
    var moonPetalLastSenderID: String
    var moonPetalLastMessageText: String
    var moonPetalUnreadMessageCount: Int
    var moonPetalIsGroupChat: Bool
    var moonPetalGroupCoverImage: String
    var moonPetalGroupRoomName: String
    var moonPetalGroupRoomIntro: String
}

struct SilkBloomChatMessageModel: CrystalBlushLocalPersistable, Hashable {
    static let crystalBlushStorageFileName = "silk_bloom_chat_messages.json"

    var id: String { silkBloomMessageID }

    var silkBloomMessageID: String
    var silkBloomRoomID: String
    var silkBloomSenderID: String
    var silkBloomTextMessage: String
    var silkBloomVoiceMessagePath: String
    var silkBloomVoiceDuration: TimeInterval
    var silkBloomSentAt: Date
}

struct MoonPetalAIHistoricalWorkModel: CrystalBlushLocalPersistable, Hashable {
    static let crystalBlushStorageFileName = "moon_petal_ai_historical_works.json"

    var id: String { moonPetalWorkID }

    var moonPetalWorkID: String
    var moonPetalOwnerUserID: String
    var moonPetalAuthorName: String
    var moonPetalImageName: String
    var moonPetalSavedAt: Date
}
