//
//  CanvasObservable.swift
//  ucanvas
//
//  Created by jldev on 14.01.2025.
//

import Foundation
import SwiftUI
class DrawingViewViewModel: ObservableObject {
    @Published var lines = [Line]()
    @Published var deletedLines = [Line]()  // ✅ Store deleted lines for redo
    @Published var selectedLineWidth: CGFloat = 5
    @Published var selectedColor: Color = .red



    init() {
        loadSavedData()
    }

    private func loadSavedData() {
        if FileManager.default.fileExists(atPath: url.path), let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            do {
                let savedLines = try decoder.decode([Line].self, from: data)
                self.lines = savedLines
            } catch {
                print("Error decoding:", error)
            }
        }
    }

    func save() {
        DispatchQueue.global(qos: .background).async {
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(self.lines)
                try data.write(to: self.url)
            } catch {
                print("Error encoding:", error)
            }
        }
    }

    func undoLastAction() {
        if let lastLine = lines.popLast() {
            deletedLines.append(lastLine)
            save()
        }
    }

    func redoLastAction() {
        if let restoredLine = deletedLines.popLast() {
            lines.append(restoredLine)
            save()
        }
    }

    func clearCanvas() {
        lines.removeAll()
        deletedLines.removeAll()
        save()
    }

    private var url: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("ucanvas").appendingPathExtension("json")
    }
}
