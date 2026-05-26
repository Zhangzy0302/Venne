import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct CrystalBlushPhotoPickerButton<Label: View>: View {
    var crystalBlushSelectionLimit: Int = 1
    var crystalBlushOnImageDataPicked: ([Data]) -> Void
    @ViewBuilder var crystalBlushLabel: () -> Label

    @State private var crystalBlushShowsPicker = false

    var body: some View {
        Button {
            crystalBlushShowsPicker = true
        } label: {
            crystalBlushLabel()
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $crystalBlushShowsPicker) {
            CrystalBlushPhotoPickerController(
                crystalBlushSelectionLimit: crystalBlushSelectionLimit,
                crystalBlushOnImageDataPicked: crystalBlushOnImageDataPicked
            )
        }
    }
}

private struct CrystalBlushPhotoPickerController: UIViewControllerRepresentable {
    var crystalBlushSelectionLimit: Int
    var crystalBlushOnImageDataPicked: ([Data]) -> Void
    @Environment(\.dismiss) private var crystalBlushDismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var crystalBlushConfiguration = PHPickerConfiguration(photoLibrary: .shared())
        crystalBlushConfiguration.filter = .images
        crystalBlushConfiguration.selectionLimit = crystalBlushSelectionLimit

        let crystalBlushPicker = PHPickerViewController(configuration: crystalBlushConfiguration)
        crystalBlushPicker.delegate = context.coordinator
        return crystalBlushPicker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(
            crystalBlushDismiss: {
                crystalBlushDismiss()
            },
            crystalBlushOnImageDataPicked: crystalBlushOnImageDataPicked
        )
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var crystalBlushDismiss: () -> Void
        var crystalBlushOnImageDataPicked: ([Data]) -> Void

        init(
            crystalBlushDismiss: @escaping () -> Void,
            crystalBlushOnImageDataPicked: @escaping ([Data]) -> Void
        ) {
            self.crystalBlushDismiss = crystalBlushDismiss
            self.crystalBlushOnImageDataPicked = crystalBlushOnImageDataPicked
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            crystalBlushDismiss()

            guard results.isEmpty == false else {
                return
            }

            let crystalBlushGroup = DispatchGroup()
            let crystalBlushLock = NSLock()
            var crystalBlushImageDataList: [Data] = []

            for crystalBlushResult in results {
                let crystalBlushProvider = crystalBlushResult.itemProvider
                guard crystalBlushProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) else {
                    continue
                }

                crystalBlushGroup.enter()
                crystalBlushProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { crystalBlushData, _ in
                    if let crystalBlushData {
                        crystalBlushLock.lock()
                        crystalBlushImageDataList.append(crystalBlushData)
                        crystalBlushLock.unlock()
                    }
                    crystalBlushGroup.leave()
                }
            }

            crystalBlushGroup.notify(queue: .main) {
                self.crystalBlushOnImageDataPicked(crystalBlushImageDataList)
            }
        }
    }
}
