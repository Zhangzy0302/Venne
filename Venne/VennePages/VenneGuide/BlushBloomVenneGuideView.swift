import SwiftUI
import UIKit

struct BlushBloomVenneGuideView: View {
    @Environment(\.crystalBlushRouter) private var blushBloomRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter
    @StateObject private var blushBloomPearlGlamInitViewModel = PearlGlamInitViewModel()
    @ObservedObject private var blushBloomLocationManager = GlossPetalLocationManager.shared
    @State private var blushBloomDidStartPearlGlamInit = false
    @State private var blushBloomDidOpenInitialBWebRoute = false
    @State private var blushBloomIsPreparingQuickLogin = false

    var body: some View {
        ZStack {
            blushBloomBackgroundLayer

            switch blushBloomPearlGlamInitViewModel.pearlGlamStatus {
            case .pearlGlamLoading:
                blushBloomLoadingContent
            case .pearlGlamA:
                blushBloomAPackageContent
            case .pearlGlamB:
                blushBloomBPackageContent
            }

            if blushBloomLocationManager.glossPetalShowLocationDialog {
                blushBloomLocationPermissionDialog
                    .transition(.opacity)
            }
        }
        .ignoresSafeArea()
        .background(Color.white)
        .onAppear {
            blushBloomStartPearlGlamInitIfNeeded()
        }
    }

    private var blushBloomAPackageContent: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 332)

            blushBloomLogoTitle

            Spacer()

            PetalLuxeButton(title: "GET STARTED", style: .primary, height: 54) {
                blushBloomRouter?.push(.velvetAuraAuthPortal)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 166)
        }
    }

    private var blushBloomBPackageContent: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 332)

            blushBloomLogoTitle

            Spacer()

            PetalLuxeButton(
                title: blushBloomIsPreparingQuickLogin ? "LOGGING IN..." : "QUICK LOGIN",
                style: .primary,
                height: 54
            ) {
                blushBloomHandleQuickLogin()
            }
            .disabled(blushBloomIsPreparingQuickLogin)
            .padding(.horizontal, 24)
            .padding(.bottom, 166)
        }
    }

    private var blushBloomLoadingContent: some View {
        VStack(spacing: 22) {
            Spacer()

            Image("VENNEAppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 108, height: 108)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: Color.white.opacity(0.55), radius: 24, y: 10)

            ProgressView()
                .progressViewStyle(.circular)
                .tint(GlowMuseTheme.blushBloomPrimaryText)
                .scaleEffect(1.15)

            Text("Curating your glow")
                .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText.opacity(0.76))

            Spacer()
                .frame(height: 116)
        }
    }

    private var blushBloomLogoTitle: some View {
        VStack(spacing: 0) {
            Image("VENNEAppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 108, height: 108)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: Color.white.opacity(0.55), radius: 24, y: 10)

            Text("VENNE")
                .font(GlowMuseTheme.blushBloomSerifFont(size: 26, weight: .black))
                .tracking(0.8)
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                .padding(.top, 18)
        }
    }

    private var blushBloomLocationPermissionDialog: some View {
        ZStack {
            Color.black.opacity(0.42)
                .ignoresSafeArea()
                .onTapGesture {
                    blushBloomLocationManager.glossPetalShowLocationDialog = false
                }

            VStack(spacing: 18) {
                Text("Enable Location")
                    .font(GlowMuseTheme.blushBloomSerifFont(size: 22, weight: .black))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

                Text("Location helps us prepare a more personalized beauty experience.")
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 15))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText)
                    .lineSpacing(4)

                PetalLuxeButton(title: "OPEN SETTINGS", style: .primary, height: 50) {
                    blushBloomOpenLocationSettings()
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
            .frame(width: 300)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white.opacity(0.96))
            )
        }
    }

    private var blushBloomBackgroundLayer: some View {
        GeometryReader { glowMuseGeometry in
            ZStack(alignment: .top) {
                Image("VENNECGuideBg")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .clipped()
            }
        }
    }

    private func blushBloomStartPearlGlamInitIfNeeded() {
        guard blushBloomDidStartPearlGlamInit == false else { return }
        blushBloomDidStartPearlGlamInit = true

        Task { @MainActor in
            await blushBloomPearlGlamInitViewModel.pearlGlamInitFlow()
            blushBloomOpenInitialBWebRouteIfNeeded()
        }
    }

    private func blushBloomOpenInitialBWebRouteIfNeeded() {
        guard blushBloomDidOpenInitialBWebRoute == false,
              let blushBloomRoute = blushBloomPearlGlamInitViewModel.pearlGlamNextRoute else {
            return
        }

        blushBloomDidOpenInitialBWebRoute = true
        blushBloomOpenBWebRoute(blushBloomRoute, showsFailureToast: false)
    }

    private func blushBloomHandleQuickLogin() {
        guard blushBloomIsPreparingQuickLogin == false else { return }
        blushBloomIsPreparingQuickLogin = true
        roseMistOverlayCenter.showLoading()

        let blushBloomInitViewModel = blushBloomPearlGlamInitViewModel

        Task { @MainActor in
            let blushBloomRoute: PearlGlamBRoute?

            if let blushBloomNextRoute = blushBloomInitViewModel.pearlGlamNextRoute {
                blushBloomRoute = blushBloomNextRoute
            } else {
                blushBloomRoute = await PearlGlamInitUtils.shared.pearlGlamGoLogin()
            }

            roseMistOverlayCenter.hideLoading()
            blushBloomIsPreparingQuickLogin = false
            blushBloomOpenBWebRoute(blushBloomRoute, showsFailureToast: true)
        }
    }

    private func blushBloomOpenBWebRoute(_ blushBloomRoute: PearlGlamBRoute?, showsFailureToast: Bool) {
        guard case let .some(.pearlGlamAgreement(blushBloomURL)) = blushBloomRoute,
              blushBloomURL.isEmpty == false else {
            if showsFailureToast {
                roseMistOverlayCenter.showToast("Login failed. Please try again.", style: .error)
            }
            return
        }

        blushBloomRouter?.push(.honeyLuxeWebDisplay(webAddress: blushBloomURL))
    }

    private func blushBloomOpenLocationSettings() {
        blushBloomLocationManager.glossPetalShowLocationDialog = false

        guard let blushBloomSettingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(blushBloomSettingsURL) else {
            return
        }

        UIApplication.shared.open(blushBloomSettingsURL)
    }
}

#Preview {
    BlushBloomVenneGuideView()
        .environmentObject(RoseMistOverlayCenter())
}
