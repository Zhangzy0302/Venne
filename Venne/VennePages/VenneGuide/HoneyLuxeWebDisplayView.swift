import Combine
import ScreenShield
import SwiftUI
import UIKit
import WebKit

struct HoneyLuxeWebDisplayView: View {
    @Environment(\.crystalBlushRouter) private var honeyLuxeRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter
    @StateObject private var honeyLuxeWebModel: HoneyLuxeWebDisplayModel

    let honeyLuxeWebAddress: String

    init(honeyLuxeWebAddress: String) {
        self.honeyLuxeWebAddress = honeyLuxeWebAddress
        _honeyLuxeWebModel = StateObject(
            wrappedValue: HoneyLuxeWebDisplayModel(honeyLuxeWebAddress: honeyLuxeWebAddress)
        )
    }

    var body: some View {
        ZStack {
            GlowMuseTheme.blushBloomPrimaryText
                .ignoresSafeArea()

            if honeyLuxeWebModel.honeyLuxeIsBPackageWeb,
               honeyLuxeWebModel.honeyLuxeIsLoading {
                honeyLuxeLaunchBackdrop
            }

            honeyLuxePageLayer
                .ignoresSafeArea()

            if honeyLuxeWebModel.honeyLuxeIsBPackageWeb == false {
                VStack(spacing: 0) {
                    RougeRibbonTopBar()
                        .background(GlowMuseTheme.silkBloomSurfaceFill.opacity(0.96))

                    Spacer(minLength: 0)
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(20)
            }

            if honeyLuxeWebModel.honeyLuxeIsLoading {
                HoneyLuxeWebLoadingLayer()
            }

            if let honeyLuxeErrorText = honeyLuxeWebModel.honeyLuxeLoadErrorText {
                HoneyLuxeWebErrorLayer(
                    honeyLuxeErrorText: honeyLuxeErrorText,
                    honeyLuxeRetryAction: honeyLuxeWebModel.honeyLuxeRetry
                )
            }

            if honeyLuxeWebModel.honeyLuxeIsScreenCaptured {
                HoneyLuxeWebScreenCaptureLayer()
            }
        }
        .protectScreenshot()
        .ignoresSafeArea()
        .background(GlowMuseTheme.silkBloomSurfaceFill.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            honeyLuxeWebModel.honeyLuxeSceneDidAppear()
        }
        .onDisappear {
            honeyLuxeWebModel.honeyLuxeSceneDidDisappear()
        }
    }

    @ViewBuilder
    private var honeyLuxePageLayer: some View {
        if let honeyLuxeURL = honeyLuxeWebModel.honeyLuxeResolvedURL {
            HoneyLuxeWebContainer(
                honeyLuxeURL: honeyLuxeURL,
                honeyLuxeBridge: honeyLuxeWebModel.honeyLuxeBridge,
                honeyLuxeCallbacks: HoneyLuxeWebCallbacks(
                    honeyLuxeLoadingStarted: honeyLuxeWebModel.honeyLuxeLoadingStarted,
                    honeyLuxeLoadingFinished: honeyLuxeWebModel.honeyLuxeLoadingFinished,
                    honeyLuxeLoadingFailed: honeyLuxeWebModel.honeyLuxeLoadingFailed,
                    honeyLuxeCloseRequested: {
                        honeyLuxeWebModel.honeyLuxeCloseRequested()
                        honeyLuxeRouter?.pop()
                    },
                    honeyLuxeRechargeRequested: honeyLuxeRechargeRequested,
                    honeyLuxeExternalOpenRequested: honeyLuxeWebModel.honeyLuxeOpenExternalURL
                )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(honeyLuxeWebModel.honeyLuxeIsBPackageWeb && honeyLuxeWebModel.honeyLuxeIsLoading ? 0 : 1)
        } else {
            honeyLuxeInvalidAddressView
        }
    }

    private var honeyLuxeInvalidAddressView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)

            Text("Invalid web address")
                .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

            Text(honeyLuxeWebAddress)
                .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                .foregroundStyle(GlowMuseTheme.blushBloomMutedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var honeyLuxeLaunchBackdrop: some View {
        ZStack {
            Image("VENNECGuideBg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    GlowMuseTheme.blushBloomPrimaryText.opacity(0.02),
                    GlowMuseTheme.blushBloomPrimaryText.opacity(0.28),
                    GlowMuseTheme.blushBloomPrimaryText.opacity(0.76)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    private func honeyLuxeRechargeRequested(orderCode honeyLuxeOrderCode: String, batchNo honeyLuxeBatchNo: String) {
        honeyLuxeWebModel.honeyLuxeRechargeRequested(
            orderCode: honeyLuxeOrderCode,
            batchNo: honeyLuxeBatchNo,
            overlayCenter: roseMistOverlayCenter
        )
    }
}

@MainActor
private final class HoneyLuxeWebDisplayModel: ObservableObject {
    let honeyLuxeWebAddress: String
    let honeyLuxeBridge = HoneyLuxeWebBridge()

    @Published var honeyLuxeIsLoading = true
    @Published var honeyLuxeLoadErrorText: String?
    @Published var honeyLuxeIsScreenCaptured = false

    private var honeyLuxeScreenCaptureObservation: NSKeyValueObservation?

    init(honeyLuxeWebAddress: String) {
        self.honeyLuxeWebAddress = honeyLuxeWebAddress
    }

    var honeyLuxeResolvedURL: URL? {
        let honeyLuxeTrimmedAddress = honeyLuxeWebAddress.trimmingCharacters(in: .whitespacesAndNewlines)

        guard honeyLuxeTrimmedAddress.isEmpty == false else {
            return nil
        }

        if let honeyLuxeURL = URL(string: honeyLuxeTrimmedAddress),
           honeyLuxeURL.scheme?.isEmpty == false {
            return honeyLuxeURL
        }

        return URL(string: "https://\(honeyLuxeTrimmedAddress)")
    }

    var honeyLuxeIsBPackageWeb: Bool {
        guard let honeyLuxeURL = honeyLuxeResolvedURL else {
            return false
        }

        let honeyLuxeURLString = honeyLuxeURL.absoluteString
        return honeyLuxeURLString.contains("openParams=") || honeyLuxeURLString.contains("appId=")
    }

    func honeyLuxeSceneDidAppear() {
        SilkBloomRechargeIAPManager.shared.silkBloomFetchProducts()
        honeyLuxeStartScreenCaptureProtection()
    }

    func honeyLuxeSceneDidDisappear() {
        honeyLuxeStopScreenCaptureProtection()
    }

    func honeyLuxeLoadingStarted() {
        honeyLuxeLoadErrorText = nil
        honeyLuxeIsLoading = true
    }

    func honeyLuxeLoadingFinished(_ honeyLuxeDuration: Int) {
        honeyLuxeRecordLoadingDuration(honeyLuxeDuration)

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: honeyLuxeIsBPackageWeb ? 250_000_000 : 120_000_000)
            honeyLuxeIsLoading = false
        }
    }

    func honeyLuxeLoadingFailed(_ honeyLuxeErrorText: String) {
        honeyLuxeIsLoading = false
        honeyLuxeLoadErrorText = honeyLuxeErrorText
    }

    func honeyLuxeRetry() {
        honeyLuxeLoadErrorText = nil
        honeyLuxeIsLoading = true
        honeyLuxeBridge.honeyLuxeReload()
    }

    func honeyLuxeCloseRequested() {
        VelvetPoutAppStorage.velvetPoutUserToken = ""
    }

    func honeyLuxeRechargeRequested(
        orderCode honeyLuxeOrderCode: String,
        batchNo honeyLuxeBatchNo: String,
        overlayCenter honeyLuxeOverlayCenter: RoseMistOverlayCenter
    ) {
        velvetPoutUsersOrderCode = honeyLuxeOrderCode
        honeyLuxeOverlayCenter.showLoading()

        SilkBloomRechargeIAPManager.shared.silkBloomRecharge(productKeyID: honeyLuxeBatchNo) { [weak self] honeyLuxeResult in
            Task { @MainActor in
                honeyLuxeOverlayCenter.hideLoading()
                self?.honeyLuxeHandleRechargeResult(honeyLuxeResult, batchNo: honeyLuxeBatchNo)
            }
        }
    }

    func honeyLuxeOpenExternalURL(_ honeyLuxeURLString: String) {
        guard let honeyLuxeURL = URL(string: honeyLuxeURLString) else {
            honeyLuxeNotifyOpenState(state: "failed", urlString: honeyLuxeURLString)
            return
        }

        UIApplication.shared.open(honeyLuxeURL, options: [:]) { [weak self] honeyLuxeSuccess in
            Task { @MainActor in
                self?.honeyLuxeNotifyOpenState(
                    state: honeyLuxeSuccess ? "success" : "failed",
                    urlString: honeyLuxeURL.absoluteString
                )
            }
        }
    }

    private func honeyLuxeHandleRechargeResult(
        _ honeyLuxeResult: SilkBloomRechargePurchaseResult,
        batchNo honeyLuxeBatchNo: String
    ) {
        switch honeyLuxeResult {
        case .success(let honeyLuxeCoins):
            honeyLuxeNotifyRechargeState(state: "success", coins: honeyLuxeCoins)

        case .cancelled:
            honeyLuxeNotifyRechargeState(state: "cancelled")

        case .pending:
            honeyLuxeNotifyRechargeState(state: "pending")

        case .failed(let honeyLuxeMessage):
            RoseMistOverlayCenter.shared.showToast(honeyLuxeMessage, style: .error)
            honeyLuxeNotifyRechargeState(state: "failed")
        }
    }

    private func honeyLuxeStartScreenCaptureProtection() {
        honeyLuxeIsScreenCaptured = UIScreen.main.isCaptured
        honeyLuxeScreenCaptureObservation = UIScreen.main.observe(
            \.isCaptured,
             options: [.new]
        ) { [weak self] _, honeyLuxeChange in
            let honeyLuxeCaptured = honeyLuxeChange.newValue ?? false
            guard let honeyLuxeSelf = self else {
                return
            }
            Task { @MainActor in
                honeyLuxeSelf.honeyLuxeIsScreenCaptured = honeyLuxeCaptured
            }
        }
    }

    private func honeyLuxeStopScreenCaptureProtection() {
        honeyLuxeScreenCaptureObservation?.invalidate()
        honeyLuxeScreenCaptureObservation = nil
        honeyLuxeIsScreenCaptured = false
    }

    private func honeyLuxeRecordLoadingDuration(_ honeyLuxeDuration: Int) {
        guard honeyLuxeIsBPackageWeb else {
            return
        }

        Task {
            try? await RougeSignalApiCall().rougeSignalLoadingTimeRecord(honeyLuxeDuration)
        }
    }

    private func honeyLuxeNotifyOpenState(state honeyLuxeState: String, urlString honeyLuxeURLString: String) {
        honeyLuxeBridge.honeyLuxeEvaluateJavaScript(
            honeyLuxeNativeOpenStateScript(state: honeyLuxeState, urlString: honeyLuxeURLString)
        )
    }

    private func honeyLuxeNotifyRechargeState(state honeyLuxeState: String, coins honeyLuxeCoins: Int = 0) {
        honeyLuxeBridge.honeyLuxeEvaluateJavaScript(
            honeyLuxeNativeRechargeStateScript(state: honeyLuxeState, coins: honeyLuxeCoins)
        )
    }
}

private struct HoneyLuxeWebLoadingLayer: View {
    var body: some View {
        VStack(spacing: 22) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(1.35)

            Text("Loading...")
                .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.28))
        .allowsHitTesting(true)
    }
}

private struct HoneyLuxeWebErrorLayer: View {
    let honeyLuxeErrorText: String
    let honeyLuxeRetryAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Load failed")
                .font(GlowMuseTheme.blushBloomSerifFont(size: 20, weight: .black))
                .foregroundStyle(.white)

