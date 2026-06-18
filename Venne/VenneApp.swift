
import SwiftUI
import UIKit

@main
struct VenneApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var crystalBlushRouter = CrystalBlushAppRouter()
    @StateObject private var roseMistOverlayCenter = RoseMistOverlayCenter.shared
    @StateObject private var silkBloomIAPManager = SilkBloomRechargeIAPManager.shared
    @StateObject private var glossPetalLocationManager = GlossPetalLocationManager.shared
    @State private var glossPetalIsCheckingLocationSettings = false
    
    @UIApplicationDelegateAdaptor(MascaraMuseAppDelegate.self)
    var appDelegate

    init() {
        Task {
            await GlossPetalPhoneInfo.shared.glossPetalGetPhoneInfo()
            MascaraMuseAdjustManager.shared.mascaraMuseInitialize()
        }
        PetalLuxeLocalSeedData.initializeIfNeeded()
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                CrystalBlushNavigationHost()

                if glossPetalLocationManager.glossPetalShowLocationDialog {
                    GlossPetalLocationPermissionDialog(
                        glossPetalOpenSettingsAction: {
                            glossPetalOpenLocationSettings()
                        },
                        glossPetalCancelAction: {
                            glossPetalIsCheckingLocationSettings = false
                            glossPetalLocationManager.glossPetalShowLocationDialog = false
                        }
                    )
                }
            }
            .task {
                silkBloomIAPManager.silkBloomFetchProducts()
            }
            .roseMistGlobalOverlay(roseMistOverlayCenter)
            .environmentObject(crystalBlushRouter)
            .environmentObject(roseMistOverlayCenter)
            .environmentObject(silkBloomIAPManager)
            .environment(\.crystalBlushRouter, crystalBlushRouter)
            .onChange(of: scenePhase) { glossPetalNewPhase in
                glossPetalHandleScenePhaseChange(glossPetalNewPhase)
            }
        }
    }

    private func glossPetalOpenLocationSettings() {
        glossPetalIsCheckingLocationSettings = true

        guard let glossPetalSettingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        Task { @MainActor in
            guard UIApplication.shared.canOpenURL(glossPetalSettingsURL) else {
                return
            }

            await UIApplication.shared.open(glossPetalSettingsURL)
        }
    }

    private func glossPetalHandleScenePhaseChange(_ glossPetalNewPhase: ScenePhase) {
        guard glossPetalNewPhase == .active,
              glossPetalIsCheckingLocationSettings else {
            return
        }

        glossPetalLocationManager.glossPetalShowLocationDialog = false
        glossPetalIsCheckingLocationSettings = false
    }
}
