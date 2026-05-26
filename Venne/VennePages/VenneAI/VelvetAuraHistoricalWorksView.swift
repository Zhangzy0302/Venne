import SwiftUI

struct VelvetAuraHistoricalWorksView: View {
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    @State private var velvetAuraWorks: [MoonPetalAIHistoricalWorkModel] = []

    var body: some View {
        HoneyGlowAISurface {
            VStack(spacing: 0) {
                HoneyGlowAITitleBar(title: "HISTORICAL WORKS") {
                    Color.clear
                        .frame(width: 52, height: 52)
                }

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        if velvetAuraWorks.isEmpty {
                            velvetAuraEmptyState
                        } else {
                            ForEach(velvetAuraWorks) { velvetAuraWork in
                                velvetAuraHistoryRow(velvetAuraWork)
                            }
                        }
                    }
                    .padding(.top, 22)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 44)
                }
            }
        }
        .onAppear {
            velvetAuraLoadHistoricalWorks()
        }
    }

    private var velvetAuraEmptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)

            Text("No saved AI works yet.")
                .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                .foregroundStyle(GlowMuseTheme.blushBloomMutedText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(GlowMuseTheme.silkBloomSurfaceFill.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func velvetAuraHistoryRow(_ velvetAuraWork: MoonPetalAIHistoricalWorkModel) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(velvetAuraWork.moonPetalSavedAt.velvetAuraHistoryDateText)
                .font(GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                .frame(width: 44, alignment: .leading)
                .padding(.top, 6)

            GeometryReader { geo in
                ZStack(alignment: .bottomTrailing) {
                    HoneyGlowAIArtworkCard(
                        imageName: velvetAuraWork.moonPetalImageName,
                        size: CGSize(width: geo.size.width, height: 168)
                    )

                    Button {
                        velvetAuraDeleteHistoricalWork(velvetAuraWork)
                    } label: {
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 42, height: 42)
                            .overlay(
                                Image(systemName: "trash")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 10)
                    .padding(.bottom, 10)
                }
            }
            
        }.frame(height: 192)
    }

    private func velvetAuraLoadHistoricalWorks() {
        guard let velvetAuraCurrentUserID = SilkBloomLoginSessionStore.currentUserID else {
            velvetAuraWorks = []
            return
        }

        do {
            velvetAuraWorks = try RadiantDewLocalDataCenter.shared.radiantDewAIHistoricalWorks
                .readAll()
                .filter { $0.moonPetalOwnerUserID == velvetAuraCurrentUserID }
                .sorted { $0.moonPetalSavedAt > $1.moonPetalSavedAt }
        } catch {
            roseMistOverlayCenter.showToast("Historical works failed to load.", style: .error)
        }
    }

    private func velvetAuraDeleteHistoricalWork(_ velvetAuraWork: MoonPetalAIHistoricalWorkModel) {
        do {
            try RadiantDewLocalDataCenter.shared.radiantDewAIHistoricalWorks.delete(id: velvetAuraWork.moonPetalWorkID)
            velvetAuraWorks.removeAll { $0.moonPetalWorkID == velvetAuraWork.moonPetalWorkID }
            roseMistOverlayCenter.showToast("Historical work deleted.", style: .success)
        } catch {
            roseMistOverlayCenter.showToast("Delete failed.", style: .error)
        }
    }
}

private extension Date {
    var velvetAuraHistoryDateText: String {
        let velvetAuraFormatter = DateFormatter()
        velvetAuraFormatter.dateFormat = "MM.dd"
        return velvetAuraFormatter.string(from: self)
    }
}

#Preview {
    VelvetAuraHistoricalWorksView()
}