            Text(honeyLuxeErrorText)
                .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                .foregroundStyle(.white.opacity(0.72))
                .multilineTextAlignment(.center)

            Button("Retry") {
                honeyLuxeRetryAction()
            }
            .buttonStyle(.plain)
            .font(GlowMuseTheme.blushBloomSerifFont(size: 17, weight: .black))
            .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
            .padding(.top, 4)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GlowMuseTheme.blushBloomPrimaryText.opacity(0.86))
        .allowsHitTesting(true)
    }
}

private struct HoneyLuxeWebScreenCaptureLayer: View {
    var body: some View {
        ZStack {
            GlowMuseTheme.blushBloomPrimaryText
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)

                Text("Screen recording not allowed")
                    .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .black))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(true)
        .zIndex(300)
    }
}

private final class HoneyLuxeWebBridge: ObservableObject {
    weak var honeyLuxeWebView: WKWebView?

    func honeyLuxeReload() {
        honeyLuxeWebView?.reload()
    }

    func honeyLuxeEvaluateJavaScript(_ honeyLuxeJavaScript: String) {
        DispatchQueue.main.async { [weak self] in
            self?.honeyLuxeWebView?.evaluateJavaScript(honeyLuxeJavaScript)
        }
    }
}

private struct HoneyLuxeWebCallbacks {
    let honeyLuxeLoadingStarted: () -> Void
    let honeyLuxeLoadingFinished: (Int) -> Void
    let honeyLuxeLoadingFailed: (String) -> Void
    let honeyLuxeCloseRequested: () -> Void
    let honeyLuxeRechargeRequested: (_ orderCode: String, _ batchNo: String) -> Void
    let honeyLuxeExternalOpenRequested: (String) -> Void
}

