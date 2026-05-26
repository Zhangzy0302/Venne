import Foundation

enum PetalLuxeLocalSeedData {
    private static let petalLuxeSeededKey = "petal_luxe_local_seed_data_initialized"

    static func initializeIfNeeded(forceRefresh: Bool = false) {
        let petalLuxeDefaults = UserDefaults.standard

        guard forceRefresh || petalLuxeDefaults.bool(forKey: petalLuxeSeededKey) == false else {
            return
        }

        do {
            try seed(forceRefresh: forceRefresh)
            petalLuxeDefaults.set(true, forKey: petalLuxeSeededKey)
        } catch {
            assertionFailure("Failed to initialize Venne local seed data: \(error.localizedDescription)")
        }
    }

    static func resetAndSeed() throws {
        try seed(forceRefresh: true)
        UserDefaults.standard.set(true, forKey: petalLuxeSeededKey)
    }

    private static func seed(forceRefresh: Bool) throws {
        let petalLuxeDataCenter = RadiantDewLocalDataCenter.shared

        if forceRefresh {
            try petalLuxeDataCenter.radiantDewUsers.deleteAll()
            try petalLuxeDataCenter.radiantDewPosts.deleteAll()
            try petalLuxeDataCenter.radiantDewComments.deleteAll()
            try petalLuxeDataCenter.radiantDewChatRooms.deleteAll()
            try petalLuxeDataCenter.radiantDewChatMessages.deleteAll()
        }

        try petalLuxeUsers.forEach { try petalLuxeDataCenter.radiantDewUsers.upsert($0) }
        try petalLuxePosts.forEach { try petalLuxeDataCenter.radiantDewPosts.upsert($0) }
        try petalLuxeComments.forEach { try petalLuxeDataCenter.radiantDewComments.upsert($0) }
        try petalLuxeChatRooms.forEach { try petalLuxeDataCenter.radiantDewChatRooms.upsert($0) }
        try petalLuxeChatMessages.forEach { try petalLuxeDataCenter.radiantDewChatMessages.upsert($0) }
    }

    private static var petalLuxeUsers: [BlushBloomUserModel] {
        [
            BlushBloomUserModel(
                blushBloomUserID: "venner_0",
                blushBloomEmail: "venne@gmail.com",
                blushBloomPassword: "123456",
                blushBloomAvatar: "VEOPWAva_0",
                blushBloomUserName: "Nash",
                blushBloomBirthdayDate: petalLuxeDate(year: 2003, month: 1, day: 3),
                blushBloomLocation: "LA",
                blushBloomGender: "Male",
                blushBloomFanIDs: ["venner_1", "venner_2"],
                blushBloomFollowingIDs: ["venner_1"],
                blushBloomBlockedIDs: [],
                blushBloomCoinCount: 0,
                blushBloomIsGuest: false,
                blushBloomAboutMe: ""
            ),
            BlushBloomUserModel(
                blushBloomUserID: "venner_1",
                blushBloomEmail: "Kevin@venne.local",
                blushBloomPassword: "scw13r32eq",
                blushBloomAvatar: "VEOPWAva_1",
                blushBloomUserName: "Kevin",
                blushBloomBirthdayDate: petalLuxeDate(year: 2002, month: 4, day: 7),
                blushBloomLocation: "NY",
                blushBloomGender: "Male",
                blushBloomFanIDs: ["venner_0"],
                blushBloomFollowingIDs: ["venner_0"],
                blushBloomBlockedIDs: [],
                blushBloomCoinCount: 400,
                blushBloomIsGuest: false,
                blushBloomAboutMe: ""
            ),
            BlushBloomUserModel(
                blushBloomUserID: "venner_2",
                blushBloomEmail: "Mason@asdawb.local",
                blushBloomPassword: "brr32yre",
                blushBloomAvatar: "VEOPWAva_2",
                blushBloomUserName: "Mason",
                blushBloomBirthdayDate: petalLuxeDate(year: 2002, month: 4, day: 7),
                blushBloomLocation: "NY",
                blushBloomGender: "Male",
                blushBloomFanIDs: [],
                blushBloomFollowingIDs: ["venner_0"],
                blushBloomBlockedIDs: [],
                blushBloomCoinCount: 400,
                blushBloomIsGuest: false,
                blushBloomAboutMe: ""
            ),
            BlushBloomUserModel(
                blushBloomUserID: "venner_3",
                blushBloomEmail: "Ruby@venne.dasd",
                blushBloomPassword: "123456",
                blushBloomAvatar: "VEOPWAva_3",
                blushBloomUserName: "Ruby",
                blushBloomBirthdayDate: petalLuxeDate(year: 2002, month: 4, day: 7),
                blushBloomLocation: "NY",
                blushBloomGender: "Female",
                blushBloomFanIDs: [],
                blushBloomFollowingIDs: [],
                blushBloomBlockedIDs: [],
                blushBloomCoinCount: 400,
                blushBloomIsGuest: false,
                blushBloomAboutMe: ""
            ),
            BlushBloomUserModel(
                blushBloomUserID: "venner_4",
                blushBloomEmail: "Christie@venne.local",
                blushBloomPassword: "123456",
                blushBloomAvatar: "VEOPWAva_4",
                blushBloomUserName: "Christie",
                blushBloomBirthdayDate: petalLuxeDate(year: 2002, month: 4, day: 7),
                blushBloomLocation: "NY",
                blushBloomGender: "Female",
                blushBloomFanIDs: [],
                blushBloomFollowingIDs: [],
                blushBloomBlockedIDs: [],
                blushBloomCoinCount: 400,
                blushBloomIsGuest: false,
                blushBloomAboutMe: ""
            ),
            BlushBloomUserModel(
                blushBloomUserID: "venner_5",
                blushBloomEmail: "Gloria@venne.local",
                blushBloomPassword: "123456",
                blushBloomAvatar: "VEOPWAva_5",
                blushBloomUserName: "Gloria",
                blushBloomBirthdayDate: petalLuxeDate(year: 2002, month: 4, day: 7),
                blushBloomLocation: "NY",
                blushBloomGender: "Female",
                blushBloomFanIDs: [],
                blushBloomFollowingIDs: [],
                blushBloomBlockedIDs: [],
                blushBloomCoinCount: 400,
                blushBloomIsGuest: false,
                blushBloomAboutMe: ""
            ),
        ]
    }

