//
//  MapDirectionsService.swift
//  Core
//
//  Created by Alya Filon  on 10.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import YALAPIClient
import CoreLocation

final public class MapDirectionsService {

    private let APIKey = "AIzaSyDIRJuwwZhZVG0Q3rgIFjG_tWi_zbz36Ws"
    private let baseURL = "https://maps.googleapis.com/maps/api/directions/json"

    public init() { }

    public func getRoute(sourceCoordinate: CLLocationCoordinate2D,
                         destinationCoordinate: CLLocationCoordinate2D,
                         completion: @escaping ((Result<String?>) -> Void)) {

        guard let url = createURL(sourceCoordinate: sourceCoordinate,
                                  destinationCoordinate: destinationCoordinate) else {
            completion(.success(nil))
            return
        }

        let defaultSession = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?

        dataTask = defaultSession.dataTask(with: url) { data, response, error in
          if let error = error {
            completion(.failure(error))
          } else if
            let data = data,
            let response = response as? HTTPURLResponse,
            response.statusCode == 200 {

            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                  let route = (json["routes"] as? [[String: Any]])?.first,
                  let polyline = route["overview_polyline"] as? [String: Any],
                  let points = polyline["points"] as? String else {
                completion(.success(nil))

                return
            }

            completion(.success(points))
          }
        }

        dataTask?.resume()
    }

    private func createURL(sourceCoordinate: CLLocationCoordinate2D,
                           destinationCoordinate: CLLocationCoordinate2D) -> URL? {

        let source = "\(sourceCoordinate.latitude),\(sourceCoordinate.longitude)"
        let destination = "\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)"
        let path = "?origin=\(source)&destination=\(destination)&mode=walking&key=\(APIKey)"

        return URL(string: baseURL + path)
    }
    
}
