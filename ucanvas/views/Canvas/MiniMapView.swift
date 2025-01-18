//
//  MiniMap.swift
//  ucanvas
//
//  Created by jldev on 12.01.2025.
//

import SwiftUI

struct MiniMapView: View {
    // Initialize MiniMapViewModel inside MiniMapView
    @StateObject private var viewModel = MiniMapViewModel(
        canvasSize: CGSize(width: 5000, height: 5000),
        miniMapSize: CGSize(width: 150, height: 150)
    )

    @Binding var lines: [Line]
    @Binding var shapes: [ShapeItem]
    @Binding var offset: CGSize
    @Binding var currentDragOffset: CGSize

    let canvasSize: CGSize
    let viewportSize: CGSize

    private let miniMapSize = CGSize(width: 150, height: 150) // Size of the mini-map

    var body: some View {
        ZStack {
            // Background for the mini-map
            Color.gray.opacity(0.2)

            // Render lines dynamically from `lines` binding
            ForEach(lines, id: \.id) { line in
                Path { path in
                    if let firstPoint = line.points.first {
                        path.move(to: viewModel.scaledPoint(firstPoint))
                        for point in line.points {
                            path.addLine(to: viewModel.scaledPoint(point))
                        }
                    }
                }
                .stroke(line.color, lineWidth: 0.5)
            }

            // Render shapes dynamically from `shapes` binding
            ForEach(shapes, id: \.id) { shape in
                let path = viewModel.scaledPath(for: shape)
                path.stroke(shape.color, lineWidth: 0.5)
            }

            // Viewport rectangle
            Rectangle()
                .stroke(Color.blue, lineWidth: 1)
                .frame(
                    width: viewModel.scaledViewportSize(viewportSize: viewportSize).width,
                    height: viewModel.scaledViewportSize(viewportSize: viewportSize).height
                )
                .position(viewModel.scaledViewportPosition(offset: offset, currentDragOffset: currentDragOffset))
        }
        .clipShape(Rectangle()) // Ensure content stays within the mini-map
    }
}


