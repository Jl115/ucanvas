//
//  DrawingView.swift
//  ucanvas
//
//  Created by jldev on 18.01.2025.
//

import UIKit

class CanvasEengine: UIView {
    // Reference to ViewModel for loading & saving
    var viewModel: DrawingViewViewModel?

    let drawEngine = DrawingEngine()
    private var currentPoints: [CGPoint] = []  // store raw points

    // Zoom & Pan
    var scale: CGFloat = 1.0
    var offset: CGPoint = .zero

    // Gesture Recognizers (only keep panning + pinching)
    private var panGesture: UIPanGestureRecognizer!
    private var pinchGesture: UIPinchGestureRecognizer!
    private var temporaryLine: Line? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGestures() {
        // Two-finger panning gesture
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanning(_:)))
        panGesture.minimumNumberOfTouches = 2
        addGestureRecognizer(panGesture)

        // Pinch gesture for zooming
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinching(_:)))
        addGestureRecognizer(pinchGesture)
    }

    // MARK: - Touch Handling for Drawing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if let touch = touches.first, touch.type == .pencil {
            print("Apple Pencil is being used!")
            return
        }
        let location = touch.location(in: self)
        let transformed = convertToCanvasCoordinates(location)

        currentPoints = [transformed]

        // Initialize `temporaryLine` immediately
        temporaryLine = Line(
            points: [transformed],
            color: viewModel?.selectedColor ?? .black,
            lineWidth: viewModel?.selectedLineWidth ?? 2.0
        )
    }


    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let transformed = convertToCanvasCoordinates(location)

        currentPoints.append(transformed)

        // Temporary line with the current color & width
        temporaryLine = Line(
            points: currentPoints,
            color: viewModel?.selectedColor ?? .black,
            lineWidth: viewModel?.selectedLineWidth ?? 2.0
        )

        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let tempLine = temporaryLine, !tempLine.points.isEmpty else { return }

        // Store the completed stroke
        viewModel?.lines.append(tempLine)
        viewModel?.save()

        // Clear the temporary line
        temporaryLine = nil
        currentPoints.removeAll()

        setNeedsDisplay()
    }



    // MARK: - Zoom & Pan Handlers
    @objc private func handlePanning(_ gesture: UIPanGestureRecognizer) {
        guard gesture.numberOfTouches == 3 else { return }

        let translation = gesture.translation(in: self)

        // Apply translation
        offset.x += translation.x
        offset.y += translation.y

        // Reset translation to avoid compounding
        gesture.setTranslation(.zero, in: self)

        setNeedsDisplay()
    }

    @objc private func handlePinching(_ gesture: UIPinchGestureRecognizer) {
        guard let view = self.superview else { return }

        guard gesture.numberOfTouches == 2 else { return }


        if gesture.state == .began || gesture.state == .changed {
            let minScale: CGFloat = 0.5
            let maxScale: CGFloat = 5.0

            // 1️⃣ Get the pinch center relative to the view
            let pinchCenter = gesture.location(in: view)

            // 2️⃣ Convert pinchCenter to canvas coordinates
            let pinchCenterOnCanvas = convertToCanvasCoordinates(pinchCenter)

            // 3️⃣ Compute the new scale and clamp it
            let newScale = min(max(scale * gesture.scale, minScale), maxScale)

            // 4️⃣ Adjust offset to keep pinch center in place
            let scaleChange = newScale / scale
            offset.x = pinchCenterOnCanvas.x - (pinchCenterOnCanvas.x - offset.x) * scaleChange
            offset.y = pinchCenterOnCanvas.y - (pinchCenterOnCanvas.y - offset.y) * scaleChange

            // 5️⃣ Apply new scale and reset the gesture scale
            scale = newScale
            gesture.scale = 1.0

            currentPoints.removeAll()

            setNeedsDisplay()
        }
    }



    // MARK: - Convert to Canvas Coordinates
    private func convertToCanvasCoordinates(_ point: CGPoint) -> CGPoint {
        let transformedX = (point.x / scale) - (offset.x / scale)
        let transformedY = (point.y / scale) - (offset.y / scale)
        return CGPoint(x: transformedX, y: transformedY)
    }

    // Function to draw a given line with its properties
    func drawLine(_ line: Line, context: CGContext) {
        guard let firstPoint = line.points.first else { return }

        let path = UIBezierPath()
        path.move(to: firstPoint)
        for point in line.points.dropFirst() {
            path.addLine(to: point)
        }

        // Convert SwiftUI.Color to UIColor
        let uiColor = UIColor(line.color)
        context.setStrokeColor(uiColor.cgColor)

        // Apply correct line width
        context.setLineWidth(line.lineWidth / scale)

        context.addPath(path.cgPath)
        context.strokePath()
    }

    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()

        context.translateBy(x: offset.x, y: offset.y)
        context.scaleBy(x: scale, y: scale)


        // Draw all stored lines from ViewModel
        viewModel?.lines.forEach { drawLine($0, context: context) }

        // Draw in-progress line with correct color and width
        if !currentPoints.isEmpty {
            //TODO: Improve lines for curved lines
            let tempPath = drawEngine.createBezierPath(for: currentPoints)

            let tempColor = viewModel?.selectedColor ?? .black
            let uiTempColor = UIColor(tempColor)
            uiTempColor.setStroke()  // Apply correct stroke color

            tempPath.lineWidth = (viewModel?.selectedLineWidth ?? 2.0) / scale  // Use selected width
            tempPath.stroke()
        }

        context.restoreGState()
    }
}

// Helper extension to extract points from CGPath
//extension CGPath {
//    func points() -> [CGPoint] {
//        var points: [CGPoint] = []
//        applyWithBlock { element in
//            let point = element.pointee.points.pointee
//            points.append(point)
//        }
//        return points
//    }
//}
