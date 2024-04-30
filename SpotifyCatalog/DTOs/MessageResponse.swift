//
//  MessageResponse.swift
//  SpotifyCatalog
//
//  Created by SCOTT CROWDER on 4/30/24.
//

import Foundation

struct MessageResponse: Codable {
    var meta: ResponseMetadata
    var data: ResponseData
}

struct ResponseMetadata: Codable {
    var message: String
    var status: String
}

struct ResponseData: Codable {
    var albums: AlbumMeta?
    var artists: ArtistMeta?
    var tracks: TrackMeta?
}
