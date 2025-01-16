//
//  FloatingMenu.swift
//  ucanvas
//
//  Created by jldev on 16.01.2025.
//

import SwiftUI

struct FloatingMenuView: View {
    
    @ObservedObject var canvasViewModel: CanvasViewModel

    @Binding  var shapes: [ShapeItem]
    @Binding  var deletedLines: [Line]
    @Binding  var deletedShapes: [ShapeItem]

    @Binding  var selectedColor: Color
    @Binding  var selectedLineWidth: CGFloat
    @Binding  var selectedShape: ShapeType
    @Binding  var mode: CanvasMode

    // Canvas transformation states
    @Binding  var scale: CGFloat
    @Binding  var offset: CGSize
    @Binding  var currentDragOffset: CGSize
    @Binding  var lastScale: CGFloat



    var body: some View {
        VStack {
            HStack {
                ColorPicker("Line Color", selection: $selectedColor)
                    .labelsHidden()
                
                Slider(value: $selectedLineWidth, in: 1 ... 15) {
                    Text("Line Width")
                }
                .frame(maxWidth: 150)
                
                Picker("Mode", selection: $mode) {
                    ForEach(CanvasMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue.capitalized)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Button(action: {
                    if let lastLine = canvasViewModel.lines.popLast() {
                        deletedLines.append(lastLine)
                    } else if let lastShape = shapes.popLast() {
                        deletedShapes.append(lastShape)
                    }
                }) {
                    Image(systemName: "arrow.uturn.backward.circle")
                        .imageScale(.large)
                }
                .disabled(canvasViewModel.lines.isEmpty && shapes.isEmpty)
                
                Button(action: {
                    if let restoredShape = deletedShapes.popLast() {
                        shapes.append(restoredShape)
                    } else if let restoredLine = deletedLines.popLast() {
                        canvasViewModel.lines.append(restoredLine)
                    }
                }) {
                    Image(systemName: "arrow.uturn.forward.circle")
                        .imageScale(.large)
                }
                .disabled(deletedLines.isEmpty && deletedShapes.isEmpty)
                
                Button("Delete All") {
                    canvasViewModel.lines.removeAll()
                    shapes.removeAll()
                    deletedLines.removeAll()
                    deletedShapes.removeAll()
                }
                .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    DrawingView()
}
