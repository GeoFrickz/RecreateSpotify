//
//  UIImageView+Extensions.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 03/09/26.
//

import UIKit

extension UIImageView {
    func load(from urlString: String) {
        self.image = nil
        guard let url = URL(string: urlString) else { return }
        
        if let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)),
           let image = UIImage(data: cachedResponse.data) {
            self.image = image
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let response = response,
                  let image = UIImage(data: data) else { return }
            
            let cachedData = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedData, for: URLRequest(url: url))
            
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
