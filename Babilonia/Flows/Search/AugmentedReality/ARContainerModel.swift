//
//  ARContainerModel.swift
//  Babilonia
//
//  Created by Vitaly Chernysh on 7/17/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Core
import CoreLocation

typealias ListingId = Core.ListingId
typealias CLHeading = CoreLocation.CLHeading
typealias CLLocation = CoreLocation.CLLocation
typealias CLLocationCoordinate2D = CoreLocation.CLLocationCoordinate2D

enum ARModelEvent: Event {
    case didRequestClosing
}

final class ARContainerModel: EventNode {
    
    var currentLocation: CLLocation? {
        locationManager.currentLocation
    }
    var destinationLocation: CLLocation? {
        guard let coordinate = destinationCoordinate else { return nil }

        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    let listings = BehaviorRelay(value: [Listing]())
    let requestState = PublishSubject<RequestState>()
    let requestFetchingUpdates = PublishSubject<Void>()
    let arrivalToDestinationUpdates = PublishSubject<Void>()
    let routePoints = PublishSubject<String?>()
    let heading: BehaviorRelay<CLHeading?> = BehaviorRelay(value: nil)

    var shouldShowCameraAlert: Bool {
        get { appSettingsStore.cameraAlertDidShow }
        set { appSettingsStore.cameraAlertDidShow = newValue }
    }
    
    let configsService: ConfigurationsService
    private let listingsService: ListingsService
    private let userService: UserService
    private let locationManager: LocationManager
    private let directionsService = MapDirectionsService()
    private let appSettingsStore: AppSettingsStore = UserDefaults()

    private var lastFetchedCenterCoordinate: CLLocationCoordinate2D?
    private var destinationCoordinate: CLLocationCoordinate2D?
    
    /// Represents a distance in `meters` from user's current location to supreme margin where Listing could be located.
    private let initialListingDisplayRadius: Float = 500.0
    private let listingFetchingRadius: Float = 700.0
    
    /// Represents a distance in `meters` from user's current location to supreme margin where the next fetching request
    /// should be called (request would fetch Listings for next 2000 meters from user's current location).
    private let minimumDistanceForListingsFetching: Double = 400.0
    
    /// Represents a minimum distance in `meters` from user's current location to destination's location when
    /// `arrivalToDestination` gets fired.
    private let minimumMetersToDestination: Double = 10.0
    private var isListingsPreloaded = false
    private var prefetchedListings = [Listing]()
    
    init(
        parent: EventNode,
        listingsService: ListingsService,
        locationManager: LocationManager,
        configsService: ConfigurationsService,
        userService: UserService
    ) {
        self.listingsService = listingsService
        self.locationManager = locationManager
        self.configsService = configsService
        self.userService = userService

        super.init(parent: parent)

        setupLocationManager()
    }
    
    ///
    /// Sets the internal paramter `destinationCoordinate: CLLocationCoordinate2D` equal to `coordinate` parameter.
    /// When `destinationCoordinate` is present, locationManager tracks the distance to it and fires a signal
    /// when the distance between user's current position and destination's position is less than or equal 30 meters.
    ///
    /// Important: - Once destination is reached or user has quit from navigation mode, you have to
    /// reset `destinationCoordinate` to `nil` by yourself.
    /// Just use `setDestination(with: nil)` to reset the destination and prevent tracking logic to fire any unwanted
    /// events.
    ///
    func setDestination(with coordinate: CLLocationCoordinate2D?) {
        self.destinationCoordinate = coordinate
    }
    
    func fetchListings() {
        guard let centerCoordinate = currentLocation?.coordinate else { return }

        let areaInfo = FetchListingsAreaInfo(
            latitude: Float(centerCoordinate.latitude),
            longitude: Float(centerCoordinate.longitude),
            radius: listingFetchingRadius
        )

        if isListingsPreloaded { listings.accept(prefetchedListings) }

        requestState.onNext(.started)
        listingsService.fetchAllListings(areaInfo: areaInfo, sort: nil, direction: nil) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let listings):
                self.lastFetchedCenterCoordinate = centerCoordinate
                self.requestState.onNext(.finished)
                if self.isListingsPreloaded {
                    self.listings.accept(listings)
                } else {
                    self.prefetchedListings = listings
                    self.listings.accept(self.filterInitialListings(listings))
                }

                self.isListingsPreloaded = true

            case .failure(let error):
                self.requestState.onNext(.failed(error))
            }
        }
    }

    private func filterInitialListings(_ listings: [Listing]) -> [Listing] {
        listings.filter { [weak self] listing in
            guard let self = self,
                  let location = listing.location,
                  let centerCoordinate = self.lastFetchedCenterCoordinate else { return false }

            let cllocation = CLLocation(latitude: CLLocationDegrees(location.latitude),
                                        longitude: CLLocationDegrees(location.longitude))

            let distance = CLLocation(latitude: centerCoordinate.latitude,
                                      longitude: centerCoordinate.longitude).distance(from: cllocation)

            return distance <= Double(self.initialListingDisplayRadius)
        }
    }

    func startHeadingUpdates() {
        locationManager.setHeadingUpdatesEnabled(true)
    }

    func shouldShowContact(for listing: Listing) -> Bool {
        guard let location = listing.location else { return false }

        let cllocation = CLLocation(latitude: CLLocationDegrees(location.latitude),
                                    longitude: CLLocationDegrees(location.longitude))
        let distance = currentLocation?.distance(from: cllocation)

        if let distance = distance {
            
            return (distance <= minimumMetersToDestination)
        }

        return false
    }
    
    func close() {
        raise(event: ARModelEvent.didRequestClosing)
    }

    func presentListingDetails(for listing: Listing) {
        raise(event: ListingDetailsPresentableEvent.presentListingDetails(listing: listing))
    }

    func isUserOwnedListing(with userID: Int) -> Bool {
        userID == userService.userID
    }

    func addListingToFavorites(listingID: String) {
        requestState.onNext(.started)
        listingsService.addListingToFavorite(listingID: listingID) { [weak self] result in
            switch result {
            case .success:
                self?.requestState.onNext(.finished)

            case .failure(let error):
                self?.requestState.onNext(.failed(error))
            }
        }
    }

    func removeListingFromFavorites(listingID: String) {
        requestState.onNext(.started)
        listingsService.deleteListingFromFavorite(listingID: listingID) { [weak self] result in
            switch result {
            case .success:
                self?.requestState.onNext(.finished)

            case .failure(let error):
                self?.requestState.onNext(.failed(error))
            }
        }
    }

    func getDirections(sourceCoordinate: CLLocationCoordinate2D,
                       destinationCoordinate: CLLocationCoordinate2D) {
        directionsService.getRoute(sourceCoordinate: sourceCoordinate,
                                   destinationCoordinate: destinationCoordinate) { [weak self] result in
            switch result {
            case .success(let points):
                self?.routePoints.onNext(points)

            case .failure:
                self?.routePoints.onNext(nil)
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.setLocationUpdatesEnabled(true)

        locationManager.didUpdateLocations = { [weak self] locations in
            guard let self = self,
                  let updatedLocation = locations.first,
                  let lastFetchedCoordinate = self.lastFetchedCenterCoordinate else { return }

            let lastFetchedLocation = CLLocation(
                latitude: lastFetchedCoordinate.latitude,
                longitude: lastFetchedCoordinate.longitude
            )
            
            let distance = lastFetchedLocation.distance(from: updatedLocation)
            if distance >= self.minimumDistanceForListingsFetching {
                self.requestFetchingUpdates.onNext(())
            }
            
            if let destinationCoordinate = self.destinationCoordinate {
                let destinationLocation = CLLocation(
                    latitude: destinationCoordinate.latitude,
                    longitude: destinationCoordinate.longitude
                )
                
                let distanceToDestination = updatedLocation.distance(from: destinationLocation)
                if distanceToDestination <= self.minimumMetersToDestination {
                    self.arrivalToDestinationUpdates.onNext(())
                }
            }
        }

        locationManager.didUpdateHeading = { [weak self] heading in
            self?.heading.accept(heading)
        }
    }

}
