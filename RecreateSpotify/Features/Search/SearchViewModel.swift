//
//  SearchViewModel.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 02/09/26.
//

import Foundation

class SearchViewModel: TrackListViewModelProtocol {
    var tracks: [Track] = []
    private var nextUrl: String?
    private var isFetchingNextPage = false
    
    var onStateChange: ((ListState) -> Void)?
    
    var state: ListState = .idle {
        didSet {
            onStateChange?(state)
        }
    }
    
    func getAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
        if let token = AuthManager.shared.accessToken {
            completion(.success(token))
        } else {
            AuthManager.shared.fetchAccessToken { result in
                switch result {
                case .success(let token):
                    completion(.success(token))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func search(query: String, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        state = .loading
        guard let url = URL(string: "https://api.spotify.com/v1/search?q=\(query)&type=track&limit=10") else {
            completion(.failure(NSError(domain: "URL", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(SearchResponse.self, from: data)
                
                guard let trackPaging = response.tracks else {
                    self.state = .empty
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                    return
                }
                
                self.nextUrl = trackPaging.nextUrl
                
                let newTracks = trackPaging.items.map { dto in
                    
                    let artists = dto.artists.map(\.name).joined(separator: ", ")
                    let duration = self.formatDuration(durationMs: dto.durationMs)
                    
                    return Track(
                        id: dto.id,
                        title: dto.name,
                        artist: artists,
                        duration: duration,
                        imageUrl: dto.album.artworkUrl
                    )
                }
                
                self.tracks = newTracks
                
                self.state = newTracks.isEmpty ? .empty : .populated
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                self.state = .error(error.localizedDescription)
                
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func formatDuration(durationMs: Int) -> String {
        let totalSeconds = durationMs / 1000
        
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var searchWorkItem: DispatchWorkItem?
    
    func searchWithDebounce(query: String, completion: @escaping (Result<Void, Error>) -> Void) {
        searchWorkItem?.cancel()
        
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            self.tracks = []
            state = .idle
            completion(.success(()))
            return
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            self.getAccessToken{ result in
                switch result {
                case .success(let token):
                    self.search(query: trimmedQuery, token: token, completion: completion)
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
        
        searchWorkItem = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: workItem)
    }
    
    func fetchNextPage(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let nextUrlString = nextUrl,
              let url = URL(string: nextUrlString),
              !isFetchingNextPage else { return }
    
        isFetchingNextPage = true
        
        getAccessToken { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let token):
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    defer { self.isFetchingNextPage = false }
                    
                    if let error = error {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    
                    guard let data = data else { return }
                    
                    do {
                        let response = try JSONDecoder().decode(SearchResponse.self, from: data)
                        
                        guard let trackPaging = response.tracks else {
                            self.state = .empty
                            DispatchQueue.main.async {
                                completion(.success(()))
                            }
                            return
                        }
                        
                        self.nextUrl = trackPaging.nextUrl
                        
                        let additionalTracks = trackPaging.items.map { dto in
                            let artists = dto.artists.map(\.name).joined(separator: ", ")
                            let duration = self.formatDuration(durationMs: dto.durationMs)
                            
                            return Track(
                                id: dto.id,
                                title: dto.name,
                                artist: artists,
                                duration: duration,
                                imageUrl: dto.album.artworkUrl
                            )
                        }
                        
                        self.tracks.append(contentsOf: additionalTracks)
                        
                        DispatchQueue.main.async {
                            completion(.success(()))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }.resume()
                
            case .failure(let error):
                self.isFetchingNextPage = false
                
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func saveTrack(at index: Int) {
        guard tracks.indices.contains(index) else { return }
        
        let track = tracks[index]
        
        if CoreDataManager.shared.isSavedTrack(id: track.id) {
            CoreDataManager.shared.deleteTrack(id: track.id)
            print("Removed from library: \(track.title)")
        } else {
            CoreDataManager.shared.saveTrack(
                id: track.id,
                title: track.title,
                artist: track.artist,
                duration: track.duration,
                imageUrl: track.imageUrl
            )
            print("Saved to library: \(track.title)")
        }
    }
}
