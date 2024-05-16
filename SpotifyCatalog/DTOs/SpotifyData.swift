//
//  SpotifyData.swift
//  SpotifyCatalog
//
//  Created by SCOTT CROWDER on 4/30/24.
//

import Foundation

protocol SpotifyData {
    var name: String { get set }
    var images: [SpotifyImage]? { get set }
}

struct ArtistMeta: Codable {
    var href: String
    var items: [Artist]
    var limit: Int
    var next: String?
    var offset: Int
    var previous: String?
    var total: Int
}

struct Artist: SpotifyData, Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case followers
        case genres
        case href
        case id
        case images
        case name
        case popularity
        case type
        case uri
    }
    
    var externalUrls: ExternalUrl?
    var followers: Followers?
    var genres: [String]?
    var href: String?
    var id: String
    var images: [SpotifyImage]?
    var name: String
    var popularity: Int?
    var type: String?
    var uri: String?
}

struct AlbumMeta: Codable {
    var href: String
    var limit: Int
    var next: String?
    var offset: Int
    var previous: String?
    var total: Int
    var items: [Album]
}

struct Album: SpotifyData, Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case artists
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case href
        case id
        case images
        case name
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case restrictions
        case totalTracks = "total_tracks"
        case type
        case uri
    }
    var albumType: String
        var artists: [Artist]
    var availableMarkets: [String]?
    var externalUrls: ExternalUrl
    var href: String
    var id: String
    var images: [SpotifyImage]?
    var name: String
    var releaseDate: String
    var releaseDatePrecision: String
    var restrictions: Restriction?
    var totalTracks: Int
    var type: String
    var uri: String
}

struct TrackMeta: Codable {
    var href: String
    var items: [Track]
    var limit: Int
    var next: String?
    var offset: Int
    var previous: String?
    var total: Int
}

struct Track: Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case album
        case artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMs = "duration_ms"
        case explicit
        case externalIDs = "external_ids"
        case externalUrls = "external_urls"
        case href
        case id
        case isLocal = "is_local"
        case isPlayable = "is_playable"
        case name
        case popularity
        case previewUrl = "preview_url"
        case restrictions
        case trackNumber = "track_number"
        case type
        case uri
    }
    
    var album: Album?
    var artists: [Artist]?
    var availableMarkets: [String]?
    var discNumber: Int?
    var durationMs: Int?
    var explicit: Bool?
    var externalIDs: ExternalID?
    var externalUrls: ExternalUrl?
    var href: String?
    var id: String
    var isLocal: Bool?
    var isPlayable: Bool?
    var name: String
    var popularity: Int?
    var previewUrl: String?
    var restrictions: Restriction?
    var trackNumber: Int?
    var type: String?
    var uri: String?
}

struct ExternalID: Codable {
    var isrc: String?
    var ean: String?
    var upc: String?
}

struct ExternalUrl: Codable {
    var spotify: String
}

struct Restriction: Codable {
    var reason: String
}

struct Followers: Codable {
    var href: String?
    var total: Int
}

struct SpotifyImage: Codable {
    var url: String
    var height: Int?
    var width: Int?
}
