import SwiftUI

struct MoonPetalProfileDetailsView: View {
    @Environment(\.crystalBlushRouter) private var moonPetalRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    let moonPetalInitialEmail: String
    let moonPetalPassword: String
    let moonPetalInitialUserName: String

    @State private var moonPetalEmail: String
    @State private var moonPetalBirthday = Calendar.current.date(from: DateComponents(year: 2003, month: 1, day: 1)) ?? .now
    @State private var moonPetalLocation = "LA"
    @State private var moonPetalGender = "Female"
    @State private var moonPetalAboutMe = ""
    @State private var moonPetalAvatarImagePath = "VENNEDefaultAvatar"
    @State private var moonPetalShowsBirthdayPicker = false
    @State private var moonPetalShowsLocationPicker = false
    @State private var moonPetalShowsGenderPicker = false
    @State private var moonPetalKeyboardHeight: CGFloat = 0
    @FocusState private var moonPetalFocusedField: MoonPetalProfileDetailsField?

    init(
        moonPetalInitialEmail: String = "",
        moonPetalPassword: String = "",
        moonPetalInitialUserName: String = ""
    ) {
        self.moonPetalInitialEmail = moonPetalInitialEmail
        self.moonPetalPassword = moonPetalPassword
        self.moonPetalInitialUserName = moonPetalInitialUserName
        _moonPetalEmail = State(initialValue: moonPetalInitialEmail)
    }

    private let moonPetalLocationOptions = [
        "LA",
        "New York",
        "San Francisco",
        "Chicago",
        "Seattle",
        "Miami"
    ]
    private let moonPetalGenderOptions = ["Female", "Male", "Non-binary", "Prefer not to say"]

