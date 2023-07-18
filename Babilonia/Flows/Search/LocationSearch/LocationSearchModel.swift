//
//  LocationSearchModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 17.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Core
import RxSwift
import RxCocoa

enum LocationSearchEvent: Event {
    case updateListings(areaInfo: FetchListingsAreaInfo,
                        placeInfo: FetchListingsPlaceInfo,
                        isCurrentLocation: Bool)
}

final class LocationSearchModel: EventNode {

    let requestState = PublishSubject<RequestState>()
    var currentLocation = BehaviorRelay<String?>(value: nil)
    var locations = BehaviorRelay<[SearchLocations]>(value: [])
    var recentSearches = BehaviorRelay<[RecentSearch]>(value: [])
    var requestForLocationPermission = BehaviorSubject<Void>(value: ())
    var isCurrentLocationSearch = false

    var searchTerm: String
    private let locationManager: LocationManager
    private let placeSearchManager: PlaceSearchManager
    private let userService: UserService

    private let defaultRadius = 5000

    init(parent: EventNode,
         searchTerm: String,
         locationManager: LocationManager,
         userService: UserService,
         isCurrentLocationSearch: Bool) {
        self.searchTerm = searchTerm
        self.locationManager = locationManager
        self.placeSearchManager = PlaceSearchManager()
        self.userService = userService
        self.isCurrentLocationSearch = isCurrentLocationSearch

        super.init(parent: parent)
    }

    func requestCurrentLocation() {
        if locationManager.authorizationStatusIsGranted {
            guard let coordinate = locationManager.currentLocation?.coordinate else { return }

            locationManager.receiveTitle(for: coordinate) { [weak self] title in
                self?.currentLocation.accept(title)
                self?.submitCurrentLocation(address: title, coordinate: coordinate)
            }
        } else {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()

            case .denied, .restricted:
                requestForLocationPermission.onNext(())

            default: break
            }
        }
    }

    func searchLocations(with term: String) {
        placeSearchManager.placeAutocomplete(term: term) { [weak self] locations in
            self?.locations.accept(locations)
        }
    }

    func proccedSearch(with term: String) {
        placeSearchManager.placeAutocomplete(term: term) { [weak self] locations in
            guard let self = self else { return }
            guard let location = locations.first else {
                self.raise(event: LocationSearchEvent.updateListings(areaInfo: FetchListingsAreaInfo.empty,
                                                                     placeInfo: FetchListingsPlaceInfo.empty,
                                                                     isCurrentLocation: false))

                return
            }

            self.generateAreaInfo(for: location.placeID)
        }
    }

    func updateListingsWithAddress(at index: Int, isRecentSearches: Bool) {
        var placeID: String
        if isRecentSearches {
            guard index < recentSearches.value.count else { return }
            if let id = recentSearches.value[index].googlePlacesLocationId {
                placeID = id
                generateAreaInfo(for: placeID)
            } else {
                let term = recentSearches.value[index].queryString
                placeSearchManager.placeAutocomplete(term: term) { [weak self] locations in
                    guard let id = locations.first?.placeID else { return }
                    self?.generateAreaInfo(for: id)
                }
            }
        } else {
            guard index < locations.value.count else { return }
            placeID = locations.value[index].placeID
            generateAreaInfo(for: placeID)
        }
    }

    func fetchRecentSearches() {
        requestState.onNext(.started)
        userService.fetchRecentSearches { [weak self] result in
            switch result {
            case .success(let searches):
                self?.requestState.onNext(.finished)
                self?.recentSearches.accept(searches)
            case .failure(let error):
                self?.requestState.onNext(.failed(error))
            }
        }
    }

    private func generateAreaInfo(for placeID: String) {
        placeSearchManager.generateAreaInfo(for: placeID) { [weak self] areaInfo, address in
            guard let self = self else { return }
            if var areaInfo = areaInfo {
                let radius = areaInfo.radius
                areaInfo.radius = radius

                let placeInfo = FetchListingsPlaceInfo(searchPlace: address ?? "", placeID: placeID)
                self.raise(event: LocationSearchEvent.updateListings(areaInfo: areaInfo,
                                                                     placeInfo: placeInfo,
                                                                     isCurrentLocation: false))
            }
        }
    }

    private func submitCurrentLocation(address: String?, coordinate: CLLocationCoordinate2D) {
        let placeInfo = FetchListingsPlaceInfo(searchPlace: address ?? "", placeID: "")
        let areaInfo = FetchListingsAreaInfo(latitude: Float(coordinate.latitude),
                                             longitude: Float(coordinate.longitude),
                                             radius: Float(defaultRadius))
        raise(event: LocationSearchEvent.updateListings(areaInfo: areaInfo,
                                                        placeInfo: placeInfo,
                                                        isCurrentLocation: true))
    }

}
