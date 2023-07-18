//
//  PlaceSearchManager.swift
//  Babilonia
//
//  Created by Alya Filon  on 18.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Core
import GooglePlaces
import GoogleMaps

typealias SearchLocations = (address: String, placeID: String)

class PlaceSearchManager {

    private let placesClient: GMSPlacesClient
    private let token: GMSAutocompleteSessionToken

    init() {
        self.placesClient = GMSPlacesClient()
        self.token = GMSAutocompleteSessionToken()
    }

    func placeAutocomplete(term: String,
                           coordinate: CLLocationCoordinate2D? = nil,
                           completion: @escaping ([SearchLocations]) -> Void) {
        let filter = GMSAutocompleteFilter()
        filter.type = .region
        filter.countries = ["UA", "PE"]

        placesClient.findAutocompletePredictions(fromQuery: term,
                                                 filter: filter,
                                                 sessionToken: token) { results, _ in
            guard let predictions = results else { return }

            let locations = predictions.compactMap { (address: $0.attributedFullText.string, placeID: $0.placeID) }
            completion(locations)
        }
    }

    func generateAreaInfo(for placeID: String,
                          completion: @escaping (FetchListingsAreaInfo?, String?) -> Void) {
        placesClient.lookUpPlaceID(placeID) { result, _ in
            guard let place = result else {
                completion(nil, nil)
                return
            }

            var address = place.formattedAddress
            if let components = place.addressComponents {
                for component in components {
                    if component.types.contains("postal_code") {
                        let postalCode = ", \(component.name)"
                        address = address?.replacingOccurrences(of: postalCode, with: "")
                    }
                }
            }

            var radius: Float = 5000
            if let northEast = place.viewport?.northEast,
               let southWest = place.viewport?.southWest {
                let northEastLocation = CLLocation(latitude: northEast.latitude,
                                                   longitude: northEast.longitude)
                let southWestLocation = CLLocation(latitude: southWest.latitude,
                                                   longitude: southWest.longitude)

                radius = Float(northEastLocation.distance(from: southWestLocation) / 2)
            }

            let areaInfo = FetchListingsAreaInfo(latitude: Float(place.coordinate.latitude),
                                                 longitude: Float(place.coordinate.longitude),
                                                 radius: radius)
            completion(areaInfo, address)
        }
    }

    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D,
                                  completion: @escaping (String?) -> Void) {
        let geocoder = GMSGeocoder()

        geocoder.reverseGeocodeCoordinate(coordinate) { [weak self] (response, _) in
            if let result = response?.firstResult() {
                let address = self?.parseAddress(result)
                completion(address)
            } else {
                completion(nil)
            }
        }
    }

    private func parseAddress(_ address: GMSAddress) -> String? {
        let components = [address.subLocality, address.locality,
                          address.administrativeArea, address.country].compactMap { $0 }

        var addressString = ""
        for index in components.indices {
            let isLast = index == components.count - 1
            let component = isLast ? components[index] : "\(components[index]), "
            addressString.append(component)
        }

        return addressString
    }

}
