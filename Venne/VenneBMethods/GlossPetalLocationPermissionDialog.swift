import SwiftUI
import UIKit

struct GlossPetalLocationPermissionDialog: View {
    let glossPetalOpenSettingsAction: () -> Void
    let glossPetalCancelAction: () -> Void

    init(
        glossPetalOpenSettingsAction: @escaping () -> Void = GlossPetalLocationPermissionDialog.glossPetalOpenAppSettings,
        glossPetalCancelAction: @escaping () -> Void
    ) {
        self.glossPetalOpenSettingsAction = glossPetalOpenSettingsAction
        self.glossPetalCancelAction = glossPetalCancelAction
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.76)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    glossPetalPermissionCard
                        .padding(.top, 80)

                    glossPetalMapStack
                }

                Button(action: glossPetalCancelAction) {
                    Circle()
                        .fill(Color.white.opacity(0.28))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "xmark")
                                .font(.system(size: 22, weight: .light))
                                .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 22)
            }
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .transition(.opacity)
    }

    private var glossPetalPermissionCard: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 58)

            Text("LOCATION PERMISSION")
                .font(GlowMuseTheme.blushBloomSerifFont(size: 19, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                .multilineTextAlignment(.center)

            Text("This app needs access to your location information to enhance your experience by customizing services based on your region. If you agree, your location data will be used exclusively for this purpose and not for any other activities")
                .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText.opacity(0.88))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 26)
                .padding(.top, 24)

            PetalLuxeButton(title: "Go to settings", style: .primary, height: 52) {
                glossPetalOpenSettingsAction()
            }
            .frame(width: 212)
            .padding(.top, 28)
            .padding(.bottom, 22)
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.77, blue: 0.87),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 38, style: .continuous))
    }

    private var glossPetalMapStack: some View {
        ZStack(alignment: .top) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white,
                                .white.opacity(0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 126, height: 110)

                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white, lineWidth: 1)
                    .frame(width: 126, height: 110)
                    .offset(x: 11, y: 11)
            }
            .rotationEffect(.degrees(18))

            Image("VENNE_location_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 116, height: 116)
                .offset(y: 2)
        }
        .frame(height: 124)
    }

    private static func glossPetalOpenAppSettings() {
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
}

#Preview {
    GlossPetalLocationPermissionDialog(
        glossPetalCancelAction: {}
    )
}
