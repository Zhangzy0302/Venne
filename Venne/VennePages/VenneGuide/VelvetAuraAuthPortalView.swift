import SwiftUI

struct VelvetAuraAuthPortalView: View {
    @Environment(\.crystalBlushRouter) private var velvetAuraRouter
    @EnvironmentObject private var roseMistOverlayCenter: RoseMistOverlayCenter

    @State private var velvetAuraMode: VelvetAuraAuthMode = .signIn
    @State private var blushBloomEmail = ""
    @State private var blushBloomPassword = ""
    @State private var blushBloomFullName = ""
    @State private var blushBloomConfirmPassword = ""
    @State private var blushBloomAgreementAccepted = MoonVelvetPersistentGlobals.moonVelvetDidAgreeAgreement
    @State private var velvetAuraShowsEulaOverlay = false
    @FocusState private var glowMuseFocusedField: VelvetAuraFocusField?

    var body: some View {
        ZStack {
            RougeRibbonGuideBackground()

            VStack(alignment: .leading, spacing: 0) {
                RougeRibbonTopBar()

                velvetAuraModeSwitcher
                    .padding(.top, 18)
                    .padding(.horizontal, 24)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        if velvetAuraMode == .signIn {
                            velvetAuraSignInForm
                        } else {
                            velvetAuraSignUpForm
                        }
                        
                        HStack(alignment: .top, spacing: 10) {
                            Button(action: {
                                blushBloomAgreementAccepted.toggle()
                                MoonVelvetPersistentGlobals.moonVelvetDidAgreeAgreement = blushBloomAgreementAccepted
                            }) {
                                Circle()
                                    .fill(blushBloomAgreementAccepted ? GlowMuseTheme.crystalBlushSelectionFill : GlowMuseTheme.silkBloomSurfaceFill)
                                    .frame(width: 18, height: 18)
                                    .overlay(
                                        Circle()
                                            .stroke(GlowMuseTheme.crystalBlushRing, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 0) {
                                    Text("Agree with ")
                                        .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText)

                                    velvetAuraAgreementLink(
                                        title: "User Agreement",
                                        webAddress: "https://app.cwmd4asu.link/users"
                                    )

                                    Text(" and")
                                        .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText)
                                }

                                velvetAuraAgreementLink(
                                    title: "Privacy Policy",
                                    webAddress: "https://app.cwmd4asu.link/privacy"
                                )
                            }
                            .font(GlowMuseTheme.blushBloomBodyFont(size: 13))
                        }
                        .padding(.top, 18)
                    }
                    .padding(.top, 28)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }
            }

            if velvetAuraShowsEulaOverlay {
                CrystalBlushEulaOverlayView(
                    onClose: {
                        velvetAuraShowsEulaOverlay = false
                    },
                    onAgree: {
                        MoonVelvetPersistentGlobals.moonVelvetDidAgreeEULA = true
                        velvetAuraShowsEulaOverlay = false
                    }
                )
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                glowMuseFocusedField = nil
            }
        )
        .onAppear {
            blushBloomAgreementAccepted = MoonVelvetPersistentGlobals.moonVelvetDidAgreeAgreement
        }
    }

    private var velvetAuraModeSwitcher: some View {
        HStack(spacing: 14) {
            ForEach(VelvetAuraAuthMode.allCases, id: \.self) { glowMuseMode in
                PetalLuxeButton(
                    title: glowMuseMode.title,
                    style: .segmented(isSelected: velvetAuraMode == glowMuseMode),
                    height: 48
                ) {
                    velvetAuraMode = glowMuseMode
                }
            }
        }
    }

    private var velvetAuraSignInForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            glowMuseFieldBlock(
                title: "EMAIL:",
                placeholder: "Enter email address",
                text: $blushBloomEmail,
                focusedField: .signInEmail,
                keyboardType: .emailAddress
            )

            glowMuseFieldBlock(
                title: "PASSWORD:",
                placeholder: "Enter password",
                text: $blushBloomPassword,
                focusedField: .signInPassword,
                isSecure: true
            )

            HStack {
                Spacer()
                Button("FORGOT?") {
                    velvetAuraRouter?.push(.honeyGlowForgotPassword)
                }
                    .font(GlowMuseTheme.blushBloomBodyFont(size: 14))
                    .foregroundStyle(GlowMuseTheme.blushBloomMutedText)
            }
            .padding(.top, -2)

            PetalLuxeButton(title: "CONTINUE", style: .primary) {
                Task { await velvetAuraHandleSignIn() }
            }
            .padding(.top, 58)

            PetalLuxeButton(title: "CONTINUE WITH GUEST", style: .secondary) {
                Task { await velvetAuraHandleGuestSignIn() }
            }

            
        }
    }

    private var velvetAuraSignUpForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            glowMuseFieldBlock(
                title: "FULL NAME:",
                placeholder: "Please enter Full name",
                text: $blushBloomFullName,
                focusedField: .signUpFullName
            )

            glowMuseFieldBlock(
                title: "EMAIL ADDRESS:",
                placeholder: "Please enter email address",
                text: $blushBloomEmail,
                focusedField: .signUpEmail,
                keyboardType: .emailAddress
            )

            glowMuseFieldBlock(
                title: "PASSWORD:",
                placeholder: "Please enter the password",
                text: $blushBloomPassword,
                focusedField: .signUpPassword,
                isSecure: true
            )

            glowMuseFieldBlock(
                title: "PASSWORD:",
                placeholder: "Please enter the password again",
                text: $blushBloomConfirmPassword,
                focusedField: .signUpConfirmPassword,
                isSecure: true
            )

            PetalLuxeButton(title: "SIGN UP NOW", style: .primary) {
                Task { await velvetAuraHandleSignUp() }
            }
            .padding(.top, 58)
        }
    }

    private func velvetAuraAgreementLink(title: String, webAddress: String) -> some View {
        Button {
            velvetAuraRouter?.push(.honeyLuxeWebDisplay(webAddress: webAddress))
        } label: {
            Text(title)
                .foregroundStyle(GlowMuseTheme.honeyGlowLinkText)
        }
        .buttonStyle(.plain)
    }

    @MainActor
    private func velvetAuraHandleSignIn() async {
        guard velvetAuraCanContinueAuthFlow() else {
            return
        }

        let velvetAuraEmail = blushBloomEmail.velvetAuraNormalizedEmail
        let velvetAuraPassword = blushBloomPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard velvetAuraEmail.isEmpty == false, velvetAuraPassword.isEmpty == false else {
            roseMistOverlayCenter.showToast("Please enter email and password.", style: .error)
            return
        }

        do {
            let velvetAuraUser = try RadiantDewLocalDataCenter.shared.radiantDewUsers
                .readAll()
                .first {
                    $0.blushBloomEmail.velvetAuraNormalizedEmail == velvetAuraEmail
                        && $0.blushBloomPassword == velvetAuraPassword
                }

            guard let velvetAuraUser else {
                roseMistOverlayCenter.showToast("Email or password is incorrect.", style: .error)
                return
            }

            SilkBloomLoginSessionStore.saveLoggedInUserID(velvetAuraUser.blushBloomUserID)
            await velvetAuraShowNavigationLoading()
            velvetAuraRouter?.replaceRoot(with: .crystalBlushTabShell)
        } catch {
            roseMistOverlayCenter.showToast("Login failed. Please try again.", style: .error)
        }
    }

    @MainActor
    private func velvetAuraHandleSignUp() async {
        guard velvetAuraCanContinueAuthFlow() else {
            return
        }

        let velvetAuraEmail = blushBloomEmail.velvetAuraNormalizedEmail
        let velvetAuraPassword = blushBloomPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let velvetAuraConfirmPassword = blushBloomConfirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let velvetAuraUserName = blushBloomFullName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard velvetAuraUserName.isEmpty == false else {
            roseMistOverlayCenter.showToast("Please enter full name.", style: .error)
            return
        }

        guard velvetAuraEmail.isEmpty == false, velvetAuraPassword.isEmpty == false else {
            roseMistOverlayCenter.showToast("Please enter email and password.", style: .error)
            return
        }

        guard velvetAuraPassword == velvetAuraConfirmPassword else {
            roseMistOverlayCenter.showToast("Passwords do not match.", style: .error)
            return
        }

        do {
            let velvetAuraEmailExists = try RadiantDewLocalDataCenter.shared.radiantDewUsers
                .readAll()
                .contains { $0.blushBloomEmail.velvetAuraNormalizedEmail == velvetAuraEmail }

            guard velvetAuraEmailExists == false else {
                roseMistOverlayCenter.showToast("This email has already been registered.", style: .error)
                return
            }

            glowMuseFocusedField = nil
            await velvetAuraShowNavigationLoading()
            velvetAuraRouter?.push(
                .moonPetalProfileDetails(
                    email: velvetAuraEmail,
                    password: velvetAuraPassword,
                    userName: velvetAuraUserName
                )
            )
        } catch {
            roseMistOverlayCenter.showToast("Sign up failed. Please try again.", style: .error)
        }
    }

    @MainActor
    private func velvetAuraHandleGuestSignIn() async {
        guard velvetAuraCanContinueAuthFlow() else {
            return
        }

        do {
            if let velvetAuraGuestUser = try RadiantDewLocalDataCenter.shared.radiantDewUsers
                .readAll()
                .first(where: { $0.blushBloomIsGuest }) {
                SilkBloomLoginSessionStore.saveLoggedInUserID(velvetAuraGuestUser.blushBloomUserID)
            } else {
                let velvetAuraGuestUser = BlushBloomUserModel(
                    blushBloomUserID: "guest_\(UUID().uuidString)",
                    blushBloomEmail: "",
                    blushBloomPassword: "",
                    blushBloomAvatar: "VENNEDefaultAvatar",
                    blushBloomUserName: "Guest",
                    blushBloomBirthdayDate: Date(),
                    blushBloomLocation: "",
                    blushBloomGender: "",
                    blushBloomFanIDs: [],
                    blushBloomFollowingIDs: [],
                    blushBloomBlockedIDs: [],
                    blushBloomCoinCount: 0,
                    blushBloomIsGuest: true
                )
                try RadiantDewLocalDataCenter.shared.radiantDewUsers.create(velvetAuraGuestUser)
                SilkBloomLoginSessionStore.saveLoggedInUserID(velvetAuraGuestUser.blushBloomUserID)
            }

            await velvetAuraShowNavigationLoading()
            velvetAuraRouter?.replaceRoot(with: .crystalBlushTabShell)
        } catch {
            roseMistOverlayCenter.showToast("Guest login failed. Please try again.", style: .error)
        }
    }

    @MainActor
    private func velvetAuraShowNavigationLoading() async {
        roseMistOverlayCenter.showLoading()
        try? await Task.sleep(nanoseconds: 800_000_000)
        roseMistOverlayCenter.hideLoading()
    }

    @MainActor
    private func velvetAuraCanContinueAuthFlow() -> Bool {
        guard MoonVelvetPersistentGlobals.moonVelvetDidAgreeEULA else {
            glowMuseFocusedField = nil
            velvetAuraShowsEulaOverlay = true
            return false
        }

        guard MoonVelvetPersistentGlobals.moonVelvetDidAgreeAgreement && blushBloomAgreementAccepted else {
            roseMistOverlayCenter.showToast("Please agree to the User Agreement first.", style: .normal)
            return false
        }

        return true
    }

    private func glowMuseFieldBlock(
        title: String,
        placeholder: String,
        text: Binding<String>,
        focusedField: VelvetAuraFocusField,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(GlowMuseTheme.blushBloomSerifFont(size: 15, weight: .black))
                .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)

            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                        .focused($glowMuseFocusedField, equals: focusedField)
                } else {
                    TextField(placeholder, text: text)
                        .focused($glowMuseFocusedField, equals: focusedField)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .font(GlowMuseTheme.blushBloomBodyFont(size: 16))
            .foregroundStyle(GlowMuseTheme.blushBloomSecondaryText)
            .tint(GlowMuseTheme.velvetAuraCursorTint)
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(GlowMuseTheme.moonPetalFieldFill)
            .clipShape(Capsule())
        }
    }

}

private extension String {
    var velvetAuraNormalizedEmail: String {
        trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

private enum VelvetAuraFocusField: Hashable {
    case signInEmail
    case signInPassword
    case signUpFullName
    case signUpEmail
    case signUpPassword
    case signUpConfirmPassword
}

private enum VelvetAuraAuthMode: CaseIterable {
    case signIn
    case signUp

    var title: String {
        switch self {
        case .signIn:
            return "SIGN IN"
        case .signUp:
            return "SIGN UP"
        }
    }
}

#Preview {
    VelvetAuraAuthPortalView()
}
