//
//  ListingDetailsModel.swift
//  Babilonia
//
//  Created by Denis on 7/11/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Core
import RxSwift
import RxCocoa

typealias Listing = Core.Listing

enum ListingDetailsEvent: Event {
    case showDescription(String)
    case showMap(location: Location, propertyType: PropertyType?)
    case showPhotoGallery(config: ListingDetailsModelConfig)
}

enum ListingDetailsModelConfig {
    case local(listing: Listing, photos: [CreateListingPhoto])
    case remote(listingId: ListingId, cachedListing: Listing?)
}

enum ListingDetailsImage {
    case local(CreateListingPhoto)
    case remote(ListingImage)
}

final class ListingDetailsModel: EventNode {
    
    var listingUpdated: Driver<Listing?> { return listing.asDriver() }
    var photosUpdated: Driver<[ListingDetailsImage]> { return photos.asDriver() }
    
    var priceSettings: (code: String, price: Int) {
        return configsService.formatPrice(listing.value?.price ?? 0)
    }

    var paymentPlanViewModel: ListingPaymentPlanViewModel?
    private let listingId: ListingId?
    private let listing: BehaviorRelay<Listing?>
    private let photos: BehaviorRelay<[ListingDetailsImage]>
    
    private let listingsService: ListingsService
    private let configsService: ConfigurationsService
    let isUserOwnedListing: Bool
    
    init(
        parent: EventNode,
        config: ListingDetailsModelConfig,
        listingsService: ListingsService,
        configsService: ConfigurationsService,
        isUserOwnedListing: Bool
        ) {
        switch config {
        case .local(let listing, let photos):
            listingId = nil
            self.listing = BehaviorRelay(value: listing)
            self.photos = BehaviorRelay(value: photos.map { .local($0) })
            self.paymentPlanViewModel = ListingPaymentPlanViewModel(listing: listing,
                                                                    isUserOwnedListing: isUserOwnedListing)
        case .remote(let listingId, let cachedListing):
            self.listingId = listingId
            listing = BehaviorRelay(value: cachedListing)
            let remotePhotos = cachedListing?.sortedPhotos
            photos = BehaviorRelay(value: remotePhotos?.map { .remote($0) } ?? [])
            if let cachedListing = cachedListing {
                self.paymentPlanViewModel = ListingPaymentPlanViewModel(listing: cachedListing,
                                                                        isUserOwnedListing: isUserOwnedListing)
            }
        }
        
        self.listingsService = listingsService
        self.configsService = configsService
        self.isUserOwnedListing = isUserOwnedListing
        
        super.init(parent: parent)
    }
    
    func showDescription() {
        raise(event: ListingDetailsEvent.showDescription(listing.value?.listingDescription ?? ""))
    }
    
}
