import SwiftUI

struct VelvetAuraEditProfileView: View {
    @Environment(\.crystalBlushRouter) private var velvetAuraRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    @State private var velvetAuraCurrentUser: BlushBloomUserModel?
    @State private var velvetAuraName = ""
    @State private var velvetAuraAboutMe = ""
    @State private var velvetAuraGender = "Female"
    @State private var velvetAuraBirthday = Calendar.current.date(from: DateComponents(year: 2003, month: 1, day: 3)) ?? .now
    @State private var velvetAuraAvatarImagePath = ""
    @State private var velvetAuraShowsGenderPicker = false
    @State private var velvetAuraShowsBirthdayPicker = false
    @State private var velvetAuraKeyboardHeight: CGFloat = 0
    @FocusState private var velvetAuraFocusedField: VelvetAuraEditField?

    private let velvetAuraGenderOptions = ["Female", "Male", "Non-binary", "Prefer not to say"]

    var body: some View {
        ZStack {
            RougeRibbonGuideBackground()
            
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

                    Text("EDIT")
                        .font(GlowMuseTheme.blushBloomSerifFont(size: 20, weight: .black))
                        .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.bottom, 6)
                .padding(.horizontal, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        

                        velvetAuraAvatarSection
                            .frame(maxWidth: .infinity)
                            .padding(.top, 26)

                        velvetAuraTextFieldBlock(
                            title: "NAME",
                            placeholder: "Please enter",
                            text: $velvetAuraName,
                            field: .name
                        )
                        .padding(.top, 40)

                        velvetAuraSelectionBlock(
                            title: "GENDER",
                            value: velvetAuraGender
                        ) {
                            velvetAuraShowsGenderPicker = true
                        }
                        .padding(.top, 18)

                        velvetAuraSelectionBlock(
                            title: "BIRTHDAY",
                            value: velvetAuraBirthday.velvetAuraDisplayText
                        ) {
                            velvetAuraShowsBirthdayPicker = true
                        }
                        .padding(.top, 18)

                        velvetAuraAboutBlock
                            .padding(.top, 18)

                        PetalLuxeButton(title: "SAVE", style: .primary) {
                            velvetAuraSaveProfile()
                        }
                            .padding(.top, 70)
                            .padding(.bottom, 28)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, velvetAuraKeyboardHeight)
                }
            }
            
        }
        .crystalBlushReadKeyboardHeight($velvetAuraKeyboardHeight)
        .crystalBlushDismissKeyboardOnTap {
            velvetAuraFocusedField = nil
        }
        .onAppear {
            velvetAuraLoadProfile()
        }
        .sheet(isPresented: $velvetAuraShowsGenderPicker) {
            NavigationView {
                List(velvetAuraGenderOptions, id: \.self) { velvetAuraOption in
                    Button(action: {
                        velvetAuraGender = velvetAuraOption
                        velvetAuraShowsGenderPicker = false
                    }) {
                        HStack {
                            Text(velvetAuraOption)
                                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

                            Spacer()

                            if velvetAuraGender == velvetAuraOption {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .navigationTitle("Gender")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(isPresented: $velvetAuraShowsBirthdayPicker) {
            NavigationView {
                VStack {
                    DatePicker(
                        "",
                        selection: $velvetAuraBirthday,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
                .padding(.top, 20)
                .navigationTitle("Birthday")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button("Done") {
                        velvetAuraShowsBirthdayPicker = false
                    }
                )
            }
        }
    }

    private var velvetAuraAvatarSection: some View {
        CrystalBlushPhotoPickerButton(crystalBlushSelectionLimit: 1) { velvetAuraImageDataList in
            velvetAuraLoadAvatar(from: velvetAuraImageDataList.first)
        } crystalBlushLabel: {
            ZStack(alignment: .bottomTrailing) {
                CrystalBlushUniversalImage(
                    velvetAuraAvatarAddress,
                    contentMode: .fill,
                    fallbackSystemName: "person.crop.circle.fill"
                )
                .frame(width: 90, height: 90)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.92), lineWidth: 2))

                Circle()
                    .fill(GlowMuseTheme.blushBloomPrimaryText.opacity(0.86))
                    .frame(width: 26, height: 26)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                    .offset(x: 4, y: 3)
            }
        }
    }

    private func velvetAuraTextFieldBlock(
        title: String,
        placeholder: String,
        text: Binding<String>,
        field: VelvetAuraEditField
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(GlowMuseTheme.blushBloomSerifFont(size: 15, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

            TextField(placeholder, text: text)
                .focused($velvetAuraFocusedField, equals: field)
                .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText)
                .tint(GlowMuseTheme.velvetAuraCursorTint)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(GlowMuseTheme.moonPetalFieldFill)
                .clipShape(Capsule())
        }
    }

    private func velvetAuraSelectionBlock(
        title: String,
        value: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(GlowMuseTheme.blushBloomSerifFont(size: 15, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

            Button(action: action) {
                HStack {
                    Text(value)
                        .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                        .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                }
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(GlowMuseTheme.moonPetalFieldFill)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var velvetAuraAboutBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ABOUT ME")
                .font(GlowMuseTheme.blushBloomSerifFont(size: 15, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(GlowMuseTheme.moonPetalFieldFill)
                    .frame(height: 114)

                TextField("", text: $velvetAuraAboutMe, prompt: Text("Please enter")
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                    .foregroundColor(GlowMuseTheme.blushBloomSecondaryText.opacity(0.55)))
                    .focused($velvetAuraFocusedField, equals: .aboutMe)
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                    .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText)
                    .tint(GlowMuseTheme.velvetAuraCursorTint)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            }
            .onTapGesture {
                velvetAuraFocusedField = .aboutMe
            }
        }
    }

    private var velvetAuraAvatarAddress: String {
        let velvetAuraSelectedAvatar = velvetAuraAvatarImagePath.trimmingCharacters(in: .whitespacesAndNewlines)
        if velvetAuraSelectedAvatar.isEmpty == false {
            return velvetAuraSelectedAvatar
        }

        let velvetAuraAvatar = velvetAuraCurrentUser?.blushBloomAvatar.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return velvetAuraAvatar.isEmpty ? "VENNEDefaultAvatar" : velvetAuraAvatar
    }

    private func velvetAuraLoadProfile() {
        guard let velvetAuraCurrentUserID = SilkBloomLoginSessionStore.currentUserID else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        do {
            guard let velvetAuraLoadedUser = try RadiantDewLocalDataCenter.shared.radiantDewUsers.read(id: velvetAuraCurrentUserID) else {
                roseMistOverlayCenter.showToast("Profile data failed to load.", style: .error)
                return
            }

            velvetAuraCurrentUser = velvetAuraLoadedUser
            velvetAuraName = velvetAuraLoadedUser.blushBloomUserName
            velvetAuraAboutMe = velvetAuraLoadedUser.blushBloomAboutMe
            velvetAuraGender = velvetAuraLoadedUser.blushBloomGender
            velvetAuraBirthday = velvetAuraLoadedUser.blushBloomBirthdayDate
            velvetAuraAvatarImagePath = velvetAuraLoadedUser.blushBloomAvatar
        } catch {
            roseMistOverlayCenter.showToast("Profile data failed to load.", style: .error)
        }
    }

    private func velvetAuraSaveProfile() {
        guard var velvetAuraCurrentUser else {
            roseMistOverlayCenter.showToast("Please sign in first.", style: .normal)
            return
        }

        let velvetAuraFinalName = velvetAuraName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard velvetAuraFinalName.isEmpty == false else {
            roseMistOverlayCenter.showToast("Please enter your name.", style: .error)
            return
        }

        do {
            velvetAuraCurrentUser.blushBloomUserName = velvetAuraFinalName
            velvetAuraCurrentUser.blushBloomGender = velvetAuraGender
            velvetAuraCurrentUser.blushBloomBirthdayDate = velvetAuraBirthday
            velvetAuraCurrentUser.blushBloomAboutMe = velvetAuraAboutMe.trimmingCharacters(in: .whitespacesAndNewlines)
            velvetAuraCurrentUser.blushBloomAvatar = velvetAuraAvatarAddress

            try RadiantDewLocalDataCenter.shared.radiantDewUsers.update(velvetAuraCurrentUser)
            self.velvetAuraCurrentUser = velvetAuraCurrentUser
            roseMistOverlayCenter.showToast("Profile saved.", style: .success)
            velvetAuraRouter?.pop()
        } catch {
            roseMistOverlayCenter.showToast("Save failed. Please try again.", style: .error)
        }
    }

    private func velvetAuraLoadAvatar(from velvetAuraImageData: Data?) {
        guard let velvetAuraImageData else {
            return
        }

        do {
            velvetAuraAvatarImagePath = try RoseQuartzLocalMediaStore.roseQuartzSaveImageData(
                velvetAuraImageData,
                folder: "UserAvatars"
            )
        } catch {
            roseMistOverlayCenter.showToast("Avatar failed to load.", style: .error)
        }
    }
}

private enum VelvetAuraEditField {
    case name
    case aboutMe
}

private extension Date {
    var velvetAuraDisplayText: String {
        let velvetAuraFormatter = DateFormatter()
        velvetAuraFormatter.dateFormat = "yyyy-MM-dd"
        return velvetAuraFormatter.string(from: self)
    }
}

#Preview {
    VelvetAuraEditProfileView()
}
