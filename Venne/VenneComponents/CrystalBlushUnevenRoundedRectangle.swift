import SwiftUI

struct CrystalBlushUnevenRoundedRectangle: Shape {
    var topLeadingRadius: CGFloat = 0
    var bottomLeadingRadius: CGFloat = 0
    var bottomTrailingRadius: CGFloat = 0
    var topTrailingRadius: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let crystalBlushMaxRadius = min(rect.width, rect.height) / 2
        let crystalBlushTopLeading = min(max(0, topLeadingRadius), crystalBlushMaxRadius)
        let crystalBlushBottomLeading = min(max(0, bottomLeadingRadius), crystalBlushMaxRadius)
        let crystalBlushBottomTrailing = min(max(0, bottomTrailingRadius), crystalBlushMaxRadius)
        let crystalBlushTopTrailing = min(max(0, topTrailingRadius), crystalBlushMaxRadius)

        var crystalBlushPath = Path()
        crystalBlushPath.move(to: CGPoint(x: rect.minX + crystalBlushTopLeading, y: rect.minY))
        crystalBlushPath.addLine(to: CGPoint(x: rect.maxX - crystalBlushTopTrailing, y: rect.minY))

        if crystalBlushTopTrailing > 0 {
            crystalBlushPath.addArc(
                center: CGPoint(x: rect.maxX - crystalBlushTopTrailing, y: rect.minY + crystalBlushTopTrailing),
                radius: crystalBlushTopTrailing,
                startAngle: .degrees(-90),
                endAngle: .degrees(0),
                clockwise: false
            )
        }

        crystalBlushPath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - crystalBlushBottomTrailing))

        if crystalBlushBottomTrailing > 0 {
            crystalBlushPath.addArc(
                center: CGPoint(x: rect.maxX - crystalBlushBottomTrailing, y: rect.maxY - crystalBlushBottomTrailing),
                radius: crystalBlushBottomTrailing,
                startAngle: .degrees(0),
                endAngle: .degrees(90),
                clockwise: false
            )
        }

        crystalBlushPath.addLine(to: CGPoint(x: rect.minX + crystalBlushBottomLeading, y: rect.maxY))

        if crystalBlushBottomLeading > 0 {
            crystalBlushPath.addArc(
                center: CGPoint(x: rect.minX + crystalBlushBottomLeading, y: rect.maxY - crystalBlushBottomLeading),
                radius: crystalBlushBottomLeading,
                startAngle: .degrees(90),
                endAngle: .degrees(180),
                clockwise: false
            )
        }

        crystalBlushPath.addLine(to: CGPoint(x: rect.minX, y: rect.minY + crystalBlushTopLeading))

        if crystalBlushTopLeading > 0 {
            crystalBlushPath.addArc(
                center: CGPoint(x: rect.minX + crystalBlushTopLeading, y: rect.minY + crystalBlushTopLeading),
                radius: crystalBlushTopLeading,
                startAngle: .degrees(180),
                endAngle: .degrees(270),
                clockwise: false
            )
        }

        crystalBlushPath.closeSubpath()
        return crystalBlushPath
    }
}
