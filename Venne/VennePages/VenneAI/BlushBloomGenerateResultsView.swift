import SwiftUI
import UIKit

struct BlushBloomGenerateResultsView: View {
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    @State private var blushBloomIsGenerating = true
    @State private var blushBloomGenerationTaskStarted = false
    @State private var blushBloomHasSavedCurrentGeneration = false

    var body: some View {
        ZStack(alignment: .bottom) {
            GlowMuseTheme.blushBloomPrimaryText
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HoneyGlowAISurface {
                    VStack(spacing: 0) {
                        HoneyGlowAITitleBar(title: "GENERATE RESULTS") {
                            Color.clear
                                .frame(width: 52, height: 52)
                        }

                        Spacer(minLength: 0)

                        ZStack {
                            if blushBloomIsGenerating {
                                BlushBloomAIGenerationWaitingView()
                                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                            } else {
                                HoneyGlowAIArtworkCard(
                                    imageName: MoonVelvetPersistentGlobals.moonVelvetLatestAIImageName,
                                    size: CGSize(width: 288, height: 379)
                                )
                                .transition(.opacity.combined(with: .scale(scale: 1.04)))
                            }
                        }
                        .animation(.easeInOut(duration: 0.42), value: blushBloomIsGenerating)
                        .padding(.bottom, 86)

                        Spacer(minLength: 0)
                    }
                }

                HStack(spacing: 14) {
                    BlushBloomResultActionButton(
                        title: "DOWNLOAD",
                        style: .secondary,
                        isEnabled: blushBloomIsGenerating == false,
                        action: blushBloomDownloadCurrentImage
                    )

                    BlushBloomResultActionButton(
                        title: blushBloomHasSavedCurrentGeneration ? "SAVED" : "SAVE",
                        style: .primary,
                        isEnabled: blushBloomIsGenerating == false && blushBloomHasSavedCurrentGeneration == false,
                        action: blushBloomSaveHistoricalWork
                    )
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 20)
                .background(GlowMuseTheme.blushBloomPrimaryText)
            }
        }
        .task {
            await blushBloomSimulateAIGeneration()
        }
    }

    private var blushBloomCurrentImageName: String {
        MoonVelvetPersistentGlobals.moonVelvetLatestAIImageName
    }

    @MainActor
    private func blushBloomSimulateAIGeneration() async {
        guard blushBloomGenerationTaskStarted == false else {
            return
        }

        blushBloomGenerationTaskStarted = true
        blushBloomIsGenerating = true

        let blushBloomDelay = UInt64(Double.random(in: 4.0...5.0) * 1_000_000_000)
        try? await Task.sleep(nanoseconds: blushBloomDelay)

        guard Task.isCancelled == false else {
            return
        }

        blushBloomIsGenerating = false
    }

    private func blushBloomSaveHistoricalWork() {
        guard blushBloomIsGenerating == false else {
            roseMistOverlayCenter.showToast("AI image is still generating.", style: .normal)
            return
        }

        guard blushBloomHasSavedCurrentGeneration == false else {
            roseMistOverlayCenter.showToast("This generation has already been saved.", style: .normal)
            return
        }

        guard let blushBloomCurrentUserID = SilkBloomLoginSessionStore.currentUserID else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        do {
            let blushBloomCurrentUser = try RadiantDewLocalDataCenter.shared.radiantDewUsers.read(id: blushBloomCurrentUserID)
            let blushBloomAuthorName = blushBloomCurrentUser?.blushBloomUserName.trimmingCharacters(in: .whitespacesAndNewlines)
            let blushBloomHistory = MoonPetalAIHistoricalWorkModel(
                moonPetalWorkID: "ai_work_\(UUID().uuidString)",
                moonPetalOwnerUserID: blushBloomCurrentUserID,
                moonPetalAuthorName: blushBloomAuthorName?.isEmpty == false ? blushBloomAuthorName! : "Venne User",
                moonPetalImageName: blushBloomCurrentImageName,
                moonPetalSavedAt: Date()
            )

            try RadiantDewLocalDataCenter.shared.radiantDewAIHistoricalWorks.create(blushBloomHistory)
            blushBloomHasSavedCurrentGeneration = true
            roseMistOverlayCenter.showToast("Saved to historical works.", style: .success)
        } catch {
            roseMistOverlayCenter.showToast("Save failed. Please try again.", style: .error)
        }
    }

    private func blushBloomDownloadCurrentImage() {
        guard blushBloomIsGenerating == false else {
            roseMistOverlayCenter.showToast("AI image is still generating.", style: .normal)
            return
        }

        guard let blushBloomImage = UIImage(named: blushBloomCurrentImageName) else {
            roseMistOverlayCenter.showToast("Image failed to load.", style: .error)
            return
        }

        UIImageWriteToSavedPhotosAlbum(blushBloomImage, nil, nil, nil)
        roseMistOverlayCenter.showToast("Saved to photo library.", style: .success)
    }
}

