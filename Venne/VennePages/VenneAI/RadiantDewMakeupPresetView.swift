import SwiftUI

struct RadiantDewMakeupPresetView: View {
    @Environment(\.crystalBlushRouter) private var radiantDewRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    @SceneStorage("radiantDewPresetTab") private var radiantDewTabRawValue = RadiantDewPresetTab.makeupStyle.rawValue
    @SceneStorage("radiantDewSelectedStyleID") private var radiantDewSelectedStyleID: String?
    @SceneStorage("radiantDewSelectedVibeID") private var radiantDewSelectedVibeID: String?
    @SceneStorage("radiantDewSelectedStyleTag") private var radiantDewSelectedStyleTag: String?
    @State private var radiantDewShowsPaymentOverlay = false

    private let radiantDewStyleCards: [RadiantDewPresetCard] = [
        .init(title: "Glamour", image: "VENNEGlamour"),
        .init(title: "Natural", image: "VENNENatural")
    ]

    private let radiantDewVibeCards: [RadiantDewPresetCard] = [
        .init(title: "Photoshoot", image: "VENNEPhotoshoot"),
        .init(title: "Party Look", image: "VENNEPartyLook"),
        .init(title: "Coffee Date", image: "VENNECoffeeDate"),
        .init(title: "Daily Commute", image: "VENNEDailyCommute")
    ]

    private let radiantDewStyleTags = ["Rosy Pink", "Warm Sunset", "Cool Tones"]

