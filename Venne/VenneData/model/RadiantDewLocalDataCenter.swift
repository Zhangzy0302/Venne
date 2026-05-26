import Foundation

final class RadiantDewLocalDataCenter {
    static let shared = RadiantDewLocalDataCenter()

    let radiantDewUsers = CrystalBlushLocalRepository<BlushBloomUserModel>()
    let radiantDewPosts = CrystalBlushLocalRepository<VelvetAuraPostModel>()
    let radiantDewComments = CrystalBlushLocalRepository<HoneyGlowCommentModel>()
    let radiantDewChatRooms = CrystalBlushLocalRepository<MoonPetalChatRoomModel>()
    let radiantDewChatMessages = CrystalBlushLocalRepository<SilkBloomChatMessageModel>()
    let radiantDewAIHistoricalWorks = CrystalBlushLocalRepository<MoonPetalAIHistoricalWorkModel>()

    private init() {}
}
