//
//  HomeViewModel.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 04/09/26.
//

import UIKit
import CoreData

class HomeViewModel {
    
    var sections: [AlbumSection] = [
        AlbumSection(title: "", albums: [], state: .idle),
        AlbumSection(title: "", albums: [], state: .idle)
    ]
    
    var onSectionsUpdated: (() -> Void)?
    
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
    
    func fetchAlbum(for index:Int, query: String) {
        self.getAccessToken { result in
            switch result {
            case .success(let token):
                let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                guard let url = URL(string: "https://api.spotify.com/v1/search?q=\(encodedQuery)&type=album&limit=10") else {
                    self.sections[index].state = .error("Invalid URL")
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        self.sections[index].state = .error(error.localizedDescription)
                        return
                    }
                    
                    guard let data = data else { return }
                    
                    do {
                        let response = try JSONDecoder().decode(SearchResponse.self, from: data)
                        
                        guard let albumPaging = response.albums else {
                            DispatchQueue.main.async {
                                self.sections[index].state = .error("No albums found")
                            }
                            return
                        }
                        
                        let albums = albumPaging.items.map { dto in
                            let artists = dto.artists.map(\.name).joined(separator: ", ")
                            return Album(
                                id: dto.id,
                                name: dto.name,
                                artists: artists,
                                artworkUrl: dto.artworkUrl)
                        }
                        
                        DispatchQueue.main.async {
                            if (query == "tag:new") {
                                self.sections[index].title = "New Albums"
                            }
                            else if (query == "eminem taylor swift") {
                                self.sections[index].title = "Popular Albums"
                            }
                            else {
                                self.sections[index].title = "More from \(query.replacingOccurrences(of: "artist:", with: ""))"
                            }
                            self.sections[index].albums = albums
                            self.sections[index].state = .populated
                            self.onSectionsUpdated?()
                        }
                        
                    } catch {
                        DispatchQueue.main.async {
                            self.sections[index].state = .error(error.localizedDescription)
                        }
                    }
                }.resume()
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.sections[index].state = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func fetchAllSections() {
        
        let fetchRequest: NSFetchRequest<TrackEntity> = TrackEntity.fetchRequest()
        
        let context = CoreDataManager.shared.context
        
        do {
            let savedTracks = try context.fetch(fetchRequest)
            
            if savedTracks.isEmpty {
                runDefaultQueries()
                return
            }
            
            let getFirstArtist: (String) -> String = { artistsString in
                return artistsString.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? artistsString
            }
            
            if savedTracks.count == 1 {
                if let singleTrack = savedTracks.first, let rawArtists = singleTrack.artists {
                    let mainArtist = getFirstArtist(rawArtists)
                    fetchAlbum(for: 0, query: "artist:\(mainArtist)")
                } else {
                    fetchAlbum(for: 0, query: "tag:new")
                }
                
                fetchAlbum(for: 1, query: "eminem taylor swift")
            }
            
            else if savedTracks.count > 1 {
                let shuffledTracks = savedTracks.shuffled()
                let track1 = shuffledTracks[0]
                let track2 = shuffledTracks[1]
                
                if let artist1 = track1.artists, let artist2 = track2.artists {
                    fetchAlbum(for: 0, query: "artist:\(artist1)")
                    fetchAlbum(for: 1, query: "artist:\(artist2)")
                } else {
                    runDefaultQueries()
                }
            }
            
            
        } catch {
            print("Failed to fetch saved tracks: \(error.localizedDescription)")
            runDefaultQueries()
        }
    }
    
    private func runDefaultQueries() {
        fetchAlbum(for: 0, query: "tag:new")
        fetchAlbum(for: 1, query: "eminem taylor swift")
    }
}
