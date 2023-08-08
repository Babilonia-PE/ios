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
    
    case updateListingsBy(searchLocation: SearchLocation,
                          isCurrentLocation: Bool)
}

final class LocationSearchModel: EventNode {

    let requestState = PublishSubject<RequestState>()
    var currentLocation = BehaviorRelay<String?>(value: nil)
    var locations = BehaviorRelay<[SearchLocation]>(value: [])
    
    var recentSearches = BehaviorRelay<[RecentSearch]>(value: [])
    var requestForLocationPermission = BehaviorSubject<Void>(value: ())
    var isCurrentLocationSearch = false
    var isCurrentAutoCompleteLocationSearch = false

    var searchTerm: String
    private let locationManager: LocationManager
    private let placeSearchManager: PlaceSearchManager
    private let autoCompleteSearchService: AutoCompleteSearchService
    private let userService: UserService

    private let defaultRadius = 2000 // 1000 // 5000

    init(parent: EventNode,
         searchTerm: String,
         locationManager: LocationManager,
         userService: UserService,
         autoCompleteSearchService: AutoCompleteSearchService,
         isCurrentLocationSearch: Bool) {
        self.searchTerm = searchTerm
        self.locationManager = locationManager
        self.placeSearchManager = PlaceSearchManager()
        self.userService = userService
        self.autoCompleteSearchService = autoCompleteSearchService
        self.isCurrentLocationSearch = isCurrentLocationSearch

        super.init(parent: parent)
    }

    func requestCurrentLocation() {
        RecentLocation.shared.currentLocation = nil
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
        
        autoCompleteSearchService.fetchSearchLocations(address: term) { [weak self] result in
            switch result {
            case .success(let autoComplete):
                self?.locations.accept(autoComplete.map { $0.toSearchLocation() })
            case .failure:
                break
             //   self?.requestState.onNext(.failed(error))
            }
        }
        /*
        placeSearchManager.placeAutocomplete(term: term) { [weak self] locations in
            self?.locations.accept(locations)
        }
 */
    }

    func proccedSearch(with term: String) {
        
        guard let location = RecentLocation.shared.locations.first(where: { $0.addressField == term }) else {
            
            return
        }
        self.updateListingsBy(for: location)
        
        return
        
//        placeSearchManager.placeAutocomplete(term: term) { [weak self] locations in
//            guard let self = self else { return }
//            guard let location = locations.first else {
//                self.raise(event: LocationSearchEvent.updateListings(areaInfo: FetchListingsAreaInfo.empty,
//                                                                     placeInfo: FetchListingsPlaceInfo.empty,
//                                                                     isCurrentLocation: false))
//
//                return
//            }
//
//            self.generateAreaInfo(for: location.placeID)
//        }
    }

    func updateListingsWithAddress(at index: Int, isRecentSearches: Bool) {
        if isRecentSearches {
            guard index < recentSearches.value.count else { return }
            guard let searchLocation = recentSearches.value[index].location?.toSearchLocation() else {
                return
            }
            RecentLocation.shared.currentLocation = searchLocation
            RecentLocation.shared.mapCenter = false
            updateListingsBy(for: searchLocation)
        } else {
            guard index < locations.value.count else { return }
            RecentLocation.shared.locations = Array(locations.value)
            let searchLocation = locations.value[index]
            RecentLocation.shared.currentLocation = searchLocation
            RecentLocation.shared.mapCenter = false
            updateListingsBy(for: searchLocation)
        }
    }

    func fetchRecentSearches() {
        if userService.userID != .guest {
            requestState.onNext(.started)
            userService.fetchRecentSearches { [weak self] result in
                switch result {
                case .success(let searches):
                    self?.requestState.onNext(.finished)
                    
                    self?.recentSearches.accept(searches.filter { $0.location != nil }) // osemy
                case .failure(let error):
                    
                    self?.requestState.onNext(.failed(error))
                }
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
    
    private func updateListingsBy(for searchLocation: SearchLocation) {
        self.raise(event:
                    LocationSearchEvent.updateListingsBy(searchLocation: searchLocation,
                                                               isCurrentLocation: false))
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
