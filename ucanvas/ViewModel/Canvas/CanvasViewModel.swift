//
//  CanvasObservable.swift
//  ucanvas
//
//  Created by jldev on 14.01.2025.
//

import Foundation

class CanvasViewModel: ObservableObject {
    //STATES
    @Published var lines = [Line]()

    //CONSTRUCTOR
    init() {
        if FileManager.default.fileExists(atPath: url.path), let data = try? Data(contentsOf: url) {

            let decoder = JSONDecoder()
            do {
                let lines = try decoder.decode([Line].self, from: data)
                print(lines)
                self.lines = lines
            } catch {
                print("Error decoding", error)
            }

        }
    }

    //FUNCTIONS
    func save() {
        DispatchQueue.global(qos: .background).async { [unowned self] in

            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(lines)
                print(data)
                try data.write(to: self.url)
            } catch {
                print("Error encoding", error)
            }
        }
    }

    var url: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]

        return documentsDirectory
            .appendingPathComponent("ucanvas")
            .appendingPathExtension( "json")
    }
}
