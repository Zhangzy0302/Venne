import SwiftUI

struct RougeRibbonGuideBackground: View {
    var body: some View {
        GeometryReader { geo in
            Image("VENNEMainBg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
        }
        
    }
}

struct RougeRibbonTopBar: View {
    @Environment(\.crystalBlushRouter) private var rougeRibbonRouter
    var onBackTap: (() -> Void)?

    var body: some View {
        HStack {
            Button {
                if let onBackTap {
                    onBackTap()
                } else {
                    rougeRibbonRouter?.pop()
                }
            } label: {
                Image("VENNECNavBack")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
            }

            Spacer()
        }
        .padding(.top, 12)
        .padding(.horizontal, 20)
    }
}