private struct HoneyLuxeWebContainer: UIViewRepresentable {
    let honeyLuxeURL: URL
    let honeyLuxeBridge: HoneyLuxeWebBridge
    let honeyLuxeCallbacks: HoneyLuxeWebCallbacks

    func makeUIView(context: Context) -> WKWebView {
        let honeyLuxeConfiguration = WKWebViewConfiguration()
        let honeyLuxeContentController = WKUserContentController()

        HoneyLuxeWebBridgeAction.allCases.forEach {
            honeyLuxeContentController.add(context.coordinator, name: $0.rawValue)
        }

        honeyLuxeConfiguration.userContentController = honeyLuxeContentController
        honeyLuxeConfiguration.mediaTypesRequiringUserActionForPlayback = []
        honeyLuxeConfiguration.allowsInlineMediaPlayback = true

        let honeyLuxeWebView = WKWebView(frame: .zero, configuration: honeyLuxeConfiguration)
        honeyLuxeApplySettings(to: honeyLuxeWebView, coordinator: context.coordinator)
        honeyLuxeBridge.honeyLuxeWebView = honeyLuxeWebView
        honeyLuxeWebView.load(URLRequest(url: honeyLuxeURL))
        return honeyLuxeWebView
    }

    func updateUIView(_ honeyLuxeWebView: WKWebView, context: Context) {
        context.coordinator.honeyLuxeContainer = self
    }

