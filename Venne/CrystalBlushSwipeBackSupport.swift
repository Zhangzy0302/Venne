import SwiftUI
import UIKit
import Combine

struct CrystalBlushSwipeBackSupport: UIViewControllerRepresentable {
    @ObservedObject var crystalBlushRouter: CrystalBlushAppRouter

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        CrystalBlushSwipeBackHostController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            guard let crystalBlushNavigationController = uiViewController.navigationController else { return }
            context.coordinator.crystalBlushRouter = crystalBlushRouter
            context.coordinator.attach(to: crystalBlushNavigationController)
        }
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
        private weak var crystalBlushNavigationController: UINavigationController?
        weak var crystalBlushRouter: CrystalBlushAppRouter?

        func attach(to crystalBlushNavigationController: UINavigationController) {
            self.crystalBlushNavigationController = crystalBlushNavigationController
            crystalBlushNavigationController.delegate = self
            crystalBlushNavigationController.interactivePopGestureRecognizer?.delegate = self
            crystalBlushNavigationController.interactivePopGestureRecognizer?.isEnabled = crystalBlushRouter?.crystalBlushCanSwipeBack ?? false
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard gestureRecognizer === crystalBlushNavigationController?.interactivePopGestureRecognizer else {
                return true
            }

            return (crystalBlushNavigationController?.viewControllers.count ?? 0) > 1
                && (crystalBlushRouter?.crystalBlushCanSwipeBack ?? false)
        }

        func navigationController(
            _ navigationController: UINavigationController,
            didShow viewController: UIViewController,
            animated: Bool
        ) {
            navigationController.interactivePopGestureRecognizer?.isEnabled = navigationController.viewControllers.count > 1
                && (crystalBlushRouter?.crystalBlushCanSwipeBack ?? false)
        }
    }
}

private final class CrystalBlushSwipeBackHostController: UIViewController {
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        view.backgroundColor = .clear
    }
}
