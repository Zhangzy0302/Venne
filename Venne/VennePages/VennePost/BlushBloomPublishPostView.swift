import SwiftUI

struct BlushBloomPublishPostView: View {
    @Environment(\.crystalBlushRouter) private var blushBloomRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    @State private var blushBloomCopywriter = ""
    @State private var blushBloomSelectedImagePaths: [String] = []
    @State private var blushBloomIsLoadingImages = false
    @State private var blushBloomKeyboardHeight: CGFloat = 0
    @FocusState private var blushBloomCopywriterFocused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            GlowMuseTheme.blushBloomPrimaryText
                .ignoresSafeArea()
            
            

            VStack {
                ZStack(alignment: .top) {
                    GeometryReader { _ in
                        Image("VENNEPostCreateBg")
                            .resizable()
                            .scaledToFill()
                    }
                    
                    HStack{
                        Spacer()
                        Image("VENNEPostLogo")
                            .resizable()
                            .frame(width: 146, height: 146)
                    }.padding(.top, 30)
                    
                        

                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 12) {
                            Button {
                                blushBloomRouter?.pop()
                            } label: {
                                Image("VENNECNavBack")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 52, height: 52)
                            }
                            .buttonStyle(.plain)

                            Text("PUBLISH")
                                .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .bold))
                                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)

                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("COPYWRITER")
                                    .font(GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .bold))
                                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                                    .padding(.top, 82)

                                blushBloomCopywriterEditor
                                    .padding(.top, 18)

                                Text("UPLOAD  (PIC)")
                                    .font(GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .bold))
                                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                                    .padding(.top, 24)

                                blushBloomUploadSection
                                    .padding(.top, 18)

                                Spacer(minLength: 220)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 120)
                        }
                    }
                }
                .clipShape(CrystalBlushUnevenRoundedRectangle(bottomLeadingRadius: 52))
                .ignoresSafeArea()

                VStack {
                    PetalLuxeButton(title: "RELEASE", style: .primary, height: 48) {
                        Task { await blushBloomReleasePost() }
                    }
                        .padding(.horizontal, 18)
                        .padding(.top, 14)
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .background(GlowMuseTheme.blushBloomPrimaryText)
            }
        }
        .crystalBlushReadKeyboardHeight($blushBloomKeyboardHeight)
        .crystalBlushDismissKeyboardOnTap {
            blushBloomCopywriterFocused = false
        }
    }

    private var blushBloomCopywriterEditor: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(GlowMuseTheme.moonPetalFieldFill)
                .frame(height: 114)

            TextField("", text: $blushBloomCopywriter, prompt: Text("Please enter")
                .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                .foregroundColor(GlowMuseTheme.blushBloomSecondaryText.opacity(0.55)))
                .focused($blushBloomCopywriterFocused)
                .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText)
                .tint(GlowMuseTheme.velvetAuraCursorTint)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled()
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                
        }.onTapGesture {
            blushBloomCopywriterFocused = true
        }
    }

    private var blushBloomUploadSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CrystalBlushPhotoPickerButton(crystalBlushSelectionLimit: 6) { blushBloomImageDataList in
                    blushBloomLoadSelectedImages(from: blushBloomImageDataList)
                } crystalBlushLabel: {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white.opacity(0.44))
                        .frame(width: 106, height: 106)
                        .overlay(
                            Group {
                                if blushBloomIsLoadingImages {
                                    ProgressView()
                                        .tint(GlowMuseTheme.honeyGlowLinkText)
                                } else {
                                    Image(systemName: "plus")
                                        .font(.system(size: 30, weight: .ultraLight))
                                        .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
                                }
                            }
                        )
                }

                ForEach(blushBloomSelectedImagePaths, id: \.self) { blushBloomImagePath in
                    CrystalBlushUniversalImage(
                        blushBloomImagePath,
                        contentMode: .fill,
                        fallbackSystemName: "photo.fill"
                    )
                    .frame(width: 106, height: 106)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }
        }
    }

    @MainActor
    private func blushBloomReleasePost() async {
        let blushBloomFinalCopy = blushBloomCopywriter.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let blushBloomCurrentUserID = SilkBloomLoginSessionStore.currentUserID else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        guard blushBloomFinalCopy.isEmpty == false else {
            roseMistOverlayCenter.showToast("Please enter copywriter.", style: .error)
            return
        }

        guard blushBloomSelectedImagePaths.isEmpty == false else {
            roseMistOverlayCenter.showToast("Please upload at least one picture.", style: .error)
            return
        }

        do {
            roseMistOverlayCenter.showLoading()
            try await Task.sleep(nanoseconds: 600_000_000)

            let blushBloomPost = VelvetAuraPostModel(
                velvetAuraPostID: "post_blush_\(UUID().uuidString)",
                velvetAuraPublisherID: blushBloomCurrentUserID,
                velvetAuraImageList: blushBloomSelectedImagePaths,
                velvetAuraCopywritingContent: blushBloomFinalCopy,
                velvetAuraLikeCount: 0
            )

            try RadiantDewLocalDataCenter.shared.radiantDewPosts.create(blushBloomPost)
            roseMistOverlayCenter.hideLoading()
            roseMistOverlayCenter.showToast("Post released.", style: .success)
            blushBloomRouter?.pop()
        } catch {
            roseMistOverlayCenter.hideLoading()
            roseMistOverlayCenter.showToast("Release failed. Please try again.", style: .error)
        }
    }

    private func blushBloomLoadSelectedImages(from blushBloomImageDataList: [Data]) {
        guard blushBloomImageDataList.isEmpty == false else {
            blushBloomSelectedImagePaths = []
            return
        }

        blushBloomIsLoadingImages = true
        var blushBloomNewImagePaths: [String] = []

        for blushBloomImageData in blushBloomImageDataList {
            do {
                let blushBloomImagePath = try RoseQuartzLocalMediaStore.roseQuartzSaveImageData(
                    blushBloomImageData,
                    folder: "Posts"
                )
                blushBloomNewImagePaths.append(blushBloomImagePath)
            } catch {
                roseMistOverlayCenter.showToast("Some pictures failed to load.", style: .error)
            }
        }

        blushBloomSelectedImagePaths = blushBloomNewImagePaths
        blushBloomIsLoadingImages = false
    }
}

#Preview {
    BlushBloomPublishPostView()
        .environmentObject(RoseMistOverlayCenter())
}
