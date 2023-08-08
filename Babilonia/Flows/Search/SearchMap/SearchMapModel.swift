//
//  SearchMapModel.swift
//  Babilonia
//
//  Created by Denis on 7/25/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Core
import CoreLocation.CLLocation
import RxSwift
import RxCocoa

final class SearchMapModel: EventNode, ListingsUpdatable {
    private let defaultRadius: Float = 2000 // 1000 // 5000
    let requestState = PublishSubject<RequestState>()
    
    var coordinateShownUpdated: Driver<CLLocationCoordinate2D?> { return coordinateShown.asDriver() }
    var listingsUpdated: Driver<[Listing]> { return listings.asDriver() }
    var moveToListingUpdated: Driver<Bool> { return moveToListing.asDriver() }

    var searchResultCoordinate: CLLocationCoordinate2D?
    
    let configService: ConfigurationsService
    
    private let coordinateShown = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)
    private let radiusShown = BehaviorRelay<CLLocationDistance?>(value: nil)
    private var filters: ListingFilterModel?
    private let updateFoundListingsCount: PublishSubject<ListingFilterModel?>
    
    private let listings = BehaviorRelay<[Listing]>(value: [])
    private let sortOption: BehaviorRelay<SortOption>
    private let moveToListing = BehaviorRelay<Bool>(value: false)

    private let locationManager: LocationManager
    private let listingsService: ListingsService
    private let userService: UserService
    private let disposeBag = DisposeBag()
    private let maxListingsCount = 50
    private var isCallService = false
    private var listingByList: Listing?
    // MARK: - lifecycle
    
    deinit {
        configService.removeObserver(self)
    }
    
    init(parent: EventNode,
         locationManager: LocationManager,
         configService: ConfigurationsService,
         listingsService: ListingsService,
         userService: UserService,
         sortOption: BehaviorRelay<SortOption>,
         updateFoundListingsCount: PublishSubject<ListingFilterModel?>) {
        self.locationManager = locationManager
        self.configService = configService
        self.listingsService = listingsService
        self.userService = userService
        self.sortOption = sortOption
        self.updateFoundListingsCount = updateFoundListingsCount

        super.init(parent: parent)
        
        configService.addObserver(self)
        setupBindings()
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
        
    func updateCoordinate(_ coordinate: CLLocationCoordinate2D) {
        coordinateShown.accept(coordinate)
    }
    
    func updateRadius(_ radius: CLLocationDistance) {
        radiusShown.accept(radius)
    }

    func currentCoordinateShown() -> CLLocationCoordinate2D? {
        coordinateShown.value
    }
    
    public func firstListing() -> Listing? {
        listings.value.first
    }
    
    func listing(with id: ListingId) -> Listing? {
        return listings.value.first { $0.id == id }
    }

    func isUserOwnedListing(with userID: Int) -> Bool {
        userID == userService.userID
    }
    
    func updateListingByList(listing: Listing?) {
        listingByList = listing
    }
    
    func currentListingByList() -> Listing? {
        listingByList
    }

    func updateListings(areaInfo: FetchListingsAreaInfo,
                        placeInfo: FetchListingsPlaceInfo,
                        isCurrentLocation: Bool) {
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(areaInfo.latitude),
                                                longitude: CLLocationDegrees(areaInfo.longitude))
        searchResultCoordinate = coordinate
        fetchListings(areaInfo: areaInfo)
        updateCoordinate(coordinate)
    }

    func updateListings(filters: ListingFilterModel) {
        self.filters = filters
        fetchListings()
    }
    
    func updateListings(searchLocation: SearchLocation, isCurrentLocation: Bool) {
        fetchListings(searchLocation: searchLocation)
    }

    func presentListingDetails(for listingID: Int) {
        guard let listing = listings.value.first(where: { $0.id == listingID }) else { return }
        raise(event: ListingDetailsPresentableEvent.presentListingDetails(listing: listing))
    }
    
    func setListingFavoriteState(for id: Int) {
        if userService.userID == .guest {
            raise(event: ListingDetailsPresentableEvent.alertGuest)
        } else {
            guard let listing = listings.value.first(where: { $0.id == id }) else { return }

            requestState.onNext(.started)
            let favorited = listing.favourited ?? false
            if favorited {
                deleteListingFromFavorite(listingID: String(id))
            } else {
                addListingToFavorite(listingID: String(id))
            }
        }
    }

    // MARK: - private

    private func addListingToFavorite(listingID: String) {
        listingsService.addListingToFavorite(listingID: listingID,
                                             ipAddress: NetworkUtil.getWiFiAddress() ?? "",
                                             userAgent: "ios",
                                             signProvider: "email") { [weak self] result in
            switch result {
            case .success:
                self?.requestState.onNext(.finished)
                self?.fetchListings()
            case .failure(let error):
                if self?.isUnauthenticated(error) == true {
                    self?.raise(event: MainFlowEvent.logout)
                } else {
                    self?.requestState.onNext(.failed(error))
                }
            }
        }
    }

    private func deleteListingFromFavorite(listingID: String) {
        listingsService.deleteListingFromFavorite(listingID: listingID,
                                                  ipAddress: NetworkUtil.getWiFiAddress() ?? "",
                                                  userAgent: "ios",
                                                  signProvider: "email") { [weak self] result in
            switch result {
            case .success:
                self?.requestState.onNext(.finished)
                self?.fetchListings()
            case .failure(let error):
                if self?.isUnauthenticated(error) == true {
                    self?.raise(event: MainFlowEvent.logout)
                } else {
                    self?.requestState.onNext(.failed(error))
                }
            }
        }
    }
    
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
            case .notDetermined: break
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
    
    private func setupBindings() {
        Driver
            .combineLatest(
                coordinateShown.asDriver().distinctUntilChanged {
                    $0?.latitude == $1?.latitude && $0?.longitude == $1?.longitude
                },
                radiusShown.asDriver().distinctUntilChanged()
            )
            .debounce(.seconds(1))
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.filters?.areaInfo = self.calculateAreaInfo()
                self.fetchListings()
                self.updateFoundListingsCount.onNext(self.filters)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchListings(areaInfo: FetchListingsAreaInfo? = nil) {
    //    RecentLocation.shared.currentLocation = nil 
        requestState.onNext(.started)

        var areaInfo: FetchListingsAreaInfo?

        if let info = areaInfo {
            areaInfo = info
        } else {
            areaInfo = calculateAreaInfo() 
        }

        listingsService.fetchAllListings(areaInfo: areaInfo,
                                         sort: sortOption.value.sortParam,
                                         direction: sortOption.value.directionParam,
                                         filters: filters,
                                         perPage: maxListingsCount) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let listings):
                self.requestState.onNext(.finished)
                self.isCallService = true
                self.listings.accept(listings)
            case .failure(let error):
                if self.isUnauthenticated(error) {
                    self.raise(event: MainFlowEvent.logout)
                } else {
                    self.requestState.onNext(.failed(error))
                }
            }
        }
    }
    
    func fetchListings(searchLocation: SearchLocation) {
   //     RecentLocation.shared.currentLocation = searchLocation
        requestState.onNext(.started)
        listingsService.fetchAllListings(searchLocation: searchLocation,
                                         sort: sortOption.value.sortParam,
                                         direction: sortOption.value.directionParam,
                                         filters: filters,
                                         perPage: maxListingsCount) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let listings):
                
                self.requestState.onNext(.finished)
                self.listings.accept(listings)
                self.moveToListing.accept(true)
            case .failure(let error):
                if self.isUnauthenticated(error) {
                    self.raise(event: MainFlowEvent.logout)
                } else {
                    self.requestState.onNext(.failed(error))
                }
            }
            
        }
    }
    
    private func calculateAreaInfo() -> FetchListingsAreaInfo? {
        FetchListingsAreaInfo(latitude: Float(coordinateShown.value?.latitude ?? 0.0),
                              longitude: Float(coordinateShown.value?.longitude ?? 0.0),
                              radius: defaultRadius)
             //                 radius: Float(radiusShown.value ?? 0.0))
    }
    
    private func isUnauthenticated(_ error: Error?) -> Bool {
        guard let serverError = error as? CompositeServerError,
              let code = serverError.errors.first?.code else { return false }
        
        return code == .unauthenticated
    }
    
}

extension SearchMapModel: CurrencyObserver {
    
    func currencyChanged(_ currency: Currency) {
        let objects = listings.value
        listings.accept(objects)
    }
    
}
