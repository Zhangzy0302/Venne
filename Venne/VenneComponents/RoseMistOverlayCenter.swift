import SwiftUI
import Combine

enum RoseMistToastStyle: Equatable {
    case normal
    case error
    case success
}

struct RoseMistToastItem: Identifiable, Equatable {
    let id = UUID()
    let roseMistMessage: String
    let roseMistStyle: RoseMistToastStyle
}

@MainActor
final class RoseMistOverlayCenter: ObservableObject {
    static let shared = RoseMistOverlayCenter()

    @Published var roseMistToastItem: RoseMistToastItem?
    @Published var roseMistIsLoading = false
    @Published var roseMistShowsLoadingMask = true
    @Published var roseMistShowsGuestLoginPrompt = false
    @Published var roseMistShowsMutualFollowPrompt = false

    private var roseMistToastDismissTask: Task<Void, Never>?

    func showToast(_ roseMistMessage: String, style roseMistStyle: RoseMistToastStyle = .normal) {
        roseMistToastDismissTask?.cancel()

        let roseMistNewToast = RoseMistToastItem(
            roseMistMessage: roseMistMessage,
            roseMistStyle: roseMistStyle
        )
        roseMistToastItem = roseMistNewToast

        roseMistToastDismissTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            guard Task.isCancelled == false else { return }

            await MainActor.run {
                guard self?.roseMistToastItem?.id == roseMistNewToast.id else { return }
                self?.hideToast()
            }
        }
    }

    func hideToast() {
        roseMistToastDismissTask?.cancel()
        roseMistToastDismissTask = nil
        roseMistToastItem = nil
    }

    func showLoading(showsMask roseMistShowsMask: Bool = true) {
        roseMistShowsLoadingMask = roseMistShowsMask
        roseMistIsLoading = true
    }

    func hideLoading() {
        roseMistIsLoading = false
    }

    func showGuestLoginPrompt() {
        hideToast()
        roseMistShowsMutualFollowPrompt = false
        roseMistShowsGuestLoginPrompt = true
    }

    func hideGuestLoginPrompt() {
        roseMistShowsGuestLoginPrompt = false
    }

    func showMutualFollowPrompt() {
        hideToast()
        roseMistShowsGuestLoginPrompt = false
        roseMistShowsMutualFollowPrompt = true
    }

    func hideMutualFollowPrompt() {
        roseMistShowsMutualFollowPrompt = false
    }
}

struct RoseMistGlobalOverlayView: View {
    @Environment(\.crystalBlushRouter) private var roseMistRouter
    @ObservedObject var roseMistOverlayCenter: RoseMistOverlayCenter

    var body: some View {
        ZStack {
            if roseMistOverlayCenter.roseMistShowsGuestLoginPrompt {
                roseMistGuestLoginMask
                    .transition(.opacity)
                    .zIndex(4)

                roseMistGuestLoginCard
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
                    .zIndex(5)
            }

            if roseMistOverlayCenter.roseMistShowsMutualFollowPrompt {
                roseMistPromptMask
                    .transition(.opacity)
                    .zIndex(4)

                roseMistMutualFollowCard
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
                    .zIndex(5)
            }

            if roseMistOverlayCenter.roseMistIsLoading {
                roseMistLoadingBlocker
                    .transition(.opacity)
                    .zIndex(1)
            }

            if let roseMistToastItem = roseMistOverlayCenter.roseMistToastItem {
                roseMistToastDismissLayer
                    .zIndex(2)

                roseMistToastCard(roseMistToastItem)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(3)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: roseMistOverlayCenter.roseMistIsLoading)
        .animation(.spring(response: 0.32, dampingFraction: 0.86), value: roseMistOverlayCenter.roseMistToastItem)
        .animation(.spring(response: 0.32, dampingFraction: 0.88), value: roseMistOverlayCenter.roseMistShowsGuestLoginPrompt)
        .animation(.spring(response: 0.32, dampingFraction: 0.88), value: roseMistOverlayCenter.roseMistShowsMutualFollowPrompt)
    }

    private var roseMistLoadingBlocker: some View {
        ZStack {
            (roseMistOverlayCenter.roseMistShowsLoadingMask ? Color.black.opacity(0.24) : Color.clear)
                .ignoresSafeArea()
                .contentShape(Rectangle())

            VStack(spacing: 12) {
                ProgressView()
                    .tint(.white)

                Text("Loading...")
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 13))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 20)
            .background(Color.black.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }

    private var roseMistToastDismissLayer: some View {
        Color.clear
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture {
                roseMistOverlayCenter.hideToast()
            }
    }

    private func roseMistToastCard(_ roseMistToastItem: RoseMistToastItem) -> some View {
        VStack {
            HStack(spacing: 10) {
                Image(systemName: roseMistToastIconName(for: roseMistToastItem.roseMistStyle))
                    .font(.system(size: 15, weight: .bold))

                Text(roseMistToastItem.roseMistMessage)
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .foregroundStyle(roseMistToastForegroundColor(for: roseMistToastItem.roseMistStyle))
            .padding(.horizontal, 18)
            .padding(.vertical, 13)
            .background(roseMistToastBackground(for: roseMistToastItem.roseMistStyle))
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.14), radius: 18, y: 8)
            .padding(.top, 64)
            .padding(.horizontal, 22)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }

    private func roseMistToastIconName(for roseMistStyle: RoseMistToastStyle) -> String {
        switch roseMistStyle {
        case .normal:
            return "bell.fill"
        case .error:
            return "xmark.circle.fill"
        case .success:
            return "checkmark.circle.fill"
        }
    }

    private func roseMistToastForegroundColor(for roseMistStyle: RoseMistToastStyle) -> Color {
        switch roseMistStyle {
        case .normal:
            return GlowMuseTheme.blushBloomPrimaryText
        case .error:
            return .white
        case .success:
            return .white
        }
    }

    private func roseMistToastBackground(for roseMistStyle: RoseMistToastStyle) -> some ShapeStyle {
        switch roseMistStyle {
        case .normal:
            return AnyShapeStyle(GlowMuseTheme.silkBloomSurfaceFill)
        case .error:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.97, green: 0.35, blue: 0.49),
                        Color(red: 0.83, green: 0.22, blue: 0.48)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        case .success:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.55, green: 0.82, blue: 0.72),
                        Color(red: 0.45, green: 0.74, blue: 0.92)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }

