import SwiftUI
import UIKit

enum CrystalBlushUniversalImageSource {
    case network(URL)
    case localFile(String)
    case asset(String)
}

struct CrystalBlushUniversalImage: View {
    let crystalBlushImageAddress: String
    var crystalBlushContentMode: ContentMode
    var crystalBlushFallbackSystemName: String

    init(
        _ crystalBlushImageAddress: String,
        contentMode crystalBlushContentMode: ContentMode = .fill,
        fallbackSystemName crystalBlushFallbackSystemName: String = "photo"
    ) {
        self.crystalBlushImageAddress = crystalBlushImageAddress
        self.crystalBlushContentMode = crystalBlushContentMode
        self.crystalBlushFallbackSystemName = crystalBlushFallbackSystemName
    }

    var body: some View {
        switch crystalBlushResolvedSource {
        case .network(let crystalBlushURL):
            AsyncImage(url: crystalBlushURL) { crystalBlushPhase in
                switch crystalBlushPhase {
                case .empty:
                    crystalBlushPlaceholderImage
                case .success(let crystalBlushImage):
                    crystalBlushImage
                        .resizable()
                        .aspectRatio(contentMode: crystalBlushContentMode)
                case .failure:
                    crystalBlushPlaceholderImage
                @unknown default:
                    crystalBlushPlaceholderImage
                }
            }

        case .localFile(let crystalBlushFilePath):
            if let crystalBlushUIImage = UIImage(contentsOfFile: crystalBlushFilePath) {
                Image(uiImage: crystalBlushUIImage)
                    .resizable()
                    .aspectRatio(contentMode: crystalBlushContentMode)
            } else {
                crystalBlushPlaceholderImage
            }

        case .asset(let crystalBlushAssetName):
            Image(crystalBlushAssetName)
                .resizable()
                .aspectRatio(contentMode: crystalBlushContentMode)
        }
    }

    private var crystalBlushResolvedSource: CrystalBlushUniversalImageSource {
        let crystalBlushTrimmedAddress = crystalBlushImageAddress.trimmingCharacters(in: .whitespacesAndNewlines)

        if let crystalBlushURL = URL(string: crystalBlushTrimmedAddress),
           let crystalBlushScheme = crystalBlushURL.scheme?.lowercased() {
            if crystalBlushScheme == "http" || crystalBlushScheme == "https" {
                return .network(crystalBlushURL)
            }

            if crystalBlushScheme == "file" {
                return .localFile(crystalBlushURL.path)
            }
        }

        if crystalBlushTrimmedAddress.hasPrefix("/") {
            return .localFile(crystalBlushTrimmedAddress)
        }

        if crystalBlushTrimmedAddress.hasPrefix("~/") {
            let crystalBlushHomePath = NSHomeDirectory()
            let crystalBlushRelativePath = String(crystalBlushTrimmedAddress.dropFirst(2))
            return .localFile((crystalBlushHomePath as NSString).appendingPathComponent(crystalBlushRelativePath))
        }

        return .asset(crystalBlushTrimmedAddress)
    }

    private var crystalBlushPlaceholderImage: some View {
        Image(systemName: crystalBlushFallbackSystemName)
            .resizable()
            .scaledToFit()
            .foregroundStyle(GlowMuseTheme.blushBloomMutedText.opacity(0.55))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GlowMuseTheme.silkBloomSurfaceFill.opacity(0.78))
    }
}

#Preview {
    VStack(spacing: 18) {
        CrystalBlushUniversalImage("VENNEAppLogo", contentMode: .fit)
            .frame(width: 96, height: 96)

        CrystalBlushUniversalImage("/tmp/not-found.png")
            .frame(width: 96, height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    .padding()
}
