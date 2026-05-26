import SwiftUI

struct HoneyGlowRelationShellView<Content: View>: View {
    @Environment(\.crystalBlushRouter) private var honeyGlowRouter

    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        ZStack(alignment: .top) {
            RougeRibbonGuideBackground()

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 16) {
                    Button {
                        honeyGlowRouter?.pop()
                    } label: {
                        Image("VENNECNavBack")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 52)
                    }
                    .buttonStyle(.plain)

                    Text(title)
                        .font(GlowMuseTheme.blushBloomSerifFont(size: 20, weight: .black))
                        .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                }
                .padding(.top, 12)
                .padding(.horizontal, 18)

                content
                    .padding(.top, 26)
                    .padding(.horizontal, 18)

                Spacer()
            }
        }
    }
}

struct HoneyGlowRelationCard: View {
    let item: HoneyGlowRelationItem
    let actionTitle: String
    let actionSymbol: String
    let actionTextOffsetY: CGFloat
    var showsAction = true
    var openAction: () -> Void = {}
    var action: () -> Void = {}

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: openAction) {
                VStack(alignment: .leading) {
                    HStack {
                        CrystalBlushUniversalImage(
                            item.avatarAddress,
                            contentMode: .fill,
                            fallbackSystemName: "person.crop.circle.fill"
                        )
                        .frame(width: 26, height: 26)
                        .clipShape(Circle())
                        .padding(.top, 2)

                        Text(item.name)
                            .font(GlowMuseTheme.blushBloomSerifFont(size: 14, weight: .black))
                            .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

                        Spacer()
                    }

                    Text(item.subtitle)
                        .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                        .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText.opacity(0.88))
                        .lineLimit(2)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)


            if showsAction {
                Button(action: action) {
                    Capsule()
                        .fill(GlowMuseTheme.velvetAuraAccentGradient)
                        .frame(width: 58, height: 34)
                        .overlay(
                            Group {
                                if actionTitle.isEmpty {
                                    Image(systemName: actionSymbol)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.white)
                                } else {
                                    Text(actionTitle)
                                        .font(GlowMuseTheme.blushBloomBodyFont(size: 12))
                                        .foregroundStyle(.white)
                                        .offset(y: actionTextOffsetY)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
                .offset(x: 6, y: -6)
            }
        }
        
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.white.opacity(0.8)))
    }
}

struct HoneyGlowRelationListView: View {
    let items: [HoneyGlowRelationItem]
    let actionTitle: String
    let actionSymbol: String
    let actionTextOffsetY: CGFloat
    var emptyText = "No users yet."
    var actionVisible: (HoneyGlowRelationItem) -> Bool = { _ in true }
    var openAction: (HoneyGlowRelationItem) -> Void = { _ in }
    var action: (HoneyGlowRelationItem) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 14) {
            if items.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)

                    Text(emptyText)
                        .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                        .foregroundStyle(GlowMuseTheme.blushBloomMutedText)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.white.opacity(0.58)))
            } else {
                ForEach(items) { item in
                    HoneyGlowRelationCard(
                        item: item,
                        actionTitle: actionTitle,
                        actionSymbol: actionSymbol,
                        actionTextOffsetY: actionTextOffsetY,
                        showsAction: actionVisible(item),
                        openAction: {
                            openAction(item)
                        },
                        action: {
                            action(item)
                        }
                    )
                }
            }
        }
    }
}

struct HoneyGlowRelationItem: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let avatarAddress: String

    init(
        id: String = UUID().uuidString,
        name: String,
        subtitle: String,
        avatarAddress: String = "VENNEAppLogo"
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.avatarAddress = avatarAddress
    }
}
