import SwiftUI

struct CrystalBlushNavigationHost: View {
    @EnvironmentObject private var crystalBlushRouter: CrystalBlushAppRouter

    var body: some View {
        NavigationView {
            CrystalBlushRouteNode(
                crystalBlushRoute: crystalBlushRouter.crystalBlushRootRoute,
                crystalBlushDepth: -1
            )
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .id(crystalBlushRouter.crystalBlushRootRoute)
    }
}

private struct CrystalBlushRouteNode: View {
    @EnvironmentObject private var crystalBlushRouter: CrystalBlushAppRouter

    let crystalBlushRoute: CrystalBlushAppRoute
    let crystalBlushDepth: Int

    private var crystalBlushNextDepth: Int {
        crystalBlushDepth + 1
    }

    var body: some View {
        ZStack {
            crystalBlushRoute.crystalBlushDestination
                .navigationBarHidden(true)

            NavigationLink(
                destination: CrystalBlushRouteDestination(crystalBlushDepth: crystalBlushNextDepth)
                    .navigationBarHidden(true),
                isActive: crystalBlushIsActiveBinding
            ) {
                EmptyView()
            }
            .hidden()
        }
        .navigationBarHidden(true)
        .background(CrystalBlushSwipeBackSupport(crystalBlushRouter: crystalBlushRouter))
    }

    private var crystalBlushIsActiveBinding: Binding<Bool> {
        Binding(
            get: {
                crystalBlushRouter.crystalBlushRoutePath.count > crystalBlushNextDepth
            },
            set: { crystalBlushIsActive in
                if crystalBlushIsActive == false {
                    crystalBlushRouter.popToDepth(crystalBlushNextDepth)
                }
            }
        )
    }
}

private struct CrystalBlushRouteDestination: View {
    @EnvironmentObject private var crystalBlushRouter: CrystalBlushAppRouter

    let crystalBlushDepth: Int

    var body: some View {
        Group {
            if crystalBlushRouter.crystalBlushRoutePath.indices.contains(crystalBlushDepth) {
                CrystalBlushRouteNode(
                    crystalBlushRoute: crystalBlushRouter.crystalBlushRoutePath[crystalBlushDepth],
                    crystalBlushDepth: crystalBlushDepth
                )
            } else {
                EmptyView()
            }
        }
    }
}