    private static var petalLuxePosts: [VelvetAuraPostModel] {
        [
            VelvetAuraPostModel(
                velvetAuraPostID: "post_blush_001",
                velvetAuraPublisherID: "venner_1",
                velvetAuraImageList: ["VAOIVPost_3", "VAOIVPost_4", "VAOIVPost_5"],
                velvetAuraCopywritingContent: "Trim facial features with simple makeup, upgrade temperament easily.",
                velvetAuraLikeCount: 103
            ),
            VelvetAuraPostModel(
                velvetAuraPostID: "post_blush_002",
                velvetAuraPublisherID: "venner_2",
                velvetAuraImageList: ["VAOIVPost_6", "VAOIVPost_7", "VAOIVPost_8"],
                velvetAuraCopywritingContent: "Simple daily makeup, keep a comfortable look all day.",
                velvetAuraLikeCount: 103
            ),
            VelvetAuraPostModel(
                velvetAuraPostID: "post_glow_003",
                velvetAuraPublisherID: "venner_0",
                velvetAuraImageList: ["VAOIVPost_0", "VAOIVPost_1", "VAOIVPost_2"],
                velvetAuraCopywritingContent: "Men’s refined makeup, clean and low-key texture.",
                velvetAuraLikeCount: 222
            ),
            VelvetAuraPostModel(
                velvetAuraPostID: "post_blush_004",
                velvetAuraPublisherID: "venner_3",
                velvetAuraImageList: ["VAOIVPost_9", "VAOIVPost_10"],
                velvetAuraCopywritingContent: "Adjust your makeup mood, live your own aesthetic.",
                velvetAuraLikeCount: 103
            ),
            VelvetAuraPostModel(
                velvetAuraPostID: "post_blush_005",
                velvetAuraPublisherID: "venner_04",
                velvetAuraImageList: ["VAOIVPost_11", "VAOIVPost_12", "VAOIVPost_13"],
                velvetAuraCopywritingContent: "Light makeup fits all occasions, effortless beauty.",
                velvetAuraLikeCount: 103
            )
        ]
    }

    private static var petalLuxeComments: [HoneyGlowCommentModel] {
        [
            HoneyGlowCommentModel(
                honeyGlowCommentID: "comment_peach_001",
                honeyGlowVideoID: "post_blush_002",
                honeyGlowPublisherID: "venner_4",
                honeyGlowContent: "Peach is perfect on you! Post a close-up!",
                honeyGlowCommentedAt: petalLuxeDate(year: 2026, month: 5, day: 14, hour: 10, minute: 12)
            )
        ]
    }

