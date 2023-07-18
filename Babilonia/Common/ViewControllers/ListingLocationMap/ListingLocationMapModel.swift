//
//  ListingLocationMapModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 09.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Core
import RxSwift
import RxCocoa

enum ListingLocationMapEvent: Event { }

final class ListingLocationMapModel: EventNode {

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude))
    }

    var currentLocation: CLLocation?
    var isGoogleMapsInstalled: Bool {
        guard let url = URL(string: "comgooglemaps://") else { return false }

        return UIApplication.shared.canOpenURL(url)
    }
    var isWazeInstalled: Bool {
        guard let url = URL(string: "waze://") else { return false }

        return UIApplication.shared.canOpenURL(url)
    }
    var requestForLocationPermission = PublishRelay<Void>()

    let location: Location
    let propertyType: PropertyType?
    private let locationManager: LocationManager

    init(parent: EventNode,
         location: Location,
         propertyType: PropertyType?,
         locationManager: LocationManager) {
        self.location = location
        self.propertyType = propertyType
        self.locationManager = locationManager

        super.init(parent: parent)
    }

    func openAppleMap() {
        guard let location = currentLocation else { return }

        let sourceCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                      longitude: location.coordinate.longitude)
        locationManager.openDirectionInMap(sourceCoordinate: sourceCoordinate,
                                           destinationCoordinate: coordinate,
                                           name: self.location.address ?? "")
    }

    func openGoogleMap() {
        guard isGoogleMapsInstalled else { return }

        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        let urlString = "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:])
        }
    }

    func openWazeMap() {
        guard isWazeInstalled else { return }

        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        let urlString = "waze://?ll=\(latitude),\(longitude)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:])
        }
    }

    func checkLocation() {
        if locationManager.authorizationStatusIsGranted {
            locationManager.didChangeAuthorization = nil
            locationManager.updateCurrentLocation()
            currentLocation = locationManager.currentLocation
        } else {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()

            case .denied, .restricted:
                requestForLocationPermission.accept(())
                let location = Constants.Location.defaultLocation
                currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

            default: break
            }
        }
    }

}
