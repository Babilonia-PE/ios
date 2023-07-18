//
//  FavoritesViewModel.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Core
import RxCocoa
import RxSwift

final class FavoritesViewModel {

    var requestState: Observable<RequestState> {
        return model.requestState.asObservable().observeOn(MainScheduler.instance)
    }
    var listingsUpdated: Observable<Void> {
        return model.listingsUpdated.asObservable()
    }
    var listings: [Listing] {
        model.listings.value
    }
    
    private let model: FavoritesModel
    
    init(model: FavoritesModel) {
        self.model = model
    }
    
    func fetchFavoritesListings() {
        model.fetchFavoritesListings()
    }

    func listingPreviewViewModel(at index: Int) -> ListingPreviewViewModel {
        let typeViewModel = ListingTypeViewModel(labelsAlignment: .vertical)
        let viewModel = ListingViewModel(listing: listings[index],
                                         configsService: model.configService,
                                         isUserOwnedListing: false)
        let photos = model.listings.value[index].sortedPhotos.map { ListingDetailsImage.remote($0) }

        return ListingPreviewViewModel(
            listingTypeViewModel: typeViewModel,
            listingViewModel: viewModel,
            isBottomButtonsHidden: true,
            photos: photos
        )
    }

    func deleteListingFromFavorite(at index: Int) {
        model.deleteListingFromFavorite(at: index)
    }

    func presentListingDetails(for index: Int) {
        model.presentListingDetails(for: index)
    }
    
}
