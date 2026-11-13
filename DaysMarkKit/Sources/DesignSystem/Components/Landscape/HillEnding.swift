//
//  HillEnding.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

nonisolated struct HillEnding: Shape {
    let isPast: Bool

    func path(in rect: CGRect) -> Path {
        guard !isPast else { return Path(rect) }

        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.width * 0.84, y: 0))
        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.height),
            control1: CGPoint(x: rect.width * 0.91, y: rect.height * 0.1),
            control2: CGPoint(x: rect.width * 0.94, y: rect.height * 0.98)
        )
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}
