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
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let transformed = convertToCanvasCoordinates(location)

        currentPoints.append(transformed)
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // finalize drawing with DrawingEngine
        let finalPath = drawEngine.createBezierPath(for: currentPoints)
        let newLine = Line(
            points: finalPath.cgPath.points(),
            color: .red,
            lineWidth: 2 / scale
        )
        viewModel?.lines.append(newLine)
        viewModel?.save()
        print("touch ended")
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

    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()

        context.translateBy(x: offset.x, y: offset.y)
        context.scaleBy(x: scale, y: scale)

        // Existing lines from ViewModel
        viewModel?.lines.forEach { line in
            let path = UIBezierPath()
            guard let firstPoint = line.points.first else { return }
            path.move(to: firstPoint)
            for point in line.points.dropFirst() {
                path.addLine(to: point)
            }
            UIColor.red.setStroke()
            path.lineWidth = line.lineWidth
            path.stroke()
        }

        // Draw in-progress path
        if !currentPoints.isEmpty {
            let tempPath = drawEngine.createBezierPath(for: currentPoints)
            UIColor.red.setStroke()
            tempPath.lineWidth = 2 / scale
            tempPath.stroke()
        }

        context.restoreGState()
    }
}

// Helper extension to extract points from CGPath
extension CGPath {
    func points() -> [CGPoint] {
        var points: [CGPoint] = []
        applyWithBlock { element in
            let point = element.pointee.points.pointee
            points.append(point)
        }
        return points
    }
}
