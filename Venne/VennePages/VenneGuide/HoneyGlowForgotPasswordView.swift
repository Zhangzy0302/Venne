import SwiftUI

struct HoneyGlowForgotPasswordView: View {
    @State private var honeyGlowEmail = ""
    @State private var honeyGlowPassword = ""
    @State private var honeyGlowConfirmPassword = ""
    @FocusState private var honeyGlowFocusedField: HoneyGlowFocusField?

    var body: some View {
        ZStack {
            RougeRibbonGuideBackground()

            VStack(alignment: .leading, spacing: 0) {
                RougeRibbonTopBar()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("FORGOT\nPASSWORD")
                            .font(GlowMuseTheme.blushBloomSerifFont(size: 18, weight: .black))
                            .foregroundStyle(GlowMuseTheme.blushBloomPrimaryText)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 26)

                        honeyGlowFieldBlock(
                            title: "EMAIL:",
                            placeholder: "Enter email address",
                            text: $honeyGlowEmail,
                            focusedField: .email,
                            keyboardType: .emailAddress
                        )
                        .padding(.top, 26)

                        honeyGlowFieldBlock(
                            title: "PASSWORD:",
                            placeholder: "Enter password",
                            text: $honeyGlowPassword,
                            focusedField: .password,
                            isSecure: true
                        )

                        honeyGlowFieldBlock(
                            title: "PASSWORD:",
                            placeholder: "Please enter the password again",
                            text: $honeyGlowConfirmPassword,
                            focusedField: .confirmPassword,
                            isSecure: true
                        )

                        PetalLuxeButton(title: "SAVE", style: .primary) {}
                            .padding(.top, 170)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 28)
                }
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                honeyGlowFocusedField = nil
            }
        )
    }

    private func honeyGlowFieldBlock(
        title: String,
        placeholder: String,
        text: Binding<String>,
        focusedField: HoneyGlowFocusField,
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
                        .focused($honeyGlowFocusedField, equals: focusedField)
                } else {
                    TextField(placeholder, text: text)
                        .focused($honeyGlowFocusedField, equals: focusedField)
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

private enum HoneyGlowFocusField: Hashable {
    case email
    case password
    case confirmPassword
}

#Preview {
    HoneyGlowForgotPasswordView()
}
