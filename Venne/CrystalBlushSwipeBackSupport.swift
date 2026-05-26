import SwiftUI
import UIKit
import Combine

struct CrystalBlushSwipeBackSupport: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        CrystalBlushSwipeBackHostController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            guard let crystalBlushNavigationController = uiViewController.navigationController else { return }
            context.coordinator.attach(to: crystalBlushNavigationController)
        }
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
        private weak var crystalBlushNavigationController: UINavigationController?

        func attach(to crystalBlushNavigationController: UINavigationController) {
            self.crystalBlushNavigationController = crystalBlushNavigationController
            crystalBlushNavigationController.delegate = self
            crystalBlushNavigationController.interactivePopGestureRecognizer?.delegate = self
            crystalBlushNavigationController.interactivePopGestureRecognizer?.isEnabled = true
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard gestureRecognizer === crystalBlushNavigationController?.interactivePopGestureRecognizer else {
                return true
            }

            return (crystalBlushNavigationController?.viewControllers.count ?? 0) > 1
        }

        func navigationController(
            _ navigationController: UINavigationController,
            didShow viewController: UIViewController,
            animated: Bool
        ) {
            navigationController.interactivePopGestureRecognizer?.isEnabled = navigationController.viewControllers.count > 1
        }
    }
}

private final class CrystalBlushSwipeBackHostController: UIViewController {
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        view.backgroundColor = .clear
    }
}

