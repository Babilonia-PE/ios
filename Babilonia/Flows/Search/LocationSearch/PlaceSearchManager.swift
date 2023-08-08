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

            var radius: Float = 2000 // 1000 // 5000
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
    
    func reverseGeocodeCoordinateToValues(_ coordinate: CLLocationCoordinate2D,
                                  completion: @escaping (String?, String?, String?, String?, String?) -> Void) {
        let defaultSession = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        
        var urlComponents = URLComponents(string: "https://maps.googleapis.com/maps/api/geocode/json")
        let key = "AIzaSyCpGfIjj1B1wxgOkjdog6Da_1xetzn9OnI"
        urlComponents?.query = "latlng=\(coordinate.latitude),\(coordinate.longitude)&key=\(key)"
        guard let url = urlComponents?.url else {
          return
        }
        dataTask = defaultSession.dataTask(with: url) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, nil, nil, nil, nil)
                }
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                          let results = json["results"] as? [[String: Any]] else {
                        DispatchQueue.main.async {
                            completion(nil, nil, nil, nil, nil)
                        }
                        return
                    }
                    
                    guard let result = results.first,
                          let addressComponents = result["address_components"] as? [[String: Any]] else {
                        DispatchQueue.main.async {
                            completion(nil, nil, nil, nil, nil)
                        }
                        return
                    }
                    print("result = \(result)")
                    var country: String?
                    var district: String?
                    var departament: String?
                    var province: String?
                    var postalCode: String?
                    
                    addressComponents.forEach { addressComponent in
                        if let types = addressComponent["types"] as? [String], let first = types.first {
                            switch first {
                            case "country":
                                country = addressComponent["long_name"] as? String
                            case "locality":
                                district = self.getDistrict(addressComponent: addressComponent)
                            case "administrative_area_level_1":
                                departament = self.getDepartament(addressComponent: addressComponent)
                            case "administrative_area_level_2":
                                province = self.getProvince(addressComponent: addressComponent)
                            case "postal_code":
                                postalCode = addressComponent["long_name"] as? String
                            default: break
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        completion(district, province, departament, country, postalCode)
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, nil, nil, nil, nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, nil, nil, nil, nil)
                }
            }
        }
        dataTask?.resume()
    }
    
    private func getDepartament(addressComponent: [String: Any]) -> String? {
        let mDepartament = addressComponent["long_name"] as? String
        if let mDepartament = mDepartament {
            var newValue = mDepartament
                .replacingOccurrences(of: "Departamento de", with: "")
            newValue = newValue
                .replacingOccurrences(of: "Provincia de", with: "")
            newValue = newValue
                .replacingOccurrences(of: "Province", with: "")
            newValue = newValue
                .replacingOccurrences(of: "Municipalidad Metropolitana de", with: "")
            newValue = newValue
                .replacingOccurrences(of: "Gobierno Regional de", with: "")
            return newValue
                .replacingOccurrences(of: "Cercado de", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return mDepartament
        }
    }
    
    private func getProvince(addressComponent: [String: Any]) -> String? {
        let mProvince = addressComponent["long_name"] as? String
        if let mProvince = mProvince {
            let newValue = mProvince
                .replacingOccurrences(of: "Provincia de", with: "")
            return newValue
                .replacingOccurrences(of: "Cercado de", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return mProvince
        }
    }
    
    private func getDistrict(addressComponent: [String: Any]) -> String? {
        let mDistrict = addressComponent["long_name"] as? String
        if let mDistrict = mDistrict {
            let newValue = mDistrict
                .replacingOccurrences(of: "Distrito de", with: "")
            return newValue
                .replacingOccurrences(of: "Cercado de", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return mDistrict
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
