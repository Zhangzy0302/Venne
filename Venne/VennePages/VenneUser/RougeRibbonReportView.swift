import SwiftUI

struct RougeRibbonReportView: View {
    @Environment(\.crystalBlushRouter) private var rougeRibbonRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    let rougeRibbonTargetUserID: String

    @State private var rougeRibbonSelectedReasonID = 4
    @State private var rougeRibbonDescription = ""
    @State private var rougeRibbonIsSubmitting = false
    @State private var rougeRibbonKeyboardHeight: CGFloat = 0
    @FocusState private var rougeRibbonDescriptionFocused: Bool

    private let rougeRibbonReportReasons: [RougeRibbonReportReason] = [
        .init(id: 0, title: "Harassment"),
        .init(id: 1, title: "Malicious fraud"),
        .init(id: 2, title: "Pornography"),
        .init(id: 3, title: "Pornography"),
        .init(id: 4, title: "False Information")
    ]

    private let rougeRibbonCharacterLimit = 150

    init(rougeRibbonTargetUserID: String = "") {
        self.rougeRibbonTargetUserID = rougeRibbonTargetUserID
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            GlowMuseTheme.blushBloomPrimaryText
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    RougeRibbonGuideBackground()
                        .ignoresSafeArea()

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 12) {
                                Button {
                                    rougeRibbonRouter?.pop()
                                } label: {
                                    Image("VENNECNavBack")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 52, height: 52)
                                }
                                .buttonStyle(.plain)

                                Text("REPORT")
                                    .font(GlowMuseTheme.blushBloomSerifFont(size: 20, weight: .black))
                                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                            }
                            .padding(.top, 60)

                            Text("REPORT TYPE")
                                .font(GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .black))
                                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                                .padding(.top, 22)

                            rougeRibbonReasonGrid
                                .padding(.top, 18)

                            rougeRibbonDescriptionBlock
                                .padding(.top, 22)

                            Spacer(minLength: 140)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120 + rougeRibbonKeyboardHeight)
                    }
                }
                .clipShape(CrystalBlushUnevenRoundedRectangle(bottomLeadingRadius: 52))
                .ignoresSafeArea()

                VStack {
                    PetalLuxeButton(
                        title: rougeRibbonIsSubmitting ? "SUBMITTING" : "SUBMIT",
                        style: .primary,
                        height: 48
                    ) {
                        Task {
                            await rougeRibbonSubmitReport()
                        }
                    }
                    .disabled(rougeRibbonIsSubmitting)
                    .opacity(rougeRibbonIsSubmitting ? 0.6 : 1)
                        .padding(.horizontal, 18)
                        .padding(.top, 14)
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .background(GlowMuseTheme.blushBloomPrimaryText)
            }
        }
        .crystalBlushReadKeyboardHeight($rougeRibbonKeyboardHeight)
        .crystalBlushDismissKeyboardOnTap {
            rougeRibbonDescriptionFocused = false
        }
        .onChange(of: rougeRibbonDescription) { rougeRibbonNewValue in
            if rougeRibbonNewValue.count > rougeRibbonCharacterLimit {
                rougeRibbonDescription = String(rougeRibbonNewValue.prefix(rougeRibbonCharacterLimit))
            }
        }
    }

    private var rougeRibbonReasonGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            alignment: .leading,
            spacing: 12
        ) {
            ForEach(rougeRibbonReportReasons) { rougeRibbonReason in
                rougeRibbonReasonCard(
                    title: rougeRibbonReason.title,
                    isSelected: rougeRibbonSelectedReasonID == rougeRibbonReason.id
                ) {
                    rougeRibbonSelectedReasonID = rougeRibbonReason.id
                }
            }
        }
    }

    private var rougeRibbonDescriptionBlock: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(GlowMuseTheme.silkBloomSurfaceFill)
                .frame(height: 212)

            TextField("", text: $rougeRibbonDescription, prompt: Text("Supplementary description (optional)")
                .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                .foregroundColor(GlowMuseTheme.blushBloomSecondaryText.opacity(0.42)))
                .focused($rougeRibbonDescriptionFocused)
                .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText)
                .tint(GlowMuseTheme.velvetAuraCursorTint)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled()
                .padding(.horizontal, 10)
                .padding(.vertical, 10)

            Text("\(rougeRibbonDescription.count)/\(rougeRibbonCharacterLimit)")
                .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText.opacity(0.45))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 16)
                .padding(.bottom, 14)
                .allowsHitTesting(false)
        }
        .onTapGesture {
            rougeRibbonDescriptionFocused = true
        }
    }

    private func rougeRibbonReasonCard(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(GlowMuseTheme.silkBloomSurfaceFill)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .padding(1)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            isSelected
                            ? AnyShapeStyle(GlowMuseTheme.velvetAuraAccentGradient)
                            : AnyShapeStyle(Color.clear)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    @MainActor
    private func rougeRibbonSubmitReport() async {
        guard rougeRibbonIsSubmitting == false else {
            return
        }

        rougeRibbonDescriptionFocused = false
        rougeRibbonIsSubmitting = true
        roseMistOverlayCenter.showLoading()

        try? await Task.sleep(nanoseconds: 700_000_000)

        roseMistOverlayCenter.hideLoading()
        roseMistOverlayCenter.showToast("Report submitted.", style: .success)
        rougeRibbonIsSubmitting = false
        rougeRibbonRouter?.pop()
    }
}

private struct RougeRibbonReportReason: Identifiable {
    let id: Int
    let title: String
}

#Preview {
    RougeRibbonReportView()
}
