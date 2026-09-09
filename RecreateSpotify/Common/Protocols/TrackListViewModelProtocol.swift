//
//  TrackListViewModelProtocol.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 04/09/26.
//

import UIKit

enum ListState {
    case idle
    case loading
    case populated
    case empty
    case error(String)
}

protocol TrackListViewModelProtocol: AnyObject {
    var tracks: [Track] { get }
    var onStateChange: ((ListState) -> Void)? { get set }
    func getAccessToken(completion: @escaping (Result<String, Error>) -> Void)
    func fetchNextPage(completion: @escaping (Result<Void, Error>) -> Void)
    func saveTrack(at index: Int)
}
