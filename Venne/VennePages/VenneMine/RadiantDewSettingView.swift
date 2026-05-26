import SwiftUI

struct RadiantDewSettingView: View {
    @Environment(\.crystalBlushRouter) private var radiantDewRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    @State private var radiantDewShowsDeleteConfirm = false
    @State private var radiantDewShowsLogoutConfirm = false

    private let radiantDewSettingItems = [
        "Privacy Policy",
        "User Agreement",
        "Blacklist"
    ]

    var body: some View {
        ZStack(alignment: .top) {
            RougeRibbonGuideBackground()

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Button {
                        radiantDewRouter?.pop()
                    } label: {
                        Image("VENNECNavBack")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 52)
                    }
                    .buttonStyle(.plain)

                    Text("SETTING")
                        .font(GlowMuseTheme.blushBloomSerifFont(size: 20, weight: .black))
                        .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                }
                .padding(.top, 12)
                .padding(.horizontal, 18)

                VStack(spacing: 14) {
                    ForEach(radiantDewSettingItems, id: \.self) { radiantDewItemTitle in
                        radiantDewSettingRow(title: radiantDewItemTitle) {
                            radiantDewHandleSettingTap(radiantDewItemTitle)
                        }
                    }
                }
                .padding(.top, 34)
                .padding(.horizontal, 18)

                Spacer()

                VStack(spacing: 16) {
                    PetalLuxeButton(
                        title: "DELETE ACCOUNT",
                        
                        style: .primary,
                        height: 48
                    ) {
                        radiantDewShowsDeleteConfirm = true
                    }

                    PetalLuxeButton(
                        title: "LOG OUT",
                        style: .primary,
                        height: 48
                    ) {
                        radiantDewShowsLogoutConfirm = true
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 40)
            }
        }
        .confirmationDialog(
            "Delete this account?",
            isPresented: $radiantDewShowsDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) {
                Task {
                    await radiantDewDeleteCurrentAccount()
                }
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the current local user and return to the guide page.")
        }
        .confirmationDialog(
            "Log out?",
            isPresented: $radiantDewShowsLogoutConfirm,
            titleVisibility: .visible
        ) {
            Button("Log Out", role: .destructive) {
                radiantDewLogOut()
            }

            Button("Cancel", role: .cancel) {}
        }
    }

    private func radiantDewSettingRow(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

                Spacer()

                Image("VENNECSettingArrow")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
                    .frame(width: 18, height: 18)
            }
            .padding(.horizontal, 24)
            .frame(height: 65)
            .background(GlowMuseTheme.silkBloomSurfaceFill)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func radiantDewHandleSettingTap(_ radiantDewTitle: String) {
        switch radiantDewTitle {
        case "Privacy Policy":
            radiantDewRouter?.push(.honeyLuxeWebDisplay(webAddress: "https://app.cwmd4asu.link/privacy"))
        case "User Agreement":
            radiantDewRouter?.push(.honeyLuxeWebDisplay(webAddress: "https://app.cwmd4asu.link/users"))
        case "Blacklist":
            radiantDewRouter?.push(.moonPetalBlacklist)
        default:
            break
        }
    }

    private func radiantDewLogOut() {
        SilkBloomLoginSessionStore.clearLoggedInUserID()
        radiantDewRouter?.replaceRoot(with: .blushBloomVenneGuide)
    }

    private func radiantDewDeleteCurrentAccount() async {
        guard let radiantDewCurrentUserID = SilkBloomLoginSessionStore.currentUserID else {
            roseMistOverlayCenter.showToast("No user is currently logged in.", style: .error)
            return
        }

        do {
            try RadiantDewLocalDataCenter.shared.radiantDewUsers.delete(id: radiantDewCurrentUserID)
            roseMistOverlayCenter.showLoading()
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            roseMistOverlayCenter.hideLoading()
            SilkBloomLoginSessionStore.clearLoggedInUserID()
            radiantDewRouter?.replaceRoot(with: .blushBloomVenneGuide)
        } catch {
            roseMistOverlayCenter.hideLoading()
            roseMistOverlayCenter.showToast("Delete account failed.", style: .error)
        }
    }
}

#Preview {
    RadiantDewSettingView()
        .environmentObject(RoseMistOverlayCenter())
}
