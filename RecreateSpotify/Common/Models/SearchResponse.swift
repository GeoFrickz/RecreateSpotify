//
//  SearchTracksResponse.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 02/09/26.
//

nonisolated struct SearchResponse: Codable {
    let tracks: PagingObject<SpotifyTrackDTO>?
    let albums: PagingObject<EmbeddedAlbumDTO>?
}

struct PagingObject<T: Codable>: Codable {
    let items: [T]
    let nextUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case items
        case nextUrl = "next"
    }
}

nonisolated struct SpotifyTrackDTO: Codable {
    let id: String
    let name: String
    let artists: [ArtistDTO]
    let album: EmbeddedAlbumDTO
    let durationMs: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, artists, album
        case durationMs = "duration_ms"
    }
}

nonisolated struct AlbumTrackDTO: Codable {
    let id: String
    let name: String
    let artists: [ArtistDTO]
    let durationMs: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, artists
        case durationMs = "duration_ms"
    }
}

struct ArtistDTO: Codable {
    let name: String
}

nonisolated struct EmbeddedAlbumDTO: Codable {
    let id: String
    let name: String
    let images: [ImageDTO]
    let artists: [ArtistDTO]
    
    var artworkUrl: String {
        return images.first?.url ?? ""
    }
}

nonisolated struct AlbumDTO: Codable {
    let id: String
    let name: String
    let images: [ImageDTO]
    let artists: [ArtistDTO]
    let tracks: PagingObject<AlbumTrackDTO>
    
    var artworkUrl: String {
        return images.first?.url ?? ""
    }
}

struct ImageDTO: Codable {
    let height: Int?
    let width: Int?
    let url: String
}
