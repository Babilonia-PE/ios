//
//  SearchListModel.swift
//  Babilonia
//
//  Created by Denis on 7/25/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import RxCocoa
import RxSwift
import Core
import DBClient
import CoreLocation
import UIKit

protocol ListingsUpdatable: class {
    func updateListings(filters: ListingFilterModel)
    func updateListings(areaInfo: FetchListingsAreaInfo,
                        placeInfo: FetchListingsPlaceInfo,
                        isCurrentLocation: Bool)
}

private let defaultSearchRadius: Float = 5000

enum ListingDetailsPresentableEvent: Event {
    case presentListingDetails(listing: Listing)
}

final class SearchListModel: EventNode {

    enum ListingsType {
        case all, searchResult
    }
    
    let requestState = PublishSubject<RequestState>()
    var listingsUpdated = PublishSubject<[IndexPath]?>()

    var emptyStateNeeded: Driver<Bool> {
        Driver.combineLatest(
            listings.asDriver().map { $0.isEmpty }.skip(1).distinctUntilChanged(),
            topListings.asDriver().map { $0.isEmpty }.skip(1).distinctUntilChanged()
        ) { $0 && $1 }
    }
    var listingsCount: Int { return listings.value.count }
    var sortOptionValue: SortOption { return sortOption.value }
    var sortOptionTitle: Driver<String> { return sortOption.map { $0.title }.asDriver(onErrorJustReturn: "") }
    var requestForLocationPermission = BehaviorSubject<Void>(value: ())

    var topListingsViewUpdatable = BehaviorRelay(value: true)

    var showLocationPromptUpdated: Signal<Bool> {
        return showLocationPrompt.asSignal(onErrorJustReturn: false).debounce(.seconds(1))
    }
    let topListings = BehaviorRelay(value: [Listing]())
    let topListingsUpdated = PublishSubject<Void>()
    
    let configService: ConfigurationsService
    
    private var defaultLocation: CLLocationCoordinate2D {
        return configService.appConfigs?.defaultLocation ?? Constants.Location.defaultLocation
    }
    
    private var currentCoordinate: CLLocationCoordinate2D?
    private let sortOption: BehaviorRelay<SortOption>

    private let locationManager: LocationManager
    private let listingsService: ListingsService
    private let userService: UserService
    private let updateDefaulLocation: (() -> Void)
    
    private let listings = BehaviorRelay(value: [Listing]())
    private let showLocationPrompt = BehaviorRelay<Bool>(value: false)

    private let disposeBag = DisposeBag()
    private var locationPromptWasShown = false
    private var listingsType: ListingsType = .all
    private var searchAreaInfo: FetchListingsAreaInfo?
    private var filters: ListingFilterModel?
    private var shouldShowTopListings = true

    private let defaultPerPage = 25
    private var page = 1
    private var canFetchMore = false
    
    // MARK: - lifecycle
    
    init(parent: EventNode,
         locationManager: LocationManager,
         configService: ConfigurationsService,
         listingsService: ListingsService,
         userService: UserService,
         updateDefaulLocation: @escaping (() -> Void),
         sortOption: BehaviorRelay<SortOption>) {
        self.locationManager = locationManager
        self.configService = configService
        self.listingsService = listingsService
        self.userService = userService
        self.updateDefaulLocation = updateDefaulLocation
        self.sortOption = sortOption

        super.init(parent: parent)
        
        checkLocation()
    }

    func incrementPage() {
        let remainder = Double(listingsCount).truncatingRemainder(dividingBy: Double(defaultPerPage))
        guard canFetchMore, listingsCount >= defaultPerPage,
              (listingsCount / defaultPerPage) == page, remainder == 0 else { return }
        page += 1
        fetchListings()
    }

    private func calculateIndexPathsToReload(from newListings: [Listing]) -> [IndexPath] {
        let startIndex = listings.value.count - newListings.count
        let endIndex = startIndex + newListings.count

        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }

