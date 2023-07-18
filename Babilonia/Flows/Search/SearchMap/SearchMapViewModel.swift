//
//  SearchMapViewModel.swift
//  Babilonia
//
//  Created by Denis on 7/25/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Core
import CoreLocation.CLLocation

final class SearchMapViewModel {
    
    var requestState: Observable<RequestState> {
        return model.requestState.asObservable().observeOn(MainScheduler.instance)
    }
    var coordinateShownUpdated: Driver<CLLocationCoordinate2D?> {
        return model.coordinateShownUpdated
    }
    var searchResultCoordinate: CLLocationCoordinate2D? {
        model.searchResultCoordinate
    }

    var markerInfosUpdated: Driver<[(SearchMapMarkerInfo, CLLocationCoordinate2D)]> {
        return model.listingsUpdated.map {
            $0.compactMap { [weak self] in
                guard
                    let priceSettings = self?.model.configService.formatPrice($0.price ?? 0),
                    let info = SearchMapMarkerInfo(listing: $0,
                                                   price: priceSettings.code + ($0.price ?? 0).shortPriceFormatted()),
                    let location = $0.location
                else { return nil }
                return (
                    info,
                    CLLocationCoordinate2D(
                        latitude: CLLocationDegrees(location.latitude),
                        longitude: CLLocationDegrees(location.longitude)
                    )
                )
            }
        }
    }
    
    var shouldShowEmptyState: Driver<Bool> {
        return Driver.combineLatest(model.coordinateShownUpdated, model.listingsUpdated).map { $0 != nil && $1.isEmpty }
    }
    
    var configsService: ConfigurationsService { return model.configService }
    var shouldReloadOnAppear = false
    
    private let model: SearchMapModel
    
    // MARK: - lifecycle
    
    init(model: SearchMapModel) {
        self.model = model
    }

    func viewLoaded() {
        model.checkLocation()
    }
        
    func updateCoordinate(_ coordinate: CLLocationCoordinate2D) {
        model.updateCoordinate(coordinate)
    }
    
    func updateRadius(_ radius: CLLocationDistance) {
        model.updateRadius(radius)
    }
    
    func listing(with id: ListingId) -> Listing? {
        return model.listing(with: id)
    }

    func isUserOwnedListing(with userID: Int) -> Bool {
        model.isUserOwnedListing(with: userID)
    }

    func presentListingDetails(for listingID: Int) {
        model.presentListingDetails(for: listingID)
    }

    func setListingFavoriteState(for id: Int) {
        model.setListingFavoriteState(for: id)
    }

    func fetchListings() {
        model.fetchListings()
    }
    
}

private extension SearchMapMarkerInfo {
    
    init?(listing: Listing, price: String) {
        guard let propertyType = listing.propertyType else { return nil }
        self = SearchMapMarkerInfo(
            priceString: price,
            propertyType: propertyType,
            listingId: listing.id
        )
    }
    
}
