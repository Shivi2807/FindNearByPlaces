//
//  GooglePlacesManager.swift
//  FindNearByPlaces
//
//  Created by Shivi Agarwal on 05/07/21.
//

import Foundation
import GooglePlaces

struct Place {
    let name: String
    let identifier: String
}

final class GooglePlacesManager
{
    static let shared = GooglePlacesManager()
    private let client = GMSPlacesClient.shared()
    
    private init(){ }
    
    enum PlacesError: Error {
        case failedToFind
        case failedToGetCoordinate
    }
    
    public func findPlaces(query: String, completion: @escaping (Result<[Place], Error>)-> Void)
    {
        let filter = GMSAutocompleteFilter()
        filter.type = .geocode
        client.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { results, error in
            guard let results = results, error == nil else
            {
                completion(.failure(PlacesError.failedToFind))
                debugPrint(error)
                return
            }
            
            let places: [Place] = results.compactMap({
                Place(name: $0.attributedFullText.string, identifier: $0.placeID)
            })
            
            completion(.success(places))
        }
    }
    
    public func resolveLocation(for place: Place, completion: @escaping (Result<CLLocationCoordinate2D, PlacesError>) ->Void)
    {
        client.fetchPlace(fromPlaceID: place.identifier, placeFields: .coordinate, sessionToken: nil) { googlePlace, error in
            guard let googlePlace = googlePlace else {
                completion(.failure(PlacesError.failedToGetCoordinate))
                return
            }
            let latitude = googlePlace.coordinate.latitude
            let longitude = googlePlace.coordinate.longitude
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            completion(.success(coordinate))
            
        }
        
    }
}

