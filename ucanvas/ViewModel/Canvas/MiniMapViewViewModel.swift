//
//  FloatinMenuViewViewModel.swift
//  ucanvas
//
//  Created by jldev on 17.01.2025.
//

import Foundation
import SwiftUI

class MiniMapViewModel: ObservableObject {
    let canvasSize: CGSize
    let miniMapSize: CGSize

    // MARK: - Initializer
    init(canvasSize: CGSize, miniMapSize: CGSize) {
        self.canvasSize = canvasSize
        self.miniMapSize = miniMapSize
    }

    // MARK: - Computed Properties for MiniMap Scaling
    func scaledPoint(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: (point.x / canvasSize.width) * miniMapSize.width,
            y: (point.y / canvasSize.height) * miniMapSize.height
        )
    }

    func scaledPath(for shape: ShapeItem) -> Path {
        var path = Path()
        let start = scaledPoint(shape.startPoint)
        let end = scaledPoint(shape.endPoint)

        switch shape.type {
        case .rectangle:
            path.addRect(CGRect(x: start.x, y: start.y, width: end.x - start.x, height: end.y - start.y))
        case .circle:
            let radius = hypot(end.x - start.x, end.y - start.y) / 2
            let center = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
            path.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        case .freeform:
            break
        }
        return path
    }

    func scaledViewportSize(viewportSize: CGSize) -> CGSize {
        CGSize(
            width: (viewportSize.width / canvasSize.width) * miniMapSize.width,
            height: (viewportSize.height / canvasSize.height) * miniMapSize.height
        )
    }

    func scaledViewportPosition(offset: CGSize, currentDragOffset: CGSize) -> CGPoint {
        let x = ((-offset.width - currentDragOffset.width) / canvasSize.width) * miniMapSize.width + miniMapSize.width / 2
        let y = ((-offset.height - currentDragOffset.height) / canvasSize.height) * miniMapSize.height + miniMapSize.height / 2
        return CGPoint(x: x, y: y)
    }
}




