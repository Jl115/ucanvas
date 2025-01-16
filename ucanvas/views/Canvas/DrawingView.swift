//
//  DrawingView.swift
//  ucanvas
//
//  Created by jldev on 12.01.2025.
//

import SwiftUI

import SwiftUI

struct DrawingView: View {

    // ENVOIREMENT SCREEN STATE
    @Environment(\.scenePhase) var scenePhase
    // LOAD VIEW MODELS
    @ObservedObject var canvasViewModel = CanvasViewModel()
    @State private var shapes = [ShapeItem]()
    @State private var deletedLines = [Line]()
    @State private var deletedShapes = [ShapeItem]()

    @State private var selectedColor: Color = .red
    @State private var selectedLineWidth: CGFloat = 5
    @State private var selectedShape: ShapeType = .freeform
    @State private var mode: CanvasMode = .draw // Toggle between "draw" and "move"

    // Canvas transformation states
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var currentDragOffset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0

    private let canvasSize = CGSize(width: 5000, height: 5000) // Virtual canvas size

    let drawEngine = DrawingEngine()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white // Background color

                // Canvas with zooming and panning
                Canvas { context, _ in
                    context.translateBy(x: offset.width + currentDragOffset.width, y: offset.height + currentDragOffset.height)
                    context.scaleBy(x: scale, y: scale)

                    // Draw lines and shapes
                    for line in canvasViewModel.lines {
                        let path = drawEngine.createPath(for: line.points)
                        context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.lineWidth / scale))
                    }

                    for shape in shapes {
                        let path = drawEngine.createShapePath(for: shape)
                        context.fill(path, with: .color(shape.color))
                        context.stroke(path, with: .color(shape.color), style: StrokeStyle(lineWidth: shape.lineWidth / scale))
                    }
                }
                .gesture(
                    activeGesture(geometry: geometry.size) // Pass geometry.size correctly
                )

                .gesture(
                    activeGesture(geometry: geometry.size) // Combined gesture based on mode and input
                )
                .background(Color.gray.opacity(0.1))
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()

                // Mini-map
                MiniMapView(
                    canvasSize: canvasSize, // Virtual canvas size
                    viewportSize: geometry.size,
                    offset: offset,
                    currentDragOffset: currentDragOffset,
                    scale: scale,
                    lines: canvasViewModel.lines,
                    shapes: shapes
                )
                .frame(width: 150, height: 150)
                .position(x: geometry.size.width - 100, y: 100)

                // Floating Menu
                FloatingMenuView(canvasViewModel: canvasViewModel ,shapes: $shapes, deletedLines: $deletedLines, deletedShapes: $deletedShapes, selectedColor: $selectedColor, selectedLineWidth: $selectedLineWidth, selectedShape: $selectedShape, mode: $mode, scale: $scale, offset: $offset, currentDragOffset: $currentDragOffset, lastScale: $lastScale

                )
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 5)
                    )
                    .padding()
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 50) // Adjust `y` for padding

                    Spacer()
                }

            }
            .onChange(of: scenePhase, initial: false) { oldPhase, newPhase in
                print("old: \(oldPhase), new: \(newPhase)")
                if newPhase == .inactive {
                    canvasViewModel.save()
                }
            }


        .edgesIgnoringSafeArea(.all)
    }

    // Combined gesture logic based on mode
    private func activeGesture(geometry: CGSize) -> AnyGesture<Void> {
        if mode == .draw {
            return AnyGesture(
                singleFingerDrawingGesture()
                    .simultaneously(with: twoFingerZoomGesture(geometry: geometry))
                    .map { _ in () }
            )
        } else {
            return AnyGesture(
                singleFingerPanningGesture(geometry: geometry)
                    .simultaneously(with: twoFingerZoomGesture(geometry: geometry))
                    .map { _ in () }
            )
        }
    }

    // Gesture for single-finger panning
    private func singleFingerPanningGesture(geometry: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                currentDragOffset = value.translation
            }
            .onEnded { value in
                let proposedOffset = CGSize(
                    width: offset.width + value.translation.width,
                    height: offset.height + value.translation.height
                )
                offset = clampedOffset(for: proposedOffset, viewportSize: geometry) // Use geometry directly
                currentDragOffset = .zero
            }
    }

    // Gesture for two-finger zooming
    private func twoFingerZoomGesture(geometry: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let zoomFactor = value / lastScale
                scale = max(0.5, min(5.0, scale * zoomFactor)) // Clamp scale between 0.5 and 5.0
                lastScale = value
            }
            .onEnded { _ in
                lastScale = 1.0 // Reset last scale for next gesture
            }
    }

    // Gesture for single-finger drawing
    private func singleFingerDrawingGesture() -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                let newPoint = convertToCanvasCoordinates(value.location)
                if selectedShape == .freeform {
                    if value.translation.width + value.translation.height == 0 {
                        canvasViewModel.lines.append(Line(points: [newPoint], color: selectedColor, lineWidth: selectedLineWidth))
                    } else {
                        let index = canvasViewModel.lines.count - 1
                        canvasViewModel.lines[index].points.append(newPoint)
                    }
                } else {
                    let start = convertToCanvasCoordinates(value.startLocation)
                    let end = convertToCanvasCoordinates(value.location)
                    if shapes.isEmpty || shapes.last?.isFinalized == true {
                        shapes
                            .append(
                                ShapeItem(
                                    type: selectedShape,
                                    startPoint: start,
                                    endPoint: end,
                                    color: selectedColor,
                                    lineWidth: selectedLineWidth,
                                    isFinalized: false
                                )
                            )
                    } else {
                        shapes[shapes.count - 1].endPoint = end
                    }
                }
            }
            .onEnded { _ in
                if selectedShape == .freeform {
                    if let last = canvasViewModel.lines.last?.points, last.isEmpty {
                        canvasViewModel.lines.removeLast()
                    }
                } else {
                    shapes[shapes.count - 1].isFinalized = true
                }
            }
    }

    // Clamp the offset to keep the viewport within the canvas boundaries
    private func clampedOffset(for proposedOffset: CGSize, viewportSize: CGSize) -> CGSize {
        let maxX = (canvasSize.width - viewportSize.width / scale) / 2
        let maxY = (canvasSize.height - viewportSize.height / scale) / 2

        return CGSize(
            width: min(max(proposedOffset.width, -maxX), maxX),
            height: min(max(proposedOffset.height, -maxY), maxY)
        )
    }

    // Helper to convert screen coordinates to canvas coordinates
    private func convertToCanvasCoordinates(_ point: CGPoint) -> CGPoint {
        return CGPoint(
            x: (point.x - offset.width - currentDragOffset.width) / scale,
            y: (point.y - offset.height - currentDragOffset.height) / scale
        )
    }
}

enum CanvasMode: String, CaseIterable {
    case draw
    case move
}

#Preview {
    DrawingView()
}
