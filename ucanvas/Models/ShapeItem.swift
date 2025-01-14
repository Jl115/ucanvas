//
//  ShapeItem.swift
//  ucanvas
//
//  Created by jldev on 12.01.2025.
//

import Foundation
import SwiftUI

struct ShapeItem: Identifiable {
    let id = UUID()
    var type: ShapeType
    var startPoint: CGPoint
    var endPoint: CGPoint
    var color: Color
    var lineWidth: CGFloat
    var isFinalized: Bool
}



enum ShapeType: String, CaseIterable {
    case freeform
    case rectangle
    case circle
}