    private var roseMistGuestLoginMask: some View {
        roseMistPromptMask
    }

    private var roseMistPromptMask: some View {
        Color.black.opacity(0.76)
            .ignoresSafeArea()
            .contentShape(Rectangle())
    }

    private var roseMistGuestLoginCard: some View {
        VStack(spacing: 0) {
            VStack(spacing: 18) {
                Text("PLEASE LOG IN")
                    .font(GlowMuseTheme.blushBloomSerifFont(size: 17, weight: .black))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                    .padding(.top, 30)

                Text("To ensure the normal operation\nof the function, please log in to\nyour account first.")
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)

                PetalLuxeButton(title: "LOG IN", style: .primary, height: 44) {
                    roseMistOverlayCenter.hideGuestLoginPrompt()
                    SilkBloomLoginSessionStore.clearLoggedInUserID()
                    roseMistRouter?.replaceRoot(with: .velvetAuraAuthPortal)
                }
                .frame(width: 170)
                .padding(.top, 10)
                .padding(.bottom, 18)
            }
            .frame(width: 278)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.80, blue: 0.90),
                        Color.white
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            Button {
                roseMistOverlayCenter.hideGuestLoginPrompt()
            } label: {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 54, height: 54)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .light))
                            .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 18)
        }
    }

    private var roseMistMutualFollowCard: some View {
        VStack(spacing: 0) {
            VStack(spacing: 18) {
                Text("FOLLOW EACH OTHER")
                    .font(GlowMuseTheme.blushBloomSerifFont(size: 17, weight: .black))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                    .padding(.top, 30)

                Text("Private chat is available only\nafter you and this user follow\neach other.")
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)

                PetalLuxeButton(title: "I KNOW", style: .primary, height: 44) {
                    roseMistOverlayCenter.hideMutualFollowPrompt()
                }
                .frame(width: 170)
                .padding(.top, 10)
                .padding(.bottom, 18)
            }
            .frame(width: 278)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.80, blue: 0.90),
                        Color.white
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            Button {
                roseMistOverlayCenter.hideMutualFollowPrompt()
            } label: {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 54, height: 54)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .light))
                            .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 18)
        }
    }
}

extension View {
    func roseMistGlobalOverlay(_ roseMistOverlayCenter: RoseMistOverlayCenter) -> some View {
        overlay {
            RoseMistGlobalOverlayView(roseMistOverlayCenter: roseMistOverlayCenter)
        }
    }
}

#Preview {
    let roseMistOverlayCenter = RoseMistOverlayCenter()
    roseMistOverlayCenter.showToast("Saved successfully", style: .success)

    return Color.pink.opacity(0.12)
        .ignoresSafeArea()
        .roseMistGlobalOverlay(roseMistOverlayCenter)
}
