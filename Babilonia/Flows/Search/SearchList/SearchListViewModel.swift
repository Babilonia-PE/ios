//
//  SearchListViewModel.swift
//  Babilonia
//
//  Created by Denis on 7/25/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchListViewModel {
    
    var requestState: Observable<RequestState> {
        model.requestState.asObservable().observeOn(MainScheduler.instance)
    }
    var listingsUpdated: Observable<[IndexPath]?> { model.listingsUpdated.asObservable() }
    var emptyStateNeeded: Driver<Bool> { model.emptyStateNeeded }
    var listingsCount: Int { model.listingsCount }
    var sortOptionTitle: Driver<String> { model.sortOptionTitle }
    var sortOptionValue: SortOption { model.sortOptionValue }
    var showLocationPromptUpdated: Signal<Bool> { model.showLocationPromptUpdated }
    var shouldReloadOnAppear = false
    var requestForLocationPermissionObservable: Observable<Void> {
        model.requestForLocationPermission.asObservable()
    }
    var topListingsViewUpdatable: Observable<Void> {
        model.topListingsViewUpdatable.map { _ in Void() }.asObservable()
    }

    var shouldShowTopListings: Bool {
        model.topListingsViewUpdatable.value
    }

    var topListingsUpdated: Observable<Void> {
        model.topListingsUpdated.asObservable()
    }
    var topListings: [Listing] {
        model.topListings.value
    }
    
    private let model: SearchListModel
    private var listingsDisposeBag = DisposeBag()
    
    // MARK: - lifecycle
    
    init(model: SearchListModel) {
        self.model = model
    }

    func incrementPage() {
        model.incrementPage()
    }
    
    func setSortOption(with id: Int) {
        model.setSortOption(with: id)
    }
    
    func acceptedLocationRequest() {
        model.checkLocation()
    }
    
    func permissionNotGrantedYet() {
        model.permissionNotGrantedYet()
    }
    
    func listingPreviewViewModel(at index: Int, isTopListing: Bool = false) -> ListingPreviewViewModel {
        let typeViewModel = ListingTypeViewModel(labelsAlignment: .vertical)
        let listing = model.listingModel(at: index, isTopListing: isTopListing)

        let viewModel = ListingViewModel(listing: listing,
                                         configsService: model.configService,
                                         isUserOwnedListing: model.isUserOwnedListing(at: index,
                                                                                      isTopListing: isTopListing))
        let photos = model.listingImages(at: index, isTopListing: isTopListing)
        
        return ListingPreviewViewModel(
            listingTypeViewModel: typeViewModel,
            listingViewModel: viewModel,
            isBottomButtonsHidden: true,
            photos: photos
        )
    }

    func presentListingDetails(for index: Int, isTopListing: Bool = false) {
        model.presentListingDetails(for: index, isTopListing: isTopListing)
    }

    func setListingFavoriteState(at index: Int, isTopListing: Bool = false) {
        model.setListingFavoriteState(at: index, isTopListing: isTopListing)
    }

    func fetchListings() {
        model.fetchListings()
    }

}
