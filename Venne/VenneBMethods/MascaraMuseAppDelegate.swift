
import UIKit
import UserNotifications
import FBSDKCoreKit
import AdjustSdk

final class MascaraMuseAdjustManager: NSObject, AdjustDelegate {
    static let shared = MascaraMuseAdjustManager()

    private let mascaraMuseInstallToken = "2oox9a"
    private let mascaraMusePurchaseToken = "6ffd2f"
    private let mascaraMuseAppToken = "vn3y21jf8zr4"
    private var mascaraMuseDidInitialize = false

    private override init() {}

    func mascaraMuseInitialize() {
        guard !mascaraMuseDidInitialize else {
            return
        }

        guard let mascaraMuseAdjustConfig = ADJConfig(
            appToken: mascaraMuseAppToken,
            environment: ADJEnvironmentProduction
        ) else {
            return
        }

        mascaraMuseAdjustConfig.logLevel = ADJLogLevel.verbose
        mascaraMuseAdjustConfig.enableSendingInBackground()
        mascaraMuseAdjustConfig.delegate = self
        
        print("ta_distinct_id: \(VelvetPoutBInfoStore.shared.velvetPoutDeviceId)")

        Adjust.addGlobalCallbackParameter(
            VelvetPoutBInfoStore.shared.velvetPoutDeviceId,
            forKey: "ta_distinct_id"
        )

        Adjust.attribution { [weak self] mascaraMuseAttribution in
            self?.adjustAttributionChanged(mascaraMuseAttribution)
        }

        Adjust.initSdk(mascaraMuseAdjustConfig)
        mascaraMuseDidInitialize = true
    }

    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        let mascaraMuseInstallEvent = ADJEvent(eventToken: mascaraMuseInstallToken)
        Adjust.trackEvent(mascaraMuseInstallEvent)
    }

    func mascaraMuseTrackPurchase(dollar mascaraMuseDollar: Double) {
        mascaraMuseTrackAdjustPurchase(dollar: mascaraMuseDollar)
        mascaraMuseTrackFacebookPurchase(price: mascaraMuseDollar)
    }

    private func mascaraMuseTrackAdjustPurchase(dollar mascaraMuseDollar: Double) {
        let mascaraMusePurchaseEvent = ADJEvent(eventToken: mascaraMusePurchaseToken)
        mascaraMusePurchaseEvent?.setRevenue(mascaraMuseDollar, currency: "USD")
        Adjust.trackEvent(mascaraMusePurchaseEvent)
    }

    private func mascaraMuseTrackFacebookPurchase(price mascaraMusePrice: Double) {
        AppEvents.shared.logPurchase(
            amount: mascaraMusePrice,
            currency: "USD",
            parameters: [AppEvents.ParameterName(rawValue: "fb_mobile_purchase"): "true"]
        )
    }
}

class MascaraMuseAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        mascaraMuseRegisterPush(application)

        return true
    }

    private func mascaraMuseRegisterPush(_ application: UIApplication) {

        UNUserNotificationCenter.current().delegate = self

        application.registerForRemoteNotifications()

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in

            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {

        let mascaraMusePushToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        // 保存
        VelvetPoutAppStorage.velvetPoutPushToken = mascaraMusePushToken
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Push 注册失败:", error)
    }
}