    func permissionNotGrantedYet() {
        setupInitialParamsAndFetch()
    }
        
    func listingModel(at index: Int, isTopListing: Bool) -> Listing {
        isTopListing ? topListings.value[index] : listings.value[index]
    }

    func isUserOwnedListing(at index: Int, isTopListing: Bool) -> Bool {
        let listing = isTopListing ? topListings.value[index] : listings.value[index]

        return listing.user.id == userService.userID
    }
    
    func listingImages(at index: Int, isTopListing: Bool) -> [ListingDetailsImage] {
        let listing = isTopListing ? topListings.value[index] : listings.value[index]

        return listing.sortedPhotos.map { ListingDetailsImage.remote($0) }
    }
    
    func setSortOption(with id: Int) {
        guard let option = SortOption(rawValue: id) else { return }

        checkForLocationPermission()
        sortOption.accept(option)
        fetchListings()
    }

    func presentListingDetails(for index: Int, isTopListing: Bool = false) {
        let listing = isTopListing ? topListings.value[index] : listings.value[index]
        raise(event: ListingDetailsPresentableEvent.presentListingDetails(listing: listing))
    }

    func setListingFavoriteState(at index: Int, isTopListing: Bool = false) {
        let listing = isTopListing ? topListings.value[index] : listings.value[index]
        let listingID = String(listing.id)

        requestState.onNext(.started)
        if listing.favourited {
            deleteListingFromFavorite(listingID: listingID)
        } else {
            addListingToFavorite(listingID: listingID)
        }
    }
    
    // MARK: - private

    private func addListingToFavorite(listingID: String) {
        listingsService.addListingToFavorite(listingID: listingID) { [weak self] result in
            switch result {
            case .success:
                self?.requestState.onNext(.finished)
                self?.fetchListings()
            case .failure(let error):
                self?.requestState.onNext(.failed(error))
            }
        }
    }

    private func deleteListingFromFavorite(listingID: String) {
        listingsService.deleteListingFromFavorite(listingID: listingID) { [weak self] result in
            switch result {
            case .success:
                self?.requestState.onNext(.finished)
                self?.fetchListings()
            case .failure(let error):
                self?.requestState.onNext(.failed(error))
            }
        }
    }
    
    private func setupInitialParamsAndFetch() {
        fetchListings()
    }

    func fetchListings(placeInfo: FetchListingsPlaceInfo? = nil,
                       shouldResetListings: Bool = false) {
        requestState.onNext(.started)

        if shouldShowTopListings {
            fetchTopListings()
        } else {
            topListingsViewUpdatable.accept(false)
        }
        
        let areaInfo = generateAreaInfo()
        listingsService.fetchAllListings(
            areaInfo: areaInfo,
            sort: sortOptionValue.sortParam,
            direction: sortOptionValue.directionParam,
            filters: filters,
            placeInfo: placeInfo,
            page: page
        ) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let listings):
                    self.requestState.onNext(.finished)

                    self.canFetchMore = listings.count == self.defaultPerPage
                    if self.page > 1 {
                        var fetchedListings = self.listings.value
                        let indexPathsToReload = self.calculateIndexPathsToReload(from: listings)
                        if self.shouldAppendListings(listings) {
                            self.listings.accept(fetchedListings + listings)
                        } else {
                            if let first = indexPathsToReload.first,
                               let last = indexPathsToReload.last, last.row < fetchedListings.count {
                                fetchedListings.replaceSubrange(first.row...last.row, with: listings)
                            }
                            self.listings.accept(fetchedListings)
                        }
                        self.listingsUpdated.onNext(indexPathsToReload)
                    } else {
                        self.listings.accept(listings)
                        self.listingsUpdated.onNext(nil)
                    }