    private var radiantDewTab: RadiantDewPresetTab {
        get {
            RadiantDewPresetTab(rawValue: radiantDewTabRawValue) ?? .makeupStyle
        }
        nonmutating set {
            radiantDewTabRawValue = newValue.rawValue
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            GlowMuseTheme.blushBloomPrimaryText
                .ignoresSafeArea()

            VStack {
                ZStack(alignment: .top) {
                    GeometryReader { _ in
                        Image("VENNEMainBg")
                            .resizable()
                            .scaledToFill()
                    }

                    radiantDewDecorativeRings

                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Button {
                                radiantDewRouter?.pop()
                            } label: {
                                Image("VENNECNavBack")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 52, height: 52)
                            }
                            .buttonStyle(.plain)

                            Spacer()

                            Button {
                                radiantDewRouter?.push(.velvetAuraHistoricalWorks)
                            } label: {
                                Image("VENNEHistoryIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 52, height: 52)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)

                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("CREATE THE\nMAKEUP YOU WANT")
                                    .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .black))
                                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                                    .lineSpacing(4)
                                    .padding(.top, 22)

                                radiantDewTabSwitcher
                                    .padding(.top, 26)

                                Text(radiantDewTab.sectionTitle)
                                    .font(GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .black))
                                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                                    .padding(.top, 34)

                                if radiantDewTab == .makeupStyle {
                                    radiantDewStyleSection
                                } else {
                                    radiantDewVibeSection
                                }

                                Spacer(minLength: 40)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 120)
                        }
                    }
                }
                .clipShape(CrystalBlushUnevenRoundedRectangle(bottomLeadingRadius: 52))
                .ignoresSafeArea()

                ZStack(alignment: .topTrailing) {
                    VStack {
                        PetalLuxeButton(title: "GENERATE", style: .primary, height: 48) {
                            radiantDewHandleGenerateTap()
                        }
                            .padding(.horizontal, 18)
                            .padding(.top, 14)
                            .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(GlowMuseTheme.blushBloomPrimaryText)

                    radiantDewCoinBadge
                        .offset(x: -18, y: -22)
                }
            }

            if radiantDewShowsPaymentOverlay {
                Color.black.opacity(0.74)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(4)

                SilkGlowPaymentConfirmOverlay(
                    silkGlowPrice: 300,
                    silkGlowContinueAction: {
                        radiantDewConfirmPaymentAndGenerate()
                    },
                    silkGlowCloseAction: {
                        radiantDewShowsPaymentOverlay = false
                    }
                )
                .transition(.scale(scale: 0.96).combined(with: .opacity))
                .zIndex(5)
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.88), value: radiantDewShowsPaymentOverlay)
    }

    private var radiantDewDecorativeRings: some View {
        ZStack(alignment: .topTrailing) {

            HStack(spacing: 10) {
                Image(systemName: "sparkle")
                    .font(.system(size: 24))
                    .foregroundStyle(.white)

                Image(systemName: "sparkle")
                    .font(.system(size: 34))
                    .foregroundStyle(.white)
                    .padding(.top, 50)
            }
            .offset(x: 80, y: 84)
            .rotationEffect(.degrees(15))
        }
    }

    private var radiantDewTabSwitcher: some View {
        ZStack {
            Capsule()
                .stroke(Color(red: 0.71, green: 0.84, blue: 0.93), lineWidth: 2)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.92))
                )
                .frame(height: 42)

            HStack(spacing: 0) {
                Button(action: {
                    radiantDewTab = .makeupStyle
                }) {
                    Text("MAKEUP STYLE")
                        .font(GlowMuseTheme.blushBloomSerifFont(size: 15, weight: .bold))
                        .foregroundStyle(radiantDewTab == .makeupStyle ? .white : GlowMuseTheme.blushBloomPrimaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 42)
                        .padding(.leading, 10)
                        .background(
                            Group {
                                if radiantDewTab == .makeupStyle {
                                    Capsule()
                                        .fill(GlowMuseTheme.velvetAuraAccentGradient)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)

                Button(action: {
                    radiantDewTab = .vibeMatch
                }) {
                    Text("VIBE MATCH")
                        .font(GlowMuseTheme.blushBloomSerifFont(size: 15, weight: .bold))
                        .foregroundStyle(radiantDewTab == .vibeMatch ? .white : GlowMuseTheme.blushBloomPrimaryText)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .frame(height: 42)
                        .padding(.trailing, 20)
                        .background(
                            Group {
                                if radiantDewTab == .vibeMatch {
                                    CrystalBlushUnevenRoundedRectangle(bottomTrailingRadius: 99, topTrailingRadius: 99)
                                        .fill(GlowMuseTheme.velvetAuraAccentGradient)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }

            Image("VENNECircleDecoration")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
        }
    }

    private var radiantDewStyleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 18) {
                ForEach(radiantDewStyleCards) { card in
                    radiantDewPresetCard(
                        card,
                        isSelected: radiantDewSelectedStyleID == card.id,
                        size: CGSize(width: 112, height: 122)
                    ) {
                        radiantDewSelectedStyleID = card.id
                    }
                }
            }
            .padding(.top, 18)

            Text("COLOR PALETTE")
                .font(GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                .padding(.top, 26)

            radiantDewTagWrap
                .padding(.top, 18)
        }
    }

    private var radiantDewVibeSection: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 18)
            ],
            spacing: 18
        ) {
            ForEach(radiantDewVibeCards) { card in
                radiantDewPresetCard(
                    card,
                    isSelected: radiantDewSelectedVibeID == card.id,
                    size: CGSize(width: 126, height: 138)
                ) {
                    radiantDewSelectedVibeID = card.id
                }
            }
        }
        .padding(.top, 18)
    }

    private var radiantDewTagWrap: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ForEach(Array(radiantDewStyleTags.prefix(2)), id: \.self) { radiantDewTagTitle in
                    radiantDewTag(
                        radiantDewTagTitle,
                        isSelected: radiantDewSelectedStyleTag == radiantDewTagTitle
                    ) {
                        radiantDewSelectedStyleTag = radiantDewTagTitle
                    }
                }
            }

            if let radiantDewLastStyleTag = radiantDewStyleTags.last {
                radiantDewTag(
                    radiantDewLastStyleTag,
                    isSelected: radiantDewSelectedStyleTag == radiantDewLastStyleTag
                ) {
                    radiantDewSelectedStyleTag = radiantDewLastStyleTag
                }
            }
        }
    }

    private func radiantDewTag(
        _ title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(GlowMuseTheme.blushBloomBodyFont(size: 15))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText.opacity(0.85))
                .padding(.horizontal, 18)
                .frame(height: 34)
                .background(Color.white.opacity(0.8))
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? AnyShapeStyle(GlowMuseTheme.velvetAuraAccentGradient) : AnyShapeStyle(Color.clear),
                            lineWidth: 1.5
                        )
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func radiantDewPresetCard(
        _ card: RadiantDewPresetCard,
        isSelected: Bool,
        size: CGSize,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack(alignment: .bottomTrailing) {
                    Image(card.image)
                        .resizable()
                        .frame(width: size.width, height: size.height)
                        

                    Capsule()
                        .fill(Color.white.opacity(0.82))
                        .frame(width: 48, height: 28)
                        .overlay(
                            Group {
                                if isSelected {
                                    Image("VENNECheck")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }
                            }
                        )
                        .padding(4)
                }

                Text(card.title)
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 15))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
            }
        }
        .buttonStyle(.plain)
    }

    private var radiantDewCoinBadge: some View {
        Capsule()
            .fill(Color.white)
            .frame(width: 92, height: 36)
            .overlay(
                HStack(spacing: 8) {
                    Image("VENNEDiamond")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)

                    Text("300")
                        .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                        .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                }
                .padding(.horizontal, 12)
            )
    }

    private func radiantDewHandleGenerateTap() {
        switch radiantDewTab {
        case .makeupStyle:
            guard radiantDewSelectedStyleID != nil else {
                roseMistOverlayCenter.showToast("Please choose a makeup style.", style: .normal)
                return
            }

            guard radiantDewSelectedStyleTag != nil else {
                roseMistOverlayCenter.showToast("Please choose a color palette.", style: .normal)
                return
            }

            radiantDewTab = .vibeMatch
            return

        case .vibeMatch:
            guard radiantDewSelectedVibeID != nil else {
                roseMistOverlayCenter.showToast("Please choose a vibe match.", style: .normal)
                return
            }
        }

        guard let radiantDewCurrentUserID = SilkBloomLoginSessionStore.currentUserID else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        do {
            guard let radiantDewCurrentUser = try RadiantDewLocalDataCenter.shared.radiantDewUsers.read(id: radiantDewCurrentUserID) else {
                roseMistOverlayCenter.showToast("User data failed to load.", style: .error)
                return
            }

            if radiantDewCurrentUser.blushBloomCoinCount < 300 {
                radiantDewRouter?.push(.silkBloomRecharge)
            } else {
                radiantDewShowsPaymentOverlay = true
            }
        } catch {
            roseMistOverlayCenter.showToast("User data failed to load.", style: .error)
        }
    }

    private func radiantDewConfirmPaymentAndGenerate() {
        guard let radiantDewCurrentUserID = SilkBloomLoginSessionStore.currentUserID else {
            radiantDewShowsPaymentOverlay = false
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        do {
            guard var radiantDewCurrentUser = try RadiantDewLocalDataCenter.shared.radiantDewUsers.read(id: radiantDewCurrentUserID) else {
                radiantDewShowsPaymentOverlay = false
                roseMistOverlayCenter.showToast("User data failed to load.", style: .error)
                return
            }

            guard radiantDewCurrentUser.blushBloomCoinCount >= 300 else {
                radiantDewShowsPaymentOverlay = false
                radiantDewRouter?.push(.silkBloomRecharge)
                return
            }

            radiantDewCurrentUser.blushBloomCoinCount -= 300
            try RadiantDewLocalDataCenter.shared.radiantDewUsers.update(radiantDewCurrentUser)
            _ = MoonVelvetPersistentGlobals.moonVelvetGenerateUniqueAIImageName()

            radiantDewShowsPaymentOverlay = false
            radiantDewRouter?.push(.blushBloomGenerateResults)
        } catch {
            radiantDewShowsPaymentOverlay = false
            roseMistOverlayCenter.showToast("Generation failed. Please try again.", style: .error)
        }
    }
}

