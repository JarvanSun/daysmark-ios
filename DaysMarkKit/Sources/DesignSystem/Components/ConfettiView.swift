//
//  ConfettiView.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/10/07.
//

import SunUserInterface
import SwiftUI

public struct ConfettiView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dimensions) private var dimensions

    @State private var start = Date.now
    @State private var isFinished = false

    private let pieces = (0..<220).map { _ in
        Piece(
            x: Double.random(in: 0...1),
            speed: Double.random(in: 0.16...0.42),
            spin: Double.random(in: -6...6),
            hue: Double.random(in: 0...1),
            size: Double.random(in: 0...1),
            delay: Double.random(in: 0...2.2)
        )
    }

    public init() {}

    public var body: some View {
        if !reduceMotion, !isFinished {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    draw(in: context, size: size, date: timeline.date)
                }
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()
            .accessibilityHidden(true)
            .task {
                try? await Task.sleep(for: .seconds(lifetime))
                isFinished = true
            }
        }
    }

    private func draw(in context: GraphicsContext, size: CGSize, date: Date) {
        let elapsed = date.timeIntervalSince(start)

        for piece in pieces {
            let time = elapsed - piece.delay
            let y = -dimensions.confettiEntryOffset + time * piece.speed * size.height

            guard time > 0, y < size.height + dimensions.confettiEntryOffset else { continue }

            let x = piece.x * size.width + sin(time * 2 + piece.x * 9) * dimensions.confettiSway
            let side = pieceSize(piece.size)
            var pieceContext = context
            pieceContext.translateBy(x: x, y: y)
            pieceContext.rotate(by: .radians(time * piece.spin))
            pieceContext.fill(
                Path(CGRect(x: -side / 2, y: -side / 4, width: side, height: side / 2)),
                with: .color(Color(hue: piece.hue, saturation: 0.75, brightness: 1))
            )
        }
    }

    private func pieceSize(_ fraction: Double) -> CGFloat {
        let range = dimensions.confettiPieceMaximumSize - dimensions.confettiPieceMinimumSize

        return dimensions.confettiPieceMinimumSize + range * fraction
    }

    private var lifetime: Double {
        pieces.map { $0.delay + 1.1 / $0.speed }.max() ?? 0
    }
}

extension ConfettiView {
    private struct Piece {
        let x: Double
        let speed: Double
        let spin: Double
        let hue: Double
        let size: Double
        let delay: Double
    }
}
