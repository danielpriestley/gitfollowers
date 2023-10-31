//
//  PersistenceManager.swift
//  GitFollowers
//
//  Created by Daniel Priestley on 10/05/2023.
//

import Foundation

// action type as an enum for consistency
enum PersistenceActionType {
    case add, remove
}

enum PersistenceManager {
    // Initialise the user defaults
    static private let defaults = UserDefaults.standard
    
    // Key enum to avoid string errors
    enum Keys {
        static let favorites = "favorites"
    }
    
    // MARK: Update Favorites
    static func updateWith(favorite: Follower, actionType: PersistenceActionType, completed: @escaping (GFError?) -> Void) { // we are using an escaping closure to present an error if case.failure is true
        retrieveFavorites { result in
            // for the result
            switch result {
            // if it is successful
            case.success(let favorites):
                var retrievedFavorites = favorites
                    
                // for the provided action type
                switch actionType {
                // if it is .add
                case .add:
                    // ensure that the retrievedFavorites does not contain the favorite already, if it does, return.
                    guard !retrievedFavorites.contains(favorite) else {
                        completed(.alreadyInFavorites)
                        return
                    }
                    
                    // add the favorite to the retrievedFavoritesArray
                    retrievedFavorites.append(favorite)
                    
                // if the action type is remove
                case .remove:
                    // remove all occurences where the value for 'login' (the username of the favorited account) is the same as the passed favorites login
                    retrievedFavorites.removeAll { $0.login == favorite.login }
                }
                
                // when the switch is completed, we pass the save function to the escaping 'completion' closure
                completed(save(favorites: retrievedFavorites))
                
            case.failure(let error):
                completed(error)
            }
        }
    }
    
    // MARK: Get Favorites
    static func retrieveFavorites(completed: @escaping (Result<[Follower], GFError>) -> Void) { // the @escaping here is expecting a Result that is either of type array of Followers, or an Error
        // guard to check that favorites data exists as Data for the key 'favorites' defined in the Keys enum
        guard let favoritesData = defaults.object(forKey: Keys.favorites) as? Data else {
            // if no favorites data is found, we just return an empty array
            completed(.success([]))
            return
        }
        
        do {
            // initialise the decoder
            let decoder = JSONDecoder()
            // decode the follower from the favorites data
            let favorites = try decoder.decode([Follower].self, from: favoritesData)
            // when completed, call the @escaping closure and pass the .success result with the favorites array
            completed(.success(favorites))
        } catch {
            // catch any failure and return the .failure result type
            completed(.failure(.unableToFavorite))
        }
    }
    
    // MARK: Save a Favorite
    static func save(favorites: [Follower]) -> GFError? { // returns GFError as an optional, as it may not error
        do {
            // initialise the encoder
            let encoder = JSONEncoder()
            // encode the favorites array
            let encodedFavorites = try encoder.encode(favorites)
            // set the encoded favorites as the value for the favorites Key
            defaults.set(encodedFavorites,  forKey: Keys.favorites)
            // return nil as we have nothing to return but the function expects a return
            return nil
        } catch {
            // return a GFError type .unableToFavorite if the 'do' fails
            return .unableToFavorite
        }
    }
    
    
    
    
}
