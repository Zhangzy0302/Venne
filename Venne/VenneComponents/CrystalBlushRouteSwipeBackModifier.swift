import SwiftUI

struct CrystalBlushRouteSwipeBackModifier: ViewModifier {
    @ObservedObject var crystalBlushRouter: CrystalBlushAppRouter

    private let crystalBlushEdgeWidth: CGFloat = 30
    private let crystalBlushTriggerDistance: CGFloat = 72
    private let crystalBlushVerticalTolerance: CGFloat = 80

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .leading) {
                Color.clear
                    .frame(width: crystalBlushEdgeWidth)
                    .contentShape(Rectangle())
                    .allowsHitTesting(crystalBlushRouter.crystalBlushCanPop)
                    .gesture(
                        DragGesture(minimumDistance: 18, coordinateSpace: .global)
                            .onEnded { crystalBlushValue in
                                crystalBlushHandleSwipe(crystalBlushValue)
                            }
                    )
                    .ignoresSafeArea()
            }
    }

    private func crystalBlushHandleSwipe(_ crystalBlushValue: DragGesture.Value) {
        guard crystalBlushRouter.crystalBlushCanPop else { return }

        let crystalBlushHorizontalMove = crystalBlushValue.translation.width
        let crystalBlushVerticalMove = abs(crystalBlushValue.translation.height)
        let crystalBlushPredictedMove = crystalBlushValue.predictedEndTranslation.width

        guard crystalBlushHorizontalMove > crystalBlushTriggerDistance,
              crystalBlushPredictedMove > crystalBlushTriggerDistance,
              crystalBlushVerticalMove < crystalBlushVerticalTolerance else {
            return
        }

        crystalBlushRouter.pop()
    }
}

extension View {
    func crystalBlushRouteSwipeBack(using crystalBlushRouter: CrystalBlushAppRouter) -> some View {
        modifier(CrystalBlushRouteSwipeBackModifier(crystalBlushRouter: crystalBlushRouter))
    }
}
