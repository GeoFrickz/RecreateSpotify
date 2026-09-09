//
//  Environment.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 02/09/26.
//

import Foundation

enum Environment {
    static var spotifyClientId: String {
        guard let object = Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_CLIENT_ID") as? String else {
            fatalError("SPOTIFY_CLIENT_ID missing from Info.plist or Configuration file")
        }
        return object
    }
    
    static var spotifyClientSecret: String {
        guard let object = Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_CLIENT_SECRET") as? String else {
            fatalError("SPOTIFY_CLIENT_SECRET missing from Info.plist or Configuration file")
        }
        return object
    }
}

let clientId = Environment.spotifyClientId
let clientSecret = Environment.spotifyClientSecret
