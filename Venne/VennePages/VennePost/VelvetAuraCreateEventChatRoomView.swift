import SwiftUI

struct VelvetAuraCreateEventChatRoomView: View {
    @Environment(\.crystalBlushRouter) private var velvetAuraRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    @State private var velvetAuraRoomName = ""
    @State private var velvetAuraIntroduce = ""
    @State private var velvetAuraCoverImagePath = ""
    @State private var velvetAuraIsLoadingCover = false
    @FocusState private var velvetAuraFocusedField: VelvetAuraCreateChatField?

    var body: some View {
        ZStack(alignment: .bottom) {
            GlowMuseTheme.blushBloomPrimaryText
                .ignoresSafeArea()
            VStack{
                
                ZStack{
                    GeometryReader { _ in
                        Image("VENNEPostCreateBg")
                            .resizable()
                            .scaledToFill()
                    }
                    
                    VStack{
                        HStack(spacing: 12) {
                            Button {
                                velvetAuraRouter?.pop()
                            } label: {
                                Image("VENNECNavBack")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 52, height: 52)
                            }
                            .buttonStyle(.plain)

                            Text("CREATE")
                                .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .bold))
                                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 0) {
                                

                                velvetAuraCoverSection
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 52)

                                Text("ROOM NAME")
                                    .font(GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .bold))
                                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                                    .padding(.top, 56)

                                velvetAuraField(
                                    placeholder: "Please enter",
                                    text: $velvetAuraRoomName,
                                    field: .roomName
                                )
                                .padding(.top, 14)

                                Text("INTRODUCE")
                                    .font(GlowMuseTheme.blushBloomSerifFont(size: 16, weight: .bold))
                                    .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                                    .padding(.top, 20)

                                velvetAuraField(
                                    placeholder: "Please enter",
                                    text: $velvetAuraIntroduce,
                                    field: .introduce
                                )
                                .padding(.top, 14)

                                Spacer(minLength: 220)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 120)
                        }
                    }
                    
                    

                    
                }.clipShape(CrystalBlushUnevenRoundedRectangle(bottomLeadingRadius: 52))
                    .ignoresSafeArea()
                

                VStack {
                    PetalLuxeButton(title: "CREATE", style: .primary, height: 48) {
                        Task { await velvetAuraCreateRoom() }
                    }
                        .padding(.horizontal, 18)
                        .padding(.top, 14)
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .background(GlowMuseTheme.blushBloomPrimaryText)
            }
            
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                velvetAuraFocusedField = nil
            }
        )
    }

    private var velvetAuraCoverSection: some View {
        VStack(spacing: 14) {
            CrystalBlushPhotoPickerButton(crystalBlushSelectionLimit: 1) { velvetAuraImageDataList in
                velvetAuraLoadCover(from: velvetAuraImageDataList.first)
            } crystalBlushLabel: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white.opacity(0.44))
                        .frame(width: 114, height: 114)

                    if velvetAuraCoverImagePath.isEmpty == false {
                        CrystalBlushUniversalImage(
                            velvetAuraCoverImagePath,
                            contentMode: .fill,
                            fallbackSystemName: "photo.fill"
                        )
                        .frame(width: 114, height: 114)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    } else if velvetAuraIsLoadingCover {
                        ProgressView()
                            .tint(GlowMuseTheme.honeyGlowLinkText)
                    } else {
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .ultraLight))
                            .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
                    }
                }
            }

            Text("COVER  (\(velvetAuraCoverImagePath.isEmpty ? 0 : 1)/1)")
                .font(GlowMuseTheme.blushBloomSerifFont(size: 17, weight: .bold))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
        }
    }

    private func velvetAuraField(
        placeholder: String,
        text: Binding<String>,
        field: VelvetAuraCreateChatField
    ) -> some View {
        TextField(placeholder, text: text)
            .focused($velvetAuraFocusedField, equals: field)
            .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
            .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText)
            .tint(GlowMuseTheme.velvetAuraCursorTint)
            .textInputAutocapitalization(.sentences)
            .autocorrectionDisabled()
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(GlowMuseTheme.moonPetalFieldFill)
            .clipShape(Capsule())
    }

    @MainActor
    private func velvetAuraCreateRoom() async {
        let velvetAuraFinalName = velvetAuraRoomName.trimmingCharacters(in: .whitespacesAndNewlines)
        let velvetAuraFinalIntro = velvetAuraIntroduce.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let velvetAuraCurrentUserID = SilkBloomLoginSessionStore.currentUserID else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        guard velvetAuraFinalName.isEmpty == false else {
            roseMistOverlayCenter.showToast("Please enter room name.", style: .error)
            return
        }

        guard velvetAuraFinalIntro.isEmpty == false else {
            roseMistOverlayCenter.showToast("Please enter introduce.", style: .error)
            return
        }

        guard velvetAuraCoverImagePath.isEmpty == false else {
            roseMistOverlayCenter.showToast("Please upload a cover.", style: .error)
            return
        }

        do {
            roseMistOverlayCenter.showLoading()
            try await Task.sleep(nanoseconds: 600_000_000)

            let velvetAuraRoomID = "room_group_\(UUID().uuidString)"
            let velvetAuraRoom = MoonPetalChatRoomModel(
                moonPetalRoomID: velvetAuraRoomID,
                moonPetalUserIDs: [velvetAuraCurrentUserID],
                moonPetalLastMessageSentAt: Date(),
                moonPetalLastSenderID: "",
                moonPetalLastMessageText: "",
                moonPetalUnreadMessageCount: 0,
                moonPetalIsGroupChat: true,
                moonPetalGroupCoverImage: velvetAuraCoverImagePath,
                moonPetalGroupRoomName: velvetAuraFinalName,
                moonPetalGroupRoomIntro: velvetAuraFinalIntro
            )

            try RadiantDewLocalDataCenter.shared.radiantDewChatRooms.create(velvetAuraRoom)
            roseMistOverlayCenter.hideLoading()
            roseMistOverlayCenter.showToast("Room created.", style: .success)
            velvetAuraRouter?.push(.crystalBlushEventGroupChat(roomID: velvetAuraRoomID))
        } catch {
            roseMistOverlayCenter.hideLoading()
            roseMistOverlayCenter.showToast("Create failed. Please try again.", style: .error)
        }
    }

    private func velvetAuraLoadCover(from velvetAuraImageData: Data?) {
        guard let velvetAuraImageData else {
            velvetAuraCoverImagePath = ""
            return
        }

        do {
            velvetAuraIsLoadingCover = true

            velvetAuraCoverImagePath = try RoseQuartzLocalMediaStore.roseQuartzSaveImageData(
                velvetAuraImageData,
                folder: "ChatRoomCovers"
            )

            velvetAuraIsLoadingCover = false
        } catch {
            velvetAuraIsLoadingCover = false
            roseMistOverlayCenter.showToast("Cover failed to load.", style: .error)
        }
    }
}

private enum VelvetAuraCreateChatField: Hashable {
    case roomName
    case introduce
}

#Preview {
    VelvetAuraCreateEventChatRoomView()
        .environmentObject(RoseMistOverlayCenter())
}
