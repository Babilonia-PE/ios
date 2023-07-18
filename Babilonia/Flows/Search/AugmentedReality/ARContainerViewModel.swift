//
//  ARContainerViewModel.swift
//  Babilonia
//
//  Created by Vitaly Chernysh on 7/17/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Core

final class ARContainerViewModel {
    
    var headingUpdates: Observable<CLHeading?> {
        model.heading.asObservable()
    }
    var requestState: Observable<RequestState> {
        model.requestState.asObservable().observeOn(MainScheduler.instance)
    }
    var arrivalToDestinationUpdates: Observable<Void> {
        model.arrivalToDestinationUpdates.asObservable().observeOn(MainScheduler.instance)
    }
    var requestFetchingUpdates: Observable<Void> {
        model.requestFetchingUpdates.asObservable().observeOn(MainScheduler.instance)
    }
    var listings: BehaviorRelay<[Listing]> {
        model.listings
    }
    var routePoints: Observable<String?> {
        model.routePoints.asObservable()
    }
    var configsService: ConfigurationsService {
        model.configsService
    }
    var currentLocation: CLLocation? {
        model.currentLocation
    }
    var destinationReachedTitle: String {
        L10n.Ar.DestinationReached.title
    }
    var navigationDistinationLocation: CLLocation? {
        model.destinationLocation
    }
    var shouldShowCameraAlert: Bool {
        get { model.shouldShowCameraAlert }
        set { model.shouldShowCameraAlert = newValue }
    }

    private let model: ARContainerModel
    
    init(model: ARContainerModel) {
        self.model = model
    }

    func fetchListings() {
        model.fetchListings()
    }

    func isUserOwnedListing(with userID: Int) -> Bool {
        model.isUserOwnedListing(with: userID)
    }
    
    func setDestination(with coordinate: CLLocationCoordinate2D?) {
        model.setDestination(with: coordinate)
    }

    func startHeadingUpdates() {
        model.startHeadingUpdates()
    }

    func shouldShowContact(for listing: Listing) -> Bool {
        model.shouldShowContact(for: listing)
    }

    func close() {
        model.close()
    }

    func presentListingDetails(for listing: Listing) {
        model.presentListingDetails(for: listing)
    }

    func addListingToFavorites(listingID: String) {
        model.addListingToFavorites(listingID: listingID)
    }

    func removeListingFromFavorites(listingID: String) {
        model.removeListingFromFavorites(listingID: listingID)
    }

    func getDirections(sourceCoordinate: CLLocationCoordinate2D,
                       destinationCoordinate: CLLocationCoordinate2D) {
        model.getDirections(sourceCoordinate: sourceCoordinate,
                                   destinationCoordinate: destinationCoordinate)
    }

}
