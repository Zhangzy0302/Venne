import SwiftUI
import UIKit

struct CrystalBlushKeyboardAdaptiveModifier: ViewModifier {
    @State private var crystalBlushKeyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, crystalBlushKeyboardHeight)
            .animation(.easeOut(duration: 0.25), value: crystalBlushKeyboardHeight)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { crystalBlushNotification in
                crystalBlushKeyboardHeight = crystalBlushKeyboardHeight(from: crystalBlushNotification)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                crystalBlushKeyboardHeight = 0
            }
    }

    private func crystalBlushKeyboardHeight(from crystalBlushNotification: Notification) -> CGFloat {
        guard let crystalBlushKeyboardFrame = crystalBlushNotification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let crystalBlushWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return 0
        }

        let crystalBlushKeyboardTop = crystalBlushKeyboardFrame.minY
        let crystalBlushWindowHeight = crystalBlushWindow.bounds.height
        let crystalBlushSafeBottom = crystalBlushWindow.safeAreaInsets.bottom
        return max(0, crystalBlushWindowHeight - crystalBlushKeyboardTop - crystalBlushSafeBottom)
    }
}

struct CrystalBlushKeyboardHeightReaderModifier: ViewModifier {
    @Binding var crystalBlushKeyboardHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { crystalBlushNotification in
                withAnimation(.easeOut(duration: 0.25)) {
                    crystalBlushKeyboardHeight = crystalBlushKeyboardHeight(from: crystalBlushNotification)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    crystalBlushKeyboardHeight = 0
                }
            }
    }

    private func crystalBlushKeyboardHeight(from crystalBlushNotification: Notification) -> CGFloat {
        guard let crystalBlushKeyboardFrame = crystalBlushNotification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let crystalBlushWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return 0
        }

        let crystalBlushKeyboardTop = crystalBlushKeyboardFrame.minY
        let crystalBlushWindowHeight = crystalBlushWindow.bounds.height
        let crystalBlushSafeBottom = crystalBlushWindow.safeAreaInsets.bottom
        return max(0, crystalBlushWindowHeight - crystalBlushKeyboardTop - crystalBlushSafeBottom)
    }
}

struct CrystalBlushKeyboardDismissModifier: ViewModifier {
    var crystalBlushOnDismiss: () -> Void

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture().onEnded {
                    crystalBlushOnDismiss()
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
            )
    }
}

extension View {
    func crystalBlushKeyboardAdaptive() -> some View {
        modifier(CrystalBlushKeyboardAdaptiveModifier())
    }

    func crystalBlushReadKeyboardHeight(_ crystalBlushKeyboardHeight: Binding<CGFloat>) -> some View {
        modifier(CrystalBlushKeyboardHeightReaderModifier(crystalBlushKeyboardHeight: crystalBlushKeyboardHeight))
    }

    func crystalBlushDismissKeyboardOnTap(_ crystalBlushOnDismiss: @escaping () -> Void) -> some View {
        modifier(CrystalBlushKeyboardDismissModifier(crystalBlushOnDismiss: crystalBlushOnDismiss))
    }
}
