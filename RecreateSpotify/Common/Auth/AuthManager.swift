//
//  AuthViewModel.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 03/09/26.
//

import Foundation

class AuthManager {
    static let shared = AuthManager()
    
    private(set) var accessToken: String?
    
    private init() {
        fetchAccessToken{ _ in }
    }
    
    func fetchAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        guard let base64Encoded = "\(Environment.spotifyClientId):\(Environment.spotifyClientSecret)".data(using: .utf8)?.base64EncodedString() else { return }
        request.setValue("Basic \(base64Encoded)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyString = "grant_type=client_credentials"
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                self.accessToken = authResponse.accessToken
                
                DispatchQueue.main.async {
                    completion(.success(authResponse.accessToken))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