private enum RadiantDewPresetTab: String {
    case makeupStyle
    case vibeMatch

    var sectionTitle: String {
        switch self {
        case .makeupStyle:
            return "MAKEUP STYLE"
        case .vibeMatch:
            return "VIBE MATCH"
        }
    }
}

private struct RadiantDewPresetCard: Identifiable {
    let title: String
    let image: String

    var id: String {
        title
    }
}

private struct SilkGlowPaymentConfirmOverlay: View {
    let silkGlowPrice: Int
    let silkGlowContinueAction: () -> Void
    let silkGlowCloseAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                silkGlowPaymentCard
                    .padding(.top, 34)

                silkGlowDiamondStack
            }

            Button(action: silkGlowCloseAction) {
                Circle()
                    .fill(Color.white.opacity(0.28))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .light))
                            .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 22)
        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var silkGlowPaymentCard: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 102)

            Text("WHETHER TO CONTINUE")
                .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                .multilineTextAlignment(.center)

            Text("Using the makeup generation\nfunction costs \(silkGlowPrice) diamonds")
                .font(GlowMuseTheme.blushBloomBodyFont(size: 15))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText.opacity(0.88))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.top, 18)

            PetalLuxeButton(title: "CONTINUE", style: .primary, height: 46) {
                silkGlowContinueAction()
            }
            .frame(width: 184)
            .padding(.top, 30)
            .padding(.bottom, 34)
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.77, blue: 0.87),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 38, style: .continuous))
    }

    private var silkGlowDiamondStack: some View {
        ZStack(alignment: .top) {
            ZStack{
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors: [
                        .white,
                        .white.opacity(0)
                    ], startPoint: .top, endPoint: .bottom))
                    .frame(width: 126, height: 110)
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white, lineWidth: 1)
                    .frame(width: 126, height: 110)
                    .offset(x: 11, y: 11)
            }.rotationEffect(.degrees(18))
            

            Image("VENNEDiamond")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .offset(y: 42)

            Capsule()
                .fill(Color.white)
                .frame(width: 92, height: 54)
                .overlay(
                    Text("\(silkGlowPrice)")
                        .font(GlowMuseTheme.blushBloomBodyFont(size: 18))
                        .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                )
                .offset(y: -2)
        }
        .frame(height: 126)
    }
}
