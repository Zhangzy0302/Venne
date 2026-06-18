import SwiftUI
import Combine

enum CrystalBlushAppRoute: Hashable {
    case crystalBlushTabShell

    case blushBloomVenneGuide
    case velvetAuraAuthPortal
    case honeyGlowForgotPassword
    case moonPetalProfileDetails(email: String, password: String, userName: String)
    case crystalBlushEulaOverlay
    case honeyLuxeWebDisplay(webAddress: String)

    case honeyGlowHome
    case velvetAuraCommunity
    case glowMuseChatHub
    case petalLuxeProfile

    case blushBloomFollow
    case crystalBlushFans
    case moonPetalBlacklist
    case radiantDewSetting
    case silkBloomRecharge
    case velvetAuraEditProfile

    case radiantDewMakeupPreset
    case silkBloomPostDetail(postID: String)
    case blushBloomPublishPost
    case velvetAuraCreateEventChatRoom
    case rougeRibbonCreatePublishSheet

    case blushBloomGenerateResults
    case velvetAuraHistoricalWorks

    case crystalBlushEventGroupChat(roomID: String)
    case honeyLuxePrivateChatRoom(roomID: String)
    case pearlLuxeVideoCall(roomID: String)

    case moonPetalUserProfile(userID: String)
    case rougeRibbonReport(targetUserID: String)

    @ViewBuilder
    var crystalBlushDestination: some View {
        switch self {
        case .crystalBlushTabShell:
            CrystalBlushTabShellView()
        case .blushBloomVenneGuide:
            BlushBloomVenneGuideView()
        case .velvetAuraAuthPortal:
            VelvetAuraAuthPortalView()
        case .honeyGlowForgotPassword:
            HoneyGlowForgotPasswordView()
        case .moonPetalProfileDetails(let email, let password, let userName):
            MoonPetalProfileDetailsView(
                moonPetalInitialEmail: email,
                moonPetalPassword: password,
                moonPetalInitialUserName: userName
            )
        case .crystalBlushEulaOverlay:
            CrystalBlushEulaOverlayView()
        case .honeyLuxeWebDisplay(let webAddress):
            HoneyLuxeWebDisplayView(honeyLuxeWebAddress: webAddress)
        case .honeyGlowHome:
            HoneyGlowHomeView()
        case .velvetAuraCommunity:
            VelvetAuraCommunityView()
        case .glowMuseChatHub:
            GlowMuseChatHubView()
        case .petalLuxeProfile:
            PetalLuxeProfileView()
        case .blushBloomFollow:
            BlushBloomFollowView()
        case .crystalBlushFans:
            CrystalBlushFansView()
        case .moonPetalBlacklist:
            MoonPetalBlacklistView()
        case .radiantDewSetting:
            RadiantDewSettingView()
        case .silkBloomRecharge:
            SilkBloomRechargeView()
        case .velvetAuraEditProfile:
            VelvetAuraEditProfileView()
        case .radiantDewMakeupPreset:
            RadiantDewMakeupPresetView()
        case .silkBloomPostDetail(let postID):
            SilkBloomPostDetailView(silkBloomPostID: postID)
        case .blushBloomPublishPost:
            BlushBloomPublishPostView()
        case .velvetAuraCreateEventChatRoom:
            VelvetAuraCreateEventChatRoomView()
        case .rougeRibbonCreatePublishSheet:
            RougeRibbonCreatePublishSheet()
        case .blushBloomGenerateResults:
            BlushBloomGenerateResultsView()
        case .velvetAuraHistoricalWorks:
            VelvetAuraHistoricalWorksView()
        case .crystalBlushEventGroupChat(let roomID):
            CrystalBlushEventGroupChatView(crystalBlushRoomID: roomID)
        case .honeyLuxePrivateChatRoom(let roomID):
            HoneyLuxePrivateChatRoomView(honeyLuxeRoomID: roomID)
        case .pearlLuxeVideoCall(let roomID):
            PearlLuxeVideoCallView(pearlLuxeRoomID: roomID)
        case .moonPetalUserProfile(let userID):
            MoonPetalUserProfileView(moonPetalUserID: userID)
        case .rougeRibbonReport(let targetUserID):
            RougeRibbonReportView(rougeRibbonTargetUserID: targetUserID)
        }
    }