    static func dismantleUIView(_ honeyLuxeWebView: WKWebView, coordinator: Coordinator) {
        HoneyLuxeWebBridgeAction.allCases.forEach {
            honeyLuxeWebView.configuration.userContentController.removeScriptMessageHandler(forName: $0.rawValue)
        }
        honeyLuxeWebView.navigationDelegate = nil
        honeyLuxeWebView.uiDelegate = nil
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func honeyLuxeApplySettings(to honeyLuxeWebView: WKWebView, coordinator: Coordinator) {
        honeyLuxeWebView.navigationDelegate = coordinator
        honeyLuxeWebView.uiDelegate = coordinator
        honeyLuxeWebView.allowsBackForwardNavigationGestures = true
        honeyLuxeWebView.scrollView.contentInsetAdjustmentBehavior = .never
        honeyLuxeWebView.scrollView.contentInset = .zero
        honeyLuxeWebView.scrollView.scrollIndicatorInsets = .zero
        honeyLuxeWebView.backgroundColor = .clear
        honeyLuxeWebView.isOpaque = false
        honeyLuxeWebView.scrollView.backgroundColor = .clear
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
        var honeyLuxeContainer: HoneyLuxeWebContainer
        var honeyLuxeStartTime: Date?

        init(_ honeyLuxeContainer: HoneyLuxeWebContainer) {
            self.honeyLuxeContainer = honeyLuxeContainer
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            honeyLuxeStartTime = Date()
            honeyLuxeContainer.honeyLuxeCallbacks.honeyLuxeLoadingStarted()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            honeyLuxeContainer.honeyLuxeCallbacks.honeyLuxeLoadingFinished(honeyLuxeElapsedMilliseconds())
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            honeyLuxeContainer.honeyLuxeCallbacks.honeyLuxeLoadingFailed(error.localizedDescription)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            honeyLuxeContainer.honeyLuxeCallbacks.honeyLuxeLoadingFailed(error.localizedDescription)
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let honeyLuxeURL = navigationAction.request.url,
                  let honeyLuxeScheme = honeyLuxeURL.scheme?.lowercased() else {
                decisionHandler(.allow)
                return
            }

            guard HoneyLuxeWebNavigationPolicy.honeyLuxeShouldAllow(scheme: honeyLuxeScheme) == false else {
                decisionHandler(.allow)
                return
            }

            honeyLuxeOpenNonWebURL(honeyLuxeURL, webView: webView)
            decisionHandler(.cancel)
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            guard let honeyLuxeURL = navigationAction.request.url else {
                return nil
            }

            if HoneyLuxeWebNavigationPolicy.honeyLuxeShouldOpenExternally(url: honeyLuxeURL) {
                UIApplication.shared.open(honeyLuxeURL)
                return nil
            }

            webView.load(URLRequest(url: honeyLuxeURL))
            return nil
        }

        @available(iOS 15.0, *)
        func webView(
            _ webView: WKWebView,
            requestMediaCapturePermissionFor origin: WKSecurityOrigin,
            initiatedByFrame frame: WKFrameInfo,
            type: WKMediaCaptureType,
            decisionHandler: @escaping (WKPermissionDecision) -> Void
        ) {
            decisionHandler(.grant)
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let honeyLuxeAction = HoneyLuxeWebBridgeAction(rawValue: message.name) else {
                return
            }

            switch honeyLuxeAction {
            case .rechargePay:
                guard let honeyLuxeOrder = HoneyLuxeWebOrder(body: message.body) else { return }
                honeyLuxeContainer.honeyLuxeCallbacks.honeyLuxeRechargeRequested(
                    honeyLuxeOrder.honeyLuxeOrderCode,
                    honeyLuxeOrder.honeyLuxeBatchNo
                )

            case .close:
                honeyLuxeContainer.honeyLuxeCallbacks.honeyLuxeCloseRequested()

            case .openBrowser:
                guard let honeyLuxeURLString = HoneyLuxeWebExternalLink.urlString(from: message.body) else { return }
                honeyLuxeContainer.honeyLuxeCallbacks.honeyLuxeExternalOpenRequested(honeyLuxeURLString)
            }
        }

        private func honeyLuxeElapsedMilliseconds() -> Int {
            honeyLuxeStartTime.map {
                Int(Date().timeIntervalSince($0) * 1000)
            } ?? 0
        }

        private func honeyLuxeOpenNonWebURL(_ honeyLuxeURL: URL, webView: WKWebView) {
            UIApplication.shared.open(honeyLuxeURL, options: [:]) { honeyLuxeSuccess in
                let honeyLuxeScript = honeyLuxeNativeOpenStateScript(
                    state: honeyLuxeSuccess ? "success" : "failed",
                    urlString: honeyLuxeURL.absoluteString
                )
                DispatchQueue.main.async {
                    webView.evaluateJavaScript(honeyLuxeScript)
                }
            }
        }
    }
}

private enum HoneyLuxeWebBridgeAction: String, CaseIterable {
    case rechargePay
    case close = "Close"
    case openBrowser
}

private enum HoneyLuxeWebNavigationPolicy {
    static func honeyLuxeShouldAllow(scheme honeyLuxeScheme: String) -> Bool {
        ["http", "https", "file", "about"].contains(honeyLuxeScheme)
    }

