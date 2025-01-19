//
//  FloatingMenu.swift
//  ucanvas
//
//  Created by jldev on 16.01.2025.
//

import SwiftUI

import SwiftUI

struct FloatingMenuView: View {
    @ObservedObject var drawingViewModel: DrawingViewViewModel  // ✅ Directly use ViewModel
    @Binding var selectedLineWidth: CGFloat
    @Binding var selectedShape: ShapeType
    @Binding var mode: CanvasMode

    var body: some View {
        VStack {
            HStack {
                ColorPicker(
                    "Line Color",
                    selection: $drawingViewModel.selectedColor
                )
                    .labelsHidden()

                Slider(value: $selectedLineWidth, in: 1...15) {
                    Text("Line Width")
                }
                .frame(maxWidth: 150)

                Picker("Mode", selection: $mode) {
                    ForEach(CanvasMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue.capitalized)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                // Undo button
                Button(action: undoAction) {
                    Image(systemName: "arrow.uturn.backward.circle")
                        .imageScale(.large)
                }
                .disabled(drawingViewModel.lines.isEmpty)

                // Redo button
                Button(action: redoAction) {
                    Image(systemName: "arrow.uturn.forward.circle")
                        .imageScale(.large)
                }
                .disabled(drawingViewModel.deletedLines.isEmpty)

                // Delete all button
                Button("Delete All") {
                    drawingViewModel.clearCanvas()
                }
                .foregroundColor(.red)
            }
        }
    }

    // Undo last action
    private func undoAction() {
        drawingViewModel.undoLastAction()
    }

    // Redo last undone action
    private func redoAction() {
        drawingViewModel.redoLastAction()
    }
}

#Preview {
    CanvasEengine()
}