    var crystalBlushAllowsSwipeBack: Bool {
        switch self {
        case .honeyLuxeWebDisplay(let webAddress):
            return CrystalBlushAppRoute.crystalBlushIsBPackageWebAddress(webAddress) == false
        default:
            return true
        }
    }

    private static func crystalBlushIsBPackageWebAddress(_ crystalBlushWebAddress: String) -> Bool {
        let crystalBlushTrimmedAddress = crystalBlushWebAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let crystalBlushResolvedAddress: String

        if let crystalBlushURL = URL(string: crystalBlushTrimmedAddress),
           crystalBlushURL.scheme?.isEmpty == false {
            crystalBlushResolvedAddress = crystalBlushURL.absoluteString
        } else {
            crystalBlushResolvedAddress = "https://\(crystalBlushTrimmedAddress)"
        }

        return crystalBlushResolvedAddress.contains("openParams=")
            || crystalBlushResolvedAddress.contains("appId=")
    }
}

@MainActor
final class CrystalBlushAppRouter: ObservableObject {
    @Published var crystalBlushRootRoute: CrystalBlushAppRoute
    @Published var crystalBlushRoutePath: [CrystalBlushAppRoute] = []

    init() {
        crystalBlushRootRoute = MoonVelvetPersistentGlobals.moonVelvetCurrentLoginUserID == nil
            ? .blushBloomVenneGuide
            : .crystalBlushTabShell
    }

    var crystalBlushCurrentRoute: CrystalBlushAppRoute {
        crystalBlushRoutePath.last ?? crystalBlushRootRoute
    }

    var crystalBlushCanPop: Bool {
        !crystalBlushRoutePath.isEmpty
    }

    var crystalBlushCanSwipeBack: Bool {
        crystalBlushCanPop && crystalBlushCurrentRoute.crystalBlushAllowsSwipeBack
    }

    func push(_ crystalBlushRoute: CrystalBlushAppRoute) {
        crystalBlushRoutePath.append(crystalBlushRoute)
    }

    func push(_ crystalBlushRoutes: [CrystalBlushAppRoute]) {
        crystalBlushRoutePath.append(contentsOf: crystalBlushRoutes)
    }

    func pop() {
        guard !crystalBlushRoutePath.isEmpty else { return }
        crystalBlushRoutePath.removeLast()
    }

    func pop(_ crystalBlushCount: Int) {
        guard crystalBlushCount > 0 else { return }
        crystalBlushRoutePath.removeLast(min(crystalBlushCount, crystalBlushRoutePath.count))
    }

    func popToRoot() {
        crystalBlushRoutePath.removeAll()
    }

    func popToDepth(_ crystalBlushDepth: Int) {
        let crystalBlushSafeDepth = max(0, min(crystalBlushDepth, crystalBlushRoutePath.count))
        guard crystalBlushRoutePath.count > crystalBlushSafeDepth else { return }
        crystalBlushRoutePath.removeLast(crystalBlushRoutePath.count - crystalBlushSafeDepth)
    }

    func replaceRoot(with crystalBlushRoute: CrystalBlushAppRoute) {
        crystalBlushRootRoute = crystalBlushRoute
        crystalBlushRoutePath.removeAll()
    }

    func replacePath(with crystalBlushRoutes: [CrystalBlushAppRoute]) {
        crystalBlushRoutePath = crystalBlushRoutes
    }
}

private struct CrystalBlushRouterEnvironmentKey: EnvironmentKey {
    static let defaultValue: CrystalBlushAppRouter? = nil
}

extension EnvironmentValues {
    var crystalBlushRouter: CrystalBlushAppRouter? {
        get { self[CrystalBlushRouterEnvironmentKey.self] }
        set { self[CrystalBlushRouterEnvironmentKey.self] = newValue }
    }
}