                case .failure(let error):
                    self.requestState.onNext(.failed(error))
                    self.topListingsViewUpdatable.accept(false)
                }
        }
    }

    func generateAreaInfo() -> FetchListingsAreaInfo? {
        switch (listingsType, searchAreaInfo) {
        case (.searchResult, let areaInfo):
            return areaInfo

        default:
            var area: FetchListingsAreaInfo?
            if let coordinate = currentCoordinate {
                area = FetchListingsAreaInfo(latitude: Float(coordinate.latitude),
                                             longitude: Float(coordinate.longitude),
                                             radius: defaultSearchRadius)

                return area
            } else {
                area = FetchListingsAreaInfo(latitude: Float(defaultLocation.latitude),
                                             longitude: Float(defaultLocation.longitude),
                                             radius: defaultSearchRadius)

                return area
            }
        }
    }

    private func fetchTopListings() {
        let areaInfo = generateAreaInfo()
        listingsService.getTopListings(areaInfo: areaInfo) { [weak self] result in
            switch result {
            case .success(let listings):
                self?.topListings.accept(listings)
                self?.topListingsViewUpdatable.accept(!listings.isEmpty)
                self?.topListingsUpdated.onNext(())

            case .failure:
                self?.topListingsViewUpdatable.accept(false)
            }
        }
    }

    private func resetPagination(shouldShowTopListings: Bool = false) {
        canFetchMore = true
        page = 1
        self.shouldShowTopListings = shouldShowTopListings
        topListings.accept([])
    }

    private func shouldAppendListings(_ newListings: [Listing]) -> Bool {
        let newListingsIDs = newListings.map { $0.id }
        let listingsIDs = listings.value.map { $0.id }
        let uniqueIDs = Set(newListingsIDs + listingsIDs).count

        return uniqueIDs == (newListingsIDs + listingsIDs).count
    }
    
}

// MARK: - Location setup & updating

extension SearchListModel {

    func checkForLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            requestForLocationPermission.onNext(())
        default: break
        }
    }

    func checkLocation() {
        if !locationPromptWasShown, case .notDetermined = locationManager.authorizationStatus {
            locationPromptWasShown = true
            showLocationPrompt.accept(true)
            return
        }

        setupLocationHandlers()
        handleLocationAuthStatus(status: locationManager.authorizationStatus)
    }

    private func stopLocationHandlers() {
        locationManager.didChangeAuthorization = nil
        locationManager.didUpdateLocations = nil
        locationManager.didFailWithError = nil
    }

    private func setupLocationHandlers() {
        locationManager.didChangeAuthorization = { [weak self] status in
            self?.handleLocationAuthStatus(status: status)
        }

        locationManager.didUpdateLocations = { [weak self] locations in
            guard let self = self else { return }

            if !locations.isEmpty {
                self.currentCoordinate = locations[0].coordinate
            }

            self.stopLocationHandlers()
            self.setupInitialParamsAndFetch()
        }

        locationManager.didFailWithError = { [weak self] _ in
            guard let self = self else { return }
            self.stopLocationHandlers()
        }
    }

    private func handleLocationAuthStatus(status: CLAuthorizationStatus) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.didChangeAuthorization = nil
            locationManager.updateCurrentLocation()

        case .denied, .restricted:
            setupInitialParamsAndFetch()
            updateDefaulLocation()

        @unknown
        default:
            stopLocationHandlers()
        }
    }

}

// MARK: - ListingsUpdatable

extension SearchListModel: ListingsUpdatable {

    func updateListings(areaInfo: FetchListingsAreaInfo,
                        placeInfo: FetchListingsPlaceInfo,
                        isCurrentLocation: Bool) {
        listingsType = .searchResult
        searchAreaInfo = areaInfo
        filters?.areaInfo = areaInfo
        resetPagination(shouldShowTopListings: isCurrentLocation && filters == nil)
        fetchListings(placeInfo: placeInfo, shouldResetListings: true)
    }

    func updateListings(filters: ListingFilterModel) {
        self.filters = filters
        if let areaInfo = searchAreaInfo {
            self.filters?.areaInfo = areaInfo
        }
        resetPagination()
        fetchListings(shouldResetListings: true)
    }

}
