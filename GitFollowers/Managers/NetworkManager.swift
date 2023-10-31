//
//  NetworkManager.swift
//  GitFollowers
//
//  Created by Daniel Priestley on 02/03/2023.
//

import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.github.com/users/"
    let cache = NSCache<NSString, UIImage>()
    
    // to make this singleton a singleton, we need to make it a private init, so it can only be init'd here
    private init() {}
    
    // MARK: GET REQUESTS
    func getFollowers(for username: String, page: Int, completed: @escaping(Result<[Follower], GFError>) -> Void) {
        let endpoint = baseURL + "\(username)/followers?per_page=100&page=\(page)"
        
        // we are guarding this as we want to ensure we have a valid url
        guard let url = URL(string: endpoint) else {
            completed(.failure(.invalidUsername))
            return
        }
        
        // the task is what we are actually performing once we have attained the url
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                completed(.failure(.unableToComplete))
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                // we are trying to decode an array of followers from the data we have recieved, using the Decodable Follower struct
                let followers = try decoder.decode([Follower].self, from: data)
                // if it reaches this step, followers was successfully decoded, so we call completed with the followers data,
                completed(.success(followers))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        
        // this is what actually starts the network call
        task.resume()
    }
    
    func getUserInfo(for username: String, completed: @escaping(Result<User, GFError>) -> Void) {
        let endpoint = baseURL + "\(username)"
        
        // we are guarding this as we want to ensure we have a valid url
        guard let url = URL(string: endpoint) else {
            completed(.failure(.invalidUsername))
            return
        }
        
        // the task is what we are actually performing once we have attained the url
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                completed(.failure(.unableToComplete))
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                // we are trying to decode an array of followers from the data we have recieved, using the Decodable Follower struct
                let user = try decoder.decode(User.self, from: data)
                // if it reaches this step, followers was successfully decoded, so we call completed with the followers data,
                completed(.success(user))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        
        // this is what actually starts the network call
        task.resume()
    }
    
    func downloadImage(from url: String, completed: @escaping (UIImage?) -> Void) {
        // guard to ensure the URL is a valid url
        guard let url = URL(string: url) else {
            completed(nil)
            return
        }
        
        let cacheKey = NSString(string: url.absoluteString) // establish the cache key as the url string
        
        // if the image is already equal to an object in our cache with the same cacheKey, we call completed and return that image
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // As we already have pre-existing logic for placeholder images, we are not doing error handling here
            if error != nil { return }
            
            // combination of guard checks to clean up code
            guard let self = self,
                  error == nil,
                  let response = response as? HTTPURLResponse, response.statusCode == 200,
                  let data = data,
                  let image = UIImage(data: data) else {
                    completed(nil)
                    return
                }
            
            self.cache.setObject(image, forKey: cacheKey)
            
            completed(image)
            
            
        }
        
        task.resume()
    }
}
