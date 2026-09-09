//
//  AlbumViewModel.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 04/09/26.
//

import Foundation

class AlbumViewModel: TrackListViewModelProtocol {
    
    var tracks: [Track] = []
    var albumName: String = ""
    var albumArtworkUrl: String = ""
    private var nextUrl: String?
    private var isFetchingNextPage = false
    
    var onStateChange: ((ListState) -> Void)?
    
    var state: ListState = .loading {
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
    
    func getAlbumDetail(albumId: String) {
        self.getAccessToken { result in
            switch result {
            case .success(let token):
                self.state = .loading
                guard let url = URL(string: "https://api.spotify.com/v1/albums/\(albumId)") else {
                    self.state = .error("Invalid URL")
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.state = .error(error.localizedDescription)
                        }
                        return
                    }
                    
                    guard let data = data else { return }
                    
                    do {
                        let response = try JSONDecoder().decode(AlbumDTO.self, from: data)
                        
                        self.nextUrl = response.tracks.nextUrl
                        self.albumName = response.name
                        self.albumArtworkUrl = response.artworkUrl
                        
                        let newTracks = response.tracks.items.map { dto in
                            let artists = dto.artists.map(\.name).joined(separator: ", ")
                            let duration = self.formatDuration(durationMs: dto.durationMs)
                            
                            return Track(
                                id: dto.id,
                                title: dto.name,
                                artist: artists,
                                duration: duration,
                                imageUrl: self.albumArtworkUrl
                            )
                        }
                        
                        self.tracks = newTracks
                        
                        DispatchQueue.main.async {
                            self.state = .populated
                        }
                        
                    } catch {
                        DispatchQueue.main.async {
                            self.state = .error(error.localizedDescription)
                        }
                    }
                }.resume()
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func formatDuration(durationMs: Int) -> String {
        let totalSeconds = durationMs / 1000
        
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
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
                        let trackPaging = try JSONDecoder().decode(PagingObject<AlbumTrackDTO>.self, from: data)
                        
                        self.nextUrl = trackPaging.nextUrl
                        
                        let additionalTracks = trackPaging.items.map { dto in
                            let artists = dto.artists.map(\.name).joined(separator: ", ")
                            let duration = self.formatDuration(durationMs: dto.durationMs)
                            
                            return Track(
                                id: dto.id,
                                title: dto.name,
                                artist: artists,
                                duration: duration,
                                imageUrl: self.tracks.first?.imageUrl ?? ""
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
