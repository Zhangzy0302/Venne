import SwiftUI

struct CrystalBlushTabShellView: View {
    @Environment(\.crystalBlushRouter) private var crystalBlushRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    @State private var crystalBlushSelectedTab: CrystalBlushTab = .home
    @State private var crystalBlushShowsCreatePublishSheet = false

    var body: some View {
        ZStack {
            GlowMuseTheme.blushBloomPrimaryText
                .ignoresSafeArea()
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    RougeRibbonGuideBackground()
                        

                    Group {
                        switch crystalBlushSelectedTab {
                        case .home:
                            HoneyGlowHomeView {
                                PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                                    crystalBlushShowsCreatePublishSheet = true
                                }
                            }
                        case .community:
                            VelvetAuraCommunityView()
                        case .message:
                            GlowMuseChatHubView()
                        case .profile:
                            PetalLuxeProfileView()
                        }
                    }
                    .id(crystalBlushSelectedTab)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .clipShape(CrystalBlushUnevenRoundedRectangle(bottomLeadingRadius: 52))
                .ignoresSafeArea(edges: .top)
            }
            
            
            
            
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            crystalBlushTabBar
                .background(GlowMuseTheme.blushBloomPrimaryText)
        }.overlay{
            if crystalBlushShowsCreatePublishSheet {
                RougeRibbonCreatePublishSheet(
                    onClose: {
                        crystalBlushShowsCreatePublishSheet = false
                    },
                    onPostTap: {
                        PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                            crystalBlushShowsCreatePublishSheet = false
                            crystalBlushRouter?.push(.blushBloomPublishPost)
                        }
                    },
                    onChatRoomTap: {
                        PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                            crystalBlushShowsCreatePublishSheet = false
                            crystalBlushRouter?.push(.velvetAuraCreateEventChatRoom)
                        }
                    }
                )
            }
        }
    }

    private var crystalBlushTabBar: some View {
        HStack(spacing: 16) {
            ForEach(CrystalBlushTab.allCases, id: \.self) { crystalBlushTab in
                Button(action: {
                    if crystalBlushTab.crystalBlushAllowsGuestBrowsing {
                        crystalBlushSelectedTab = crystalBlushTab
                    } else {
                        PeachMistGuestAccessGuard.peachMistRequireMemberAccess(overlayCenter: roseMistOverlayCenter) {
                            crystalBlushSelectedTab = crystalBlushTab
                        }
                    }
                }) {
                    ZStack {
                        Capsule()
                            .fill(crystalBlushSelectedTab == crystalBlushTab ? AnyShapeStyle(GlowMuseTheme.velvetAuraAccentGradient) : AnyShapeStyle(Color.white.opacity(0.10)))
                            .frame(height: 48)

                        Image(crystalBlushTab.symbolName)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }

}

private enum CrystalBlushTab: String, CaseIterable {
    case home
    case community
    case message
    case profile

    var symbolName: String {
        switch self {
        case .home:
            return "VENNECNavHome"
        case .community:
            return "VENNECNavComunity"
        case .message:
            return "VENNECNavMessage"
        case .profile:
            return "VENNECNavMine"
        }
    }

    var crystalBlushAllowsGuestBrowsing: Bool {
        switch self {
        case .home, .community:
            return true
        case .message, .profile:
            return false
        }
    }
}

#Preview {
    CrystalBlushTabShellView()
}
