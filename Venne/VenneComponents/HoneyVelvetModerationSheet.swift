import SwiftUI

struct HoneyVelvetModerationSheet: View {
    @Environment(\.crystalBlushRouter) private var honeyVelvetRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    let honeyVelvetTargetUserID: String
    var honeyVelvetOnClose: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.58)
                .ignoresSafeArea()
                .onTapGesture {
                    honeyVelvetOnClose()
                }

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("MORE ACTIONS")
                        .font(GlowMuseTheme.blushBloomSerifFont(size: 17, weight: .black))
                        .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

                    Spacer()

                    Button(action: honeyVelvetOnClose) {
                        Circle()
                            .fill(GlowMuseTheme.silkBloomSurfaceFill)
                            .frame(width: 52, height: 52)
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .light))
                                    .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
                            )
                    }
                    .buttonStyle(.plain)
                }

                VStack(spacing: 12) {
                    honeyVelvetActionRow(
                        title: "REPORT",
                        subtitle: "Tell us what feels unsafe.",
                        iconName: "exclamationmark.bubble.fill",
                        action: honeyVelvetReportTarget
                    )

                    honeyVelvetActionRow(
                        title: "BLACKLIST",
                        subtitle: "Hide this user and their content.",
                        iconName: "person.crop.circle.badge.xmark",
                        action: honeyVelvetBlockTarget
                    )
                }
                .padding(.top, 18)

                Color.clear
                    .frame(height: 18)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 18)
            .background(
                ZStack {
                    Color.white
                    RougeRibbonGuideBackground()
                        .opacity(0.55)
                }
            )
            .clipShape(
                CrystalBlushUnevenRoundedRectangle(
                    topLeadingRadius: 32,
                    topTrailingRadius: 32
                )
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private func honeyVelvetActionRow(
        title: String,
        subtitle: String,
        iconName: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Circle()
                    .fill(GlowMuseTheme.velvetAuraAccentGradient)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: iconName)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(GlowMuseTheme.blushBloomSerifFont(size: 15, weight: .black))
                        .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

                    Text(subtitle)
                        .font(GlowMuseTheme.blushBloomBodyFont(size: 13))
                        .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText.opacity(0.72))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
            }
            .padding(.horizontal, 16)
            .frame(height: 76)
            .background(GlowMuseTheme.silkBloomSurfaceFill.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func honeyVelvetReportTarget() {
        honeyVelvetOnClose()
        honeyVelvetRouter?.push(.rougeRibbonReport(targetUserID: honeyVelvetTargetUserID))
    }

    private func honeyVelvetBlockTarget() {
        guard let honeyVelvetCurrentUserID = SilkBloomLoginSessionStore.currentUserID else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            honeyVelvetOnClose()
            return
        }

        guard honeyVelvetCurrentUserID != honeyVelvetTargetUserID else {
            roseMistOverlayCenter.showToast("You cannot blacklist yourself.", style: .normal)
            honeyVelvetOnClose()
            return
        }

        do {
            guard var honeyVelvetCurrentUser = try RadiantDewLocalDataCenter.shared.radiantDewUsers.read(id: honeyVelvetCurrentUserID) else {
                roseMistOverlayCenter.showToast("User data failed to load.", style: .error)
                honeyVelvetOnClose()
                return
            }

            if honeyVelvetCurrentUser.blushBloomBlockedIDs.contains(honeyVelvetTargetUserID) {
                roseMistOverlayCenter.showToast("Already in blacklist.", style: .normal)
            } else {
                honeyVelvetCurrentUser.blushBloomBlockedIDs.append(honeyVelvetTargetUserID)
                honeyVelvetCurrentUser.blushBloomFollowingIDs.removeAll { $0 == honeyVelvetTargetUserID }
                honeyVelvetCurrentUser.blushBloomFanIDs.removeAll { $0 == honeyVelvetTargetUserID }
                try RadiantDewLocalDataCenter.shared.radiantDewUsers.update(honeyVelvetCurrentUser)
                roseMistOverlayCenter.showToast("Added to blacklist.", style: .success)
            }

            honeyVelvetOnClose()
            honeyVelvetRouter?.popToRoot()
        } catch {
            roseMistOverlayCenter.showToast("Blacklist failed. Please try again.", style: .error)
            honeyVelvetOnClose()
        }
    }
}

#Preview {
    HoneyVelvetModerationSheet(
        honeyVelvetTargetUserID: "user_demo",
        honeyVelvetOnClose: {}
    )
    .environmentObject(RoseMistOverlayCenter())
}
