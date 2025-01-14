//
//  MiniMap.swift
//  ucanvas
//
//  Created by jldev on 12.01.2025.
//

import Foundation
import SwiftUI

struct MiniMapView: View {
    let canvasSize: CGSize // Virtual size of the full canvas
    let viewportSize: CGSize // Size of the visible viewport
    let offset: CGSize // Offset of the main canvas
    let currentDragOffset: CGSize // Temporary drag offset
    let scale: CGFloat // Current zoom scale
    let lines: [Line] // Lines to render on the mini-map
    let shapes: [ShapeItem] // Shapes to render on the mini-map

    private let miniMapSize = CGSize(width: 150, height: 150) // Size of the mini-map

    var body: some View {
        ZStack {
            // Background for the mini-map
            Color.gray.opacity(0.2)

            // Render lines on the mini-map
            ForEach(lines) { line in
                Path { path in
                    if let firstPoint = line.points.first {
                        path.move(to: scaledPoint(firstPoint))
                        for point in line.points {
                            path.addLine(to: scaledPoint(point))
                        }
                    }
                }
                .stroke(line.color, lineWidth: 0.5)
            }

            // Render shapes on the mini-map
            ForEach(shapes) { shape in
                let path = scaledPath(for: shape)
                path.stroke(shape.color, lineWidth: 0.5)
            }

            // Viewport rectangle
            Rectangle()
                .stroke(Color.blue, lineWidth: 1)
                .frame(
                    width: scaledViewportSize().width,
                    height: scaledViewportSize().height
                )
                .position(scaledViewportPosition())
        }
        .clipShape(Rectangle()) // Ensure content stays within the mini-map
    }

    // Scale a point to fit within the mini-map
    private func scaledPoint(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: (point.x / canvasSize.width) * miniMapSize.width,
            y: (point.y / canvasSize.height) * miniMapSize.height
        )
    }

    // Scale a shape's path to fit within the mini-map
    private func scaledPath(for shape: ShapeItem) -> Path {
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

    // Calculate the scaled viewport size for the mini-map
    private func scaledViewportSize() -> CGSize {
        CGSize(
            width: (viewportSize.width / canvasSize.width) * miniMapSize.width / scale,
            height: (viewportSize.height / canvasSize.height) * miniMapSize.height / scale
        )
    }

    // Calculate the scaled viewport position for the mini-map
    private func scaledViewportPosition() -> CGPoint {
        let x = ((-offset.width - currentDragOffset.width) / canvasSize.width) * miniMapSize.width + miniMapSize.width / 2
        let y = ((-offset.height - currentDragOffset.height) / canvasSize.height) * miniMapSize.height + miniMapSize.height / 2

        return CGPoint(x: x, y: y)
    }
}