    static func honeyLuxeShouldOpenExternally(url honeyLuxeURL: URL) -> Bool {
        let honeyLuxeURLString = honeyLuxeURL.absoluteString.lowercased()
        return honeyLuxeURL.scheme == "itms-apps"
            || honeyLuxeURL.scheme == "itms-services"
            || honeyLuxeURLString.contains("apps.apple.com")
    }
}

private struct HoneyLuxeWebOrder {
    let honeyLuxeOrderCode: String
    let honeyLuxeBatchNo: String

    init?(body honeyLuxeBody: Any) {
        guard let honeyLuxeDict = honeyLuxeBody as? [String: Any],
              let honeyLuxeOrderCode = honeyLuxeDict["orderCode"] as? String,
              let honeyLuxeBatchNo = honeyLuxeDict["batchNo"] as? String else {
            return nil
        }

        self.honeyLuxeOrderCode = honeyLuxeOrderCode
        self.honeyLuxeBatchNo = honeyLuxeBatchNo
    }
}

private enum HoneyLuxeWebExternalLink {
    static func urlString(from honeyLuxeBody: Any) -> String? {
        if let honeyLuxeDict = honeyLuxeBody as? [String: Any],
           let honeyLuxeURLString = honeyLuxeDict["url"] as? String {
            return honeyLuxeURLString
        }

        return honeyLuxeBody as? String
    }
}

private func honeyLuxeJavaScriptEscaped(_ honeyLuxeValue: String) -> String {
    honeyLuxeValue
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "'", with: "\\'")
        .replacingOccurrences(of: "\n", with: "\\n")
        .replacingOccurrences(of: "\r", with: "\\r")
}

private func honeyLuxeNativeOpenStateScript(state honeyLuxeState: String, urlString honeyLuxeURLString: String) -> String {
    """
    window.dispatchEvent(new CustomEvent('nativeOpenState', {
        detail: { state: '\(honeyLuxeJavaScriptEscaped(honeyLuxeState))', url: '\(honeyLuxeJavaScriptEscaped(honeyLuxeURLString))' }
    }));
    """
}

private func honeyLuxeNativeRechargeStateScript(state honeyLuxeState: String, coins honeyLuxeCoins: Int) -> String {
    """
    window.dispatchEvent(new CustomEvent('nativeRechargeState', {
        detail: { state: '\(honeyLuxeJavaScriptEscaped(honeyLuxeState))', coins: \(honeyLuxeCoins) }
    }));
    """
}
