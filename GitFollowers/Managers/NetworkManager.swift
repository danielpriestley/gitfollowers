//
//  NetworkManager.swift
//  GitFollowers
//
//  Created by Daniel Priestley on 02/03/2023.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    let baseURL = "https://api.github.com/users/"
    
    // to make this singleton a singleton, we need to make it a private init, so it can only be init'd here
    private init() {}
    
    // MARK: GET REQUESTS
    func getFollowers(for username: String, page: Int, completed: @escaping([Follower]?, ErrorMessage?) -> Void) {
        let endpoint = baseURL + "\(username)/followers?per_page=100&page=\(page)"
        
        // we are guarding this as we want to ensure we have a valid url
        guard let url = URL(string: endpoint) else {
            completed(nil, ErrorMessage.invalidUsername)
            return
        }
        
        // the task is what we are actually performing once we have attained the url
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                completed(nil, ErrorMessage.unableToComplete)
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(nil, ErrorMessage.invalidResponse)
                return
            }
            
            guard let data = data else {
                completed(nil, ErrorMessage.invalidData)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                // we are trying to decode an array of followers from the data we have recieved, using the Decodable Follower struct
                let followers = try decoder.decode([Follower].self, from: data)
                // if it reaches this step, followers was successfully decoded, so we call completed with the followers data,
                completed(followers, nil)
            } catch {
                completed(nil, ErrorMessage.invalidData)
            }
        }
        
        // this is what actually starts the network call
        task.resume()
    }
}
