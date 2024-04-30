//
//  AudioType.swift
//  SpotifyCatalog
//
//  Created by SCOTT CROWDER on 4/30/24.
//

import Foundation

struct AudioType: Identifiable {
    let name: String
    var isChecked: Bool = false
    
    var id: String { name }
    var spotifyType: String { name.lowercased() }
    
    static var knownTypes: [AudioType] = [
        .init(name: "Album"),
        .init(name: "Artist", isChecked: true),
        .init(name: "Playlist"),
        .init(name: "Track"),
        .init(name: "Show"),
        .init(name: "Episode"),
        .init(name: "Audiobook"),
    ]
    
    static func toggleCheck(for item: AudioType) {
        print("Audio type: \(item.id)")
        if let index = knownTypes.firstIndex(where: {$0.id == item.id }) {
            knownTypes[index].isChecked.toggle()
        }
    }
}