    private static var petalLuxeChatRooms: [MoonPetalChatRoomModel] {
        [
            MoonPetalChatRoomModel(
                moonPetalRoomID: "room_private_dashi_nova",
                moonPetalUserIDs: ["venner_0", "venner_1"],
                moonPetalLastMessageSentAt: petalLuxeDate(year: 2026, month: 5, day: 14, hour: 11, minute: 20),
                moonPetalLastSenderID: "venner_0",
                moonPetalLastMessageText: "hello what are you doing?",
                moonPetalUnreadMessageCount: 0,
                moonPetalIsGroupChat: false,
                moonPetalGroupCoverImage: "",
                moonPetalGroupRoomName: "",
                moonPetalGroupRoomIntro: ""
            ),
            MoonPetalChatRoomModel(
                moonPetalRoomID: "room_glow_talk",
                moonPetalUserIDs: ["venner_2", "venner_3", "venner_5"],
                moonPetalLastMessageSentAt: petalLuxeDate(year: 2026, month: 5, day: 14, hour: 12, minute: 5),
                moonPetalLastSenderID: "",
                moonPetalLastMessageText: "",
                moonPetalUnreadMessageCount: 0,
                moonPetalIsGroupChat: true,
                moonPetalGroupCoverImage: "VENNWRoomCover_0",
                moonPetalGroupRoomName: "Glow Beauty Hub",
                moonPetalGroupRoomIntro: "Share makeup tips, skincare routines and daily beauty looks. Explore trending cosmetics and grow your glow together."
            ),
            MoonPetalChatRoomModel(
                moonPetalRoomID: "room_makeup_lovers",
                moonPetalUserIDs: ["venner_2", "venner_3"],
                moonPetalLastMessageSentAt: petalLuxeDate(year: 2026, month: 5, day: 14, hour: 12, minute: 5),
                moonPetalLastSenderID: "",
                moonPetalLastMessageText: "",
                moonPetalUnreadMessageCount: 0,
                moonPetalIsGroupChat: true,
                moonPetalGroupCoverImage: "VENNWRoomCover_1",
                moonPetalGroupRoomName: "Makeup Lovers Club",
                moonPetalGroupRoomIntro: "A paradise for makeup enthusiasts. Exchange makeup tutorials, product reviews and all beauty secrets here."
            ),
            MoonPetalChatRoomModel(
                moonPetalRoomID: "room_beauty_expert",
                moonPetalUserIDs: ["venner_4", "venner_1", "venner_5"],
                moonPetalLastMessageSentAt: petalLuxeDate(year: 2026, month: 5, day: 14, hour: 12, minute: 5),
                moonPetalLastSenderID: "",
                moonPetalLastMessageText: "",
                moonPetalUnreadMessageCount: 0,
                moonPetalIsGroupChat: true,
                moonPetalGroupCoverImage: "VENNWRoomCover_2",
                moonPetalGroupRoomName: "Beauty Expert Circle",
                moonPetalGroupRoomIntro: "Professional makeup sharing, problem solving for skin care and free discussion of all beauty topics."
            )
        ]
    }

    private static var petalLuxeChatMessages: [SilkBloomChatMessageModel] {
        [
            SilkBloomChatMessageModel(
                silkBloomMessageID: "message_private_001",
                silkBloomRoomID: "room_private_dashi_nova",
                silkBloomSenderID: "venner_1",
                silkBloomTextMessage: "Hi, how are you today?",
                silkBloomVoiceMessagePath: "",
                silkBloomVoiceDuration: 0,
                silkBloomSentAt: petalLuxeDate(year: 2026, month: 5, day: 14, hour: 11, minute: 18)
            ),
            SilkBloomChatMessageModel(
                silkBloomMessageID: "message_private_002",
                silkBloomRoomID: "room_private_dashi_nova",
                silkBloomSenderID: "venner_0",
                silkBloomTextMessage: "I'm good. what about you?",
                silkBloomVoiceMessagePath: "",
                silkBloomVoiceDuration: 0,
                silkBloomSentAt: petalLuxeDate(year: 2026, month: 5, day: 14, hour: 11, minute: 19)
            ),
            SilkBloomChatMessageModel(
                silkBloomMessageID: "message_private_003",
                silkBloomRoomID: "room_private_dashi_nova",
                silkBloomSenderID: "venner_1",
                silkBloomTextMessage: "hello what are you doing?",
                silkBloomVoiceMessagePath: "",
                silkBloomVoiceDuration: 0,
                silkBloomSentAt: petalLuxeDate(year: 2026, month: 5, day: 14, hour: 11, minute: 20)
            ),
            SilkBloomChatMessageModel(
                silkBloomMessageID: "message_group_001",
                silkBloomRoomID: "room_glow_talk",
                silkBloomSenderID: "venner_2",
                silkBloomTextMessage: "Tried a peachy blush today. Can't tell if it's cute or too much lol.",
                silkBloomVoiceMessagePath: "",
                silkBloomVoiceDuration: 0,
                silkBloomSentAt: petalLuxeDate(year: 2026, month: 5, day: 14, hour: 11, minute: 58)
            ),
            SilkBloomChatMessageModel(
                silkBloomMessageID: "message_group_002",
                silkBloomRoomID: "room_glow_talk",
                silkBloomSenderID: "venner_3",
                silkBloomTextMessage: "I did peach + gold shimmer yesterday!",
                silkBloomVoiceMessagePath: "",
                silkBloomVoiceDuration: 0,
                silkBloomSentAt: petalLuxeDate(year: 2026, month: 5, day: 14, hour: 12, minute: 5)
            )
        ]
    }

    private static func petalLuxeDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0
    ) -> Date {
        Calendar.current.date(
            from: DateComponents(
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute
            )
        ) ?? Date()
    }
}
