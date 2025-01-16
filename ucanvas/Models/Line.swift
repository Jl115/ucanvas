//
//  Line.swift
//  ucanvas
//
//  Created by jldev on 12.01.2025.
//

import Foundation
import SwiftUI

import Foundation
import SwiftUI

struct Line: Identifiable, Codable {
    let id: UUID
    var points: [CGPoint]
    var customColor: CustomColor
    var lineWidth: CGFloat

    var color: Color {
        get { customColor.color }
        set { customColor = CustomColor(color: newValue) }
    }

    init(id: UUID = UUID(), points: [CGPoint], color: Color, lineWidth: CGFloat) {
        self.id = id
        self.points = points
        self.customColor = CustomColor(color: color)
        self.lineWidth = lineWidth
    }
}

struct CustomColor: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double = 1.0

    init(color: Color) {
        if let components = color.cgColor?.components, components.count >= 3 {
            self.red = Double(components[0])
            self.green = Double(components[1])
            self.blue = Double(components[2])
            self.alpha = components.count > 3 ? Double(components[3]) : 1.0
        } else {
            // Fallback to black if components can't be extracted
            self.red = 0
            self.green = 0
            self.blue = 0
            self.alpha = 1.0
        }
    }

    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

