
import SwiftUI

@main
struct VenneApp: App {
    
    @StateObject private var crystalBlushRouter = CrystalBlushAppRouter()
    @StateObject private var roseMistOverlayCenter = RoseMistOverlayCenter()
    @StateObject private var silkBloomIAPManager = SilkBloomRechargeIAPManager.shared

    init() {
        PetalLuxeLocalSeedData.initializeIfNeeded()
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some Scene {
        WindowGroup {
            CrystalBlushNavigationHost()
                .task {
                    silkBloomIAPManager.silkBloomFetchProducts()
                }
                .roseMistGlobalOverlay(roseMistOverlayCenter)
                .environmentObject(crystalBlushRouter)
                .environmentObject(roseMistOverlayCenter)
                .environmentObject(silkBloomIAPManager)
                .environment(\.crystalBlushRouter, crystalBlushRouter)
        }
    }
}
