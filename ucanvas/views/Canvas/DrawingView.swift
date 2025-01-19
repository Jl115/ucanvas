//
//  DrawingView 2.swift
//  ucanvas
//
//  Created by jldev on 18.01.2025.
//


import SwiftUI

struct DrawingView: View {
    @StateObject private var viewModel = DrawingViewViewModel()


    @State private var selectedLineWidth: CGFloat = 5
    @State private var selectedShape: ShapeType = .freeform
    @State private var mode: CanvasMode = .draw // Toggle between "draw" and "move"

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                // UIKit-Based Drawing Canvas
                DrawingCanvasWrapper(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)

                // Floating Menu (Positioned on screen)
                FloatingMenuView(
                    drawingViewModel: viewModel, // ✅ Directly passes ViewModel
                    selectedLineWidth: $viewModel.selectedLineWidth,
                    selectedShape: $selectedShape,
                    mode: $mode
                )
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(radius: 5)
                )
                .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
            }
        }
        .onDisappear {
            viewModel.save()
        }
        .onSubmit {
            viewModel.save()
        }
    }
}



enum CanvasMode: String, CaseIterable {
    case draw
    case move
}

#Preview {
    DrawingView()
}