private struct BlushBloomAIGenerationWaitingView: View {
    @State private var blushBloomOrbitRotates = false
    @State private var blushBloomPulseScale = false

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(GlowMuseTheme.silkBloomSurfaceFill.opacity(0.78))
                    .frame(width: 168, height: 168)
                    .shadow(color: GlowMuseTheme.honeyGlowLinkText.opacity(0.16), radius: 24, x: 0, y: 12)

                Circle()
                    .stroke(
                        GlowMuseTheme.velvetAuraAccentGradient,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [28, 18])
                    )
                    .frame(width: 132, height: 132)
                    .rotationEffect(.degrees(blushBloomOrbitRotates ? 360 : 0))

                Circle()
                    .fill(GlowMuseTheme.velvetAuraAccentGradient)
                    .frame(width: 74, height: 74)
                    .scaleEffect(blushBloomPulseScale ? 1.08 : 0.92)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(.white)
                    )

                ForEach(0..<3, id: \.self) { blushBloomSparkIndex in
                    Image(systemName: "sparkle")
                        .font(.system(size: blushBloomSparkIndex == 0 ? 18 : 13, weight: .bold))
                        .foregroundStyle(GlowMuseTheme.honeyGlowLinkText.opacity(0.82))
                        .offset(blushBloomSparkOffset(for: blushBloomSparkIndex))
                        .opacity(blushBloomPulseScale ? 1 : 0.38)
                        .animation(
                            .easeInOut(duration: 0.9)
                                .repeatForever(autoreverses: true)
                                .delay(Double(blushBloomSparkIndex) * 0.18),
                            value: blushBloomPulseScale
                        )
                }
            }

            VStack(spacing: 8) {
                Text("AI IS CREATING")
                    .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .black))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

                Text("Blending your makeup inspiration...")
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                    .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText)
            }
        }
        .frame(width: 288, height: 379)
        .onAppear {
            withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                blushBloomOrbitRotates = true
            }

            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                blushBloomPulseScale = true
            }
        }
    }

    private func blushBloomSparkOffset(for blushBloomSparkIndex: Int) -> CGSize {
        switch blushBloomSparkIndex {
        case 0:
            return CGSize(width: 62, height: -58)
        case 1:
            return CGSize(width: -62, height: -36)
        default:
            return CGSize(width: 52, height: 52)
        }
    }
}

private struct BlushBloomResultActionButton: View {
    enum SilkBloomStyle {
        case primary
        case secondary
    }

    let title: String
    let style: SilkBloomStyle
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .bold))
                .foregroundStyle(titleColor)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(backgroundStyle)
                .clipShape(Capsule())
        }
        .disabled(isEnabled == false)
        .opacity(isEnabled ? 1 : 0.42)
        .buttonStyle(.plain)
    }

    private var titleColor: Color {
        switch style {
        case .primary:
            .white
        case .secondary:
            .white.opacity(0.92)
        }
    }

    @ViewBuilder
    private var backgroundStyle: some View {
        switch style {
        case .primary:
            GlowMuseTheme.velvetAuraAccentGradient
        case .secondary:
            Color.white.opacity(0.12)
        }
    }
}

#Preview {
    BlushBloomGenerateResultsView()
}
