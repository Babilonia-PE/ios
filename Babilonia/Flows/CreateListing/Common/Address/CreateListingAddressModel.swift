//
//  CreateListingAddressModel.swift
//  Babilonia
//
//  Created by Denis on 6/11/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Core
import RxCocoa
import RxSwift
import CoreLocation.CLLocation

enum CreateListingAddressEvent: Event {
    case close
}

final class CreateListingAddressModel: EventNode {
    
    var addressUpdated: Driver<MapAddress?> { return address.asDriver() }
    var coordinateShownUpdated: Driver<CLLocationCoordinate2D?> { return coordinateShown.asDriver() }
    
    private let locationManager: LocationManager
    private let placeSearchManager: PlaceSearchManager
    private let configService: ConfigurationsService
    
    private let updateHandler: (MapAddress) -> Void
    private let address: BehaviorRelay<MapAddress?>
    private let coordinateShown: BehaviorRelay<CLLocationCoordinate2D?>
    
    // MARK: - lifecycle
    
    init(
        parent: EventNode,
        locationManager: LocationManager,
        configService: ConfigurationsService,
        updateHandler: @escaping (MapAddress) -> Void,
        initialAddress: MapAddress?
    ) {
        self.locationManager = locationManager
        self.configService = configService
        self.updateHandler = updateHandler
        self.coordinateShown = BehaviorRelay(value: initialAddress?.coordinate)
        self.address = BehaviorRelay(value: initialAddress)
        self.placeSearchManager = PlaceSearchManager()
        super.init(parent: parent)
    }
    
    func checkLocation() {
        setupLocationHandlers()
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.didChangeAuthorization = nil
            locationManager.updateCurrentLocation()
        case .denied, .restricted:
            let location = configService.appConfigs?.defaultLocation ?? Constants.Location.defaultLocation
            updateCoordinateShown(location)
            stopLocationHandlers()
        @unknown
        default:
            let location = configService.appConfigs?.defaultLocation ?? Constants.Location.defaultLocation
            updateCoordinateShown(location)
            stopLocationHandlers()
        }
    }
    
    func close() {
        raise(event: CreateListingAddressEvent.close)
    }
    
    func done() {
        if let address = address.value {
            updateHandler(address)
        }
        raise(event: CreateListingAddressEvent.close)
    }
    
    func updateLocation(_ location: CLLocationCoordinate2D) {
        locationManager.receiveTitle(for: location) { [weak self] title in
            guard let self = self else { return }
            self.updateMapAddress(location, title: title, showCoordinate: false)
        }
    }
    
    func updateMapAddress(_ coordinate: CLLocationCoordinate2D, title: String?, showCoordinate: Bool) {
        placeSearchManager
            .reverseGeocodeCoordinateToValues(coordinate) { [weak self] loc, province, admArea, country, postalCode in
                guard let self = self else { return }
                if showCoordinate {
                    self.coordinateShown.accept(coordinate)
                }
                var titleMap = title
                if let oldTitle = title {
                    if let first = oldTitle.split(separator: ",").first,
                       let department = admArea,
                       let district = loc {
                        titleMap = String(first) + ", \(district), \(department)"
                    }
                }
                let address = MapAddress(title: titleMap,
                                         coordinate: coordinate,
                                         country: country,
                                         department: admArea,
                                         province: province,
                                         district: loc,
                                         zipCode: postalCode)
                self.address.accept(address)
            }
    }
    
    // MARK: - private
    
    private func setupLocationHandlers() {
        locationManager.didChangeAuthorization = { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.updateCurrentLocation()
            case .denied, .restricted:
                let location = self.configService.appConfigs?.defaultLocation ?? Constants.Location.defaultLocation
                self.updateCoordinateShown(location)
                self.stopLocationHandlers()
            case .notDetermined:
                // skipping here because we're asking user to choose status
                break
            @unknown
            default:
                let location = self.configService.appConfigs?.defaultLocation ?? Constants.Location.defaultLocation
                self.updateCoordinateShown(location)
                self.stopLocationHandlers()
            }
        }
        locationManager.didUpdateLocations = { [weak self] locations in
            guard let self = self else { return }
            guard !locations.isEmpty else {
                let location = self.configService.appConfigs?.defaultLocation ?? Constants.Location.defaultLocation
                self.updateCoordinateShown(location)
                self.stopLocationHandlers()
                return
            }
            
            self.updateCoordinateShown(locations[0].coordinate)
            self.stopLocationHandlers()
        }
        locationManager.didFailWithError = { [weak self] _ in
            guard let self = self else { return }
            let location = self.configService.appConfigs?.defaultLocation ?? Constants.Location.defaultLocation
            self.updateCoordinateShown(location)
            self.stopLocationHandlers()
        }
    }
    
    private func stopLocationHandlers() {
        locationManager.didChangeAuthorization = nil
        locationManager.didUpdateLocations = nil
        locationManager.didFailWithError = nil
    }
    
    private func updateCoordinateShown(_ coordinate: CLLocationCoordinate2D) {
        if coordinateShown.value == nil {
            coordinateShown.accept(coordinate)
        }
    }
    
}
