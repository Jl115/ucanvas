//
//  DrawingViewWrapper.swift
//  ucanvas
//
//  Created by jldev on 18.01.2025.
//


import SwiftUI

struct DrawingCanvasWrapper: UIViewRepresentable {
    @ObservedObject var viewModel: DrawingViewViewModel

    func makeUIView(context: Context) -> CanvasEengine {
        let canvasView = CanvasEengine()
        canvasView.viewModel = viewModel
        return canvasView
    }

    func updateUIView(_ uiView: CanvasEengine, context: Context) {
        uiView.setNeedsDisplay() // Ensures canvas refreshes when ViewModel updates
    }
}


