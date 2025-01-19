//
//  DrawingEngine.swift
//  ucanvas
//
//  Created by jldev on 12.01.2025.
//

import Foundation
import SwiftUI

class DrawingEngine {


    func createPath(for points: [CGPoint]) -> Path {
        var path = Path()
        if let firstPoint = points.first {
            path.move(to: firstPoint)
        }

        for index in 1 ..< points.count {
            let midPoint = calcuateMidPoint(points[index - 1], points[index])
            path.addQuadCurve(to: midPoint, control: points[index - 1])
        }
        if let lastPoint = points.last {
            path.addLine(to: lastPoint)
        }
        
        return path
    }

    func createShapePath(for shape: ShapeItem) -> Path {
        var path = Path()
        switch shape.type {
        case .rectangle:
            let rect = CGRect(
                origin: CGPoint(
                    x: min(shape.startPoint.x, shape.endPoint.x),
                    y: min(shape.startPoint.y, shape.endPoint.y)
                ),
                size: CGSize(
                    width: abs(shape.endPoint.x - shape.startPoint.x),
                    height: abs(shape.endPoint.y - shape.startPoint.y)
                )
            )
            path.addRect(rect)
        case .circle:
            let radius = hypot(shape.endPoint.x - shape.startPoint.x, shape.endPoint.y - shape.startPoint.y) / 2
            let center = CGPoint(
                x: (shape.startPoint.x + shape.endPoint.x) / 2,
                y: (shape.startPoint.y + shape.endPoint.y) / 2
            )
            path.addEllipse(in: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
        default:
            break
        }
        return path
    }

    
    func createBezierPath(for points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        guard points.count > 1 else { return path }

        path.move(to: points[0])

        for i in 1..<points.count {
            let midPoint = calcuateMidPoint(points[i - 1], points[i])
            path.addQuadCurve(to: midPoint, controlPoint: points[i - 1])
        }

        // Instead of a line, do one final quad curve from the last midpoint to the final point:
        if points.count >= 2 {
            let lastIndex = points.count - 1
            path.addQuadCurve(to: points[lastIndex], controlPoint: points[lastIndex - 1])
        }

        return path
    }
//    func createBezierPath(for points: [CGPoint]) -> UIBezierPath {
//        let path = UIBezierPath()
//        guard points.count > 1 else { return path }
//
//        path.move(to: points[0])
//
//        if points.count == 2 {
//            // If only two points, draw a simple line
//            path.addLine(to: points[1])
//            return path
//        }
//
//        for i in 1..<points.count - 1 {
//            let previous = points[i - 1]
//            let current = points[i]
//            let next = points[i + 1]
//
//            // Calculate control points for cubic Bézier
//            let control1 = CGPoint(x: (previous.x + current.x) / 2, y: (previous.y + current.y) / 2)
//            let control2 = CGPoint(x: (current.x + next.x) / 2, y: (current.y + next.y) / 2)
//
//            path.addCurve(to: next, controlPoint1: control1, controlPoint2: control2)
//        }
//
//        return path
//    }




    func calcuateMidPoint(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
       return CGPoint(x: (point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
    }
}
