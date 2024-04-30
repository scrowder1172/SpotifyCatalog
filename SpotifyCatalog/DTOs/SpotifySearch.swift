//
//  SpotifySearchDTO.swift
//  SpotifyCatalog
//
//  Created by SCOTT CROWDER on 4/30/24.
//

import Foundation

struct SpotifySearchBody: Codable {
    var query: String
    var market: String
    var type: [String]
}
