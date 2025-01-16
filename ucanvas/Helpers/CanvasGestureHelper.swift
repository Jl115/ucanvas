import SwiftUI

class CanvasGestureHelper: ObservableObject { // ✅ Add `ObservableObject`

    @Binding var offset: CGSize
    @Binding var currentDragOffset: CGSize
    @Binding var scale: CGFloat
    @Binding var lastScale: CGFloat
    @Binding var mode: CanvasMode

    @Binding var selectedColor: Color
    @Binding var selectedLineWidth: CGFloat
    @Binding var selectedShape: ShapeType
    @ObservedObject var canvasViewModel: CanvasViewModel
    @Binding var shapes: [ShapeItem]
    @Binding var deletedLines: [Line]
    @Binding var deletedShapes: [ShapeItem]

    private let canvasSize = CGSize(width: 5000, height: 5000) // Virtual canvas size

    init(
        offset: Binding<CGSize>,
        currentDragOffset: Binding<CGSize>,
        scale: Binding<CGFloat>,
        lastScale: Binding<CGFloat>,
        mode: Binding<CanvasMode>,
        selectedColor: Binding<Color>,
        selectedLineWidth: Binding<CGFloat>,
        selectedShape: Binding<ShapeType>,
        canvasViewModel: CanvasViewModel,
        shapes: Binding<[ShapeItem]>,
        deletedLines: Binding<[Line]>,
        deletedShapes: Binding<[ShapeItem]>
    ) {
        self._offset = offset
        self._currentDragOffset = currentDragOffset
        self._scale = scale
        self._lastScale = lastScale
        self._mode = mode
        self._selectedColor = selectedColor
        self._selectedLineWidth = selectedLineWidth
        self._selectedShape = selectedShape
        self.canvasViewModel = canvasViewModel
        self._shapes = shapes
        self._deletedLines = deletedLines
        self._deletedShapes = deletedShapes
    }


    // 🔹 Returns the appropriate gesture based on the mode
    func activeGesture(geometry: CGSize) -> AnyGesture<Void> {
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

    // 🔹 Gesture for single-finger panning
    func singleFingerPanningGesture(geometry: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                self.currentDragOffset = value.translation
            }
            .onEnded { value in
                let proposedOffset = CGSize(
                    width: self.offset.width + value.translation.width,
                    height: self.offset.height + value.translation.height
                )
                self.offset = self.clampedOffset(for: proposedOffset, viewportSize: geometry)
                self.currentDragOffset = .zero
            }
    }

    // 🔹 Gesture for two-finger zooming
    func twoFingerZoomGesture(geometry: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let zoomFactor = value / self.lastScale
                self.scale = max(0.5, min(5.0, self.scale * zoomFactor))
                self.lastScale = value
            }
            .onEnded { _ in
                self.lastScale = 1.0
            }
    }

    // 🔹 Gesture for single-finger drawing
    func singleFingerDrawingGesture() -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                let newPoint = self.convertToCanvasCoordinates(value.location)
                if self.selectedShape == .freeform {
                    if value.translation.width + value.translation.height == 0 {
                        self.canvasViewModel.lines.append(Line(points: [newPoint], color: self.selectedColor, lineWidth: self.selectedLineWidth))
                    } else {
                        let index = self.canvasViewModel.lines.count - 1
                        self.canvasViewModel.lines[index].points.append(newPoint)
                    }
                } else {
                    let start = self.convertToCanvasCoordinates(value.startLocation)
                    let end = self.convertToCanvasCoordinates(value.location)
                    if self.shapes.isEmpty || self.shapes.last?.isFinalized == true {
                        self.shapes.append(
                            ShapeItem(
                                type: self.selectedShape,
                                startPoint: start,
                                endPoint: end,
                                color: self.selectedColor,
                                lineWidth: self.selectedLineWidth,
                                isFinalized: false
                            )
                        )
                    } else {
                        self.shapes[self.shapes.count - 1].endPoint = end
                    }
                }
            }
            .onEnded { _ in
                if self.selectedShape == .freeform {
                    if let last = self.canvasViewModel.lines.last?.points, last.isEmpty {
                        self.canvasViewModel.lines.removeLast()
                    }
                } else {
                    self.shapes[self.shapes.count - 1].isFinalized = true
                }
            }
    }

    // 🔹 Clamp offset within canvas boundaries
    private func clampedOffset(for proposedOffset: CGSize, viewportSize: CGSize) -> CGSize {
        let maxX = (canvasSize.width - viewportSize.width / scale) / 2
        let maxY = (canvasSize.height - viewportSize.height / scale) / 2

        return CGSize(
            width: min(max(proposedOffset.width, -maxX), maxX),
            height: min(max(proposedOffset.height, -maxY), maxY)
        )
    }

    // 🔹 Convert screen coordinates to canvas coordinates
    private func convertToCanvasCoordinates(_ point: CGPoint) -> CGPoint {
        return CGPoint(
            x: (point.x - offset.width - currentDragOffset.width) / scale,
            y: (point.y - offset.height - currentDragOffset.height) / scale
        )
    }
}