    var body: some View {
        ZStack {
            RougeRibbonGuideBackground()

            VStack(alignment: .leading, spacing: 0) {
                RougeRibbonTopBar()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        moonPetalAvatarSection
                        .padding(.top, 30)
                        .frame(maxWidth: .infinity)

                        moonPetalTextFieldBlock(
                            title: "EMAIL:",
                            placeholder: "Please enter",
                            text: $moonPetalEmail
                        )
                        .padding(.top, 18)

                        moonPetalSelectionBlock(
                            title: "BIRTHDAY:",
                            value: moonPetalBirthday.blushBloomDisplayText
                        ) {
                            moonPetalShowsBirthdayPicker = true
                        }

                        moonPetalSelectionBlock(
                            title: "LOCATION",
                            value: moonPetalLocation
                        ) {
                            moonPetalShowsLocationPicker = true
                        }

                        moonPetalSelectionBlock(
                            title: "GENDER",
                            value: moonPetalGender
                        ) {
                            moonPetalShowsGenderPicker = true
                        }

                        moonPetalAboutBlock

                        PetalLuxeButton(title: "SAVE", style: .primary) {
                            Task { await moonPetalCreateRegisteredUser() }
                        }
                            .padding(.top, 52)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 28 + moonPetalKeyboardHeight)
                }
            }
        }
        .crystalBlushReadKeyboardHeight($moonPetalKeyboardHeight)
        .crystalBlushDismissKeyboardOnTap {
            moonPetalFocusedField = nil
        }
        .sheet(isPresented: $moonPetalShowsBirthdayPicker) {
            NavigationView {
                VStack {
                    DatePicker(
                        "",
                        selection: $moonPetalBirthday,
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
                        moonPetalShowsBirthdayPicker = false
                    }
                )
            }
        }
        .sheet(isPresented: $moonPetalShowsLocationPicker) {
            NavigationView {
                List(moonPetalLocationOptions, id: \.self) { moonPetalCityName in
                    Button(action: {
                        moonPetalLocation = moonPetalCityName
                        moonPetalShowsLocationPicker = false
                    }) {
                        HStack {
                            Text(moonPetalCityName)
                                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

                            Spacer()

                            if moonPetalLocation == moonPetalCityName {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .navigationTitle("Location")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(isPresented: $moonPetalShowsGenderPicker) {
            NavigationView {
                List(moonPetalGenderOptions, id: \.self) { moonPetalGenderName in
                    Button(action: {
                        moonPetalGender = moonPetalGenderName
                        moonPetalShowsGenderPicker = false
                    }) {
                        HStack {
                            Text(moonPetalGenderName)
                                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

                            Spacer()

                            if moonPetalGender == moonPetalGenderName {
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
    }

    private var moonPetalAvatarSection: some View {
        CrystalBlushPhotoPickerButton(crystalBlushSelectionLimit: 1) { moonPetalImageDataList in
            moonPetalLoadAvatar(from: moonPetalImageDataList.first)
        } crystalBlushLabel: {
            ZStack(alignment: .bottomTrailing) {
                CrystalBlushUniversalImage(
                    moonPetalAvatarImagePath,
                    contentMode: .fill,
                    fallbackSystemName: "person.crop.circle.fill"
                )
                .frame(width: 78, height: 78)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.92), lineWidth: 2)
                )

                Circle()
                    .fill(Color.black.opacity(0.82))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white)
                    )
                    .offset(x: 8, y: 2)
            }
        }
    }

    private func moonPetalTextFieldBlock(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(GlowMuseTheme.blushBloomSerifFont(size: 15, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

            TextField(placeholder, text: text)
                .focused($moonPetalFocusedField, equals: .email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText)
                .tint(GlowMuseTheme.velvetAuraCursorTint)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(GlowMuseTheme.moonPetalFieldFill)
                .clipShape(Capsule())
        }
    }

    private var moonPetalAboutBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ABOUT ME")
                .font(GlowMuseTheme.blushBloomSerifFont(size: 15, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(GlowMuseTheme.moonPetalFieldFill)
                    .frame(height: 114)

                TextField("", text: $moonPetalAboutMe, prompt: Text("Please enter")
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                    .foregroundColor(GlowMuseTheme.blushBloomSecondaryText.opacity(0.55)))
                    .focused($moonPetalFocusedField, equals: .aboutMe)
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
                    .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText)
                    .tint(GlowMuseTheme.velvetAuraCursorTint)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            }
            .onTapGesture {
                moonPetalFocusedField = .aboutMe
            }
        }
    }

    private func moonPetalSelectionBlock(
        title: String,
        value: String,
        action: @escaping () -> Void = {}
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(GlowMuseTheme.blushBloomSerifFont(size: 15, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

            Button(action: action) {
                HStack(spacing: 12) {
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

    @MainActor
    private func moonPetalCreateRegisteredUser() async {
        let moonPetalFinalEmail = moonPetalEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let moonPetalFinalName = moonPetalInitialUserName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard moonPetalFinalEmail.isEmpty == false, moonPetalPassword.isEmpty == false else {
            roseMistOverlayCenter.showToast("Missing email or password.", style: .error)
            return
        }

        do {
            let moonPetalEmailExists = try RadiantDewLocalDataCenter.shared.radiantDewUsers
                .readAll()
                .contains { $0.blushBloomEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == moonPetalFinalEmail }

            guard moonPetalEmailExists == false else {
                roseMistOverlayCenter.showToast("This email has already been registered.", style: .error)
                return
            }

            let moonPetalUserID = "user_\(UUID().uuidString)"
            let moonPetalNewUser = BlushBloomUserModel(
                blushBloomUserID: moonPetalUserID,
                blushBloomEmail: moonPetalFinalEmail,
                blushBloomPassword: moonPetalPassword,
                blushBloomAvatar: moonPetalAvatarImagePath,
                blushBloomUserName: moonPetalFinalName.isEmpty ? "Venne User" : moonPetalFinalName,
                blushBloomBirthdayDate: moonPetalBirthday,
                blushBloomLocation: moonPetalLocation,
                blushBloomGender: moonPetalGender,
                blushBloomFanIDs: [],
                blushBloomFollowingIDs: [],
                blushBloomBlockedIDs: [],
                blushBloomCoinCount: 0,
                blushBloomIsGuest: false,
                blushBloomLikedPostIDs: [],
                blushBloomAboutMe: moonPetalAboutMe.trimmingCharacters(in: .whitespacesAndNewlines)
            )

            try RadiantDewLocalDataCenter.shared.radiantDewUsers.create(moonPetalNewUser)
            SilkBloomLoginSessionStore.saveLoggedInUserID(moonPetalUserID)
            roseMistOverlayCenter.showToast("Registration successful.", style: .success)
            await moonPetalShowNavigationLoading()
            moonPetalRouter?.replaceRoot(with: .crystalBlushTabShell)
        } catch {
            roseMistOverlayCenter.showToast("Save failed. Please try again.", style: .error)
        }
    }

    private func moonPetalLoadAvatar(from moonPetalImageData: Data?) {
        guard let moonPetalImageData else {
            return
        }

        do {
            moonPetalAvatarImagePath = try RoseQuartzLocalMediaStore.roseQuartzSaveImageData(
                moonPetalImageData,
                folder: "UserAvatars"
            )
        } catch {
            roseMistOverlayCenter.showToast("Avatar failed to load.", style: .error)
        }
    }

    @MainActor
    private func moonPetalShowNavigationLoading() async {
        roseMistOverlayCenter.showLoading()
        try? await Task.sleep(nanoseconds: 800_000_000)
        roseMistOverlayCenter.hideLoading()
    }
}

private extension Date {
    var blushBloomDisplayText: String {
        let blushBloomFormatter = DateFormatter()
        blushBloomFormatter.dateFormat = "yyyy-MM-dd"
        return blushBloomFormatter.string(from: self)
    }
}

private enum MoonPetalProfileDetailsField: Hashable {
    case email
    case aboutMe
}

#Preview {
    MoonPetalProfileDetailsView()
}
