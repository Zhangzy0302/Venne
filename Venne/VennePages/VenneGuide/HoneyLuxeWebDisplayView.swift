import SwiftUI
import WebKit

struct HoneyLuxeWebDisplayView: View {
    let honeyLuxeWebAddress: String

    var body: some View {
        VStack(spacing: 0) {
            RougeRibbonTopBar()
                .background(GlowMuseTheme.silkBloomSurfaceFill.opacity(0.96))

            if let honeyLuxeURL = honeyLuxeResolvedURL {
                HoneyLuxeWebContainer(honeyLuxeURL: honeyLuxeURL)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                honeyLuxeInvalidAddressView
            }
        }
        .background(GlowMuseTheme.silkBloomSurfaceFill.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
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

    private var honeyLuxeResolvedURL: URL? {
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
}

private struct HoneyLuxeWebContainer: UIViewRepresentable {
    let honeyLuxeURL: URL

    func makeUIView(context: Context) -> WKWebView {
        let honeyLuxeConfiguration = WKWebViewConfiguration()
        let honeyLuxeWebView = WKWebView(frame: .zero, configuration: honeyLuxeConfiguration)
        honeyLuxeWebView.allowsBackForwardNavigationGestures = true
        honeyLuxeWebView.scrollView.contentInsetAdjustmentBehavior = .never
        honeyLuxeWebView.backgroundColor = .clear
        honeyLuxeWebView.isOpaque = false
        return honeyLuxeWebView
    }

    func updateUIView(_ honeyLuxeWebView: WKWebView, context: Context) {
        guard honeyLuxeWebView.url != honeyLuxeURL else {
            return
        }

        honeyLuxeWebView.load(URLRequest(url: honeyLuxeURL))
    }
}

#Preview {
    HoneyLuxeWebDisplayView(honeyLuxeWebAddress: "https://www.apple.com")
}
