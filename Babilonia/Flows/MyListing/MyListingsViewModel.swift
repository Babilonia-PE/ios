//
//  MyListingsViewModel.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 6/26/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Core

enum MyListingOptions {
    case open, edit, publish, unpublish, delete, share
}

final class MyListingsViewModel {
    
    var requestState: Observable<RequestState> {
        model.requestState .asObservable().observeOn(MainScheduler.instance)
    }
    
    var showWarning: Observable<Bool> {
        model.showWarning.asObservable().observeOn(MainScheduler.instance)
    }
    
    var shouldShowAddListingButton: Driver<Bool> {
        Driver.combineLatest(model.listingsUpdated, model.listingsAreEmptyUpdated) { !$0.isEmpty && !$1 }
    }
    
    var listingsUpdated: Driver<Void> { model.listingsUpdated.map { _ in } }
    var emptyStateNeeded: Driver<Bool> { model.listingsAreEmptyUpdated }
    var publishedListingsCount: Int { model.publishedListingsCount }
    var notPublishedListingsCount: Int { model.notPublishedListingsCount }
    
    private let model: MyListingsModel
    private var listingsDisposeBag = DisposeBag()
    
    // MARK: - lifecycle
    
    init(model: MyListingsModel) {
        self.model = model
    }
    
    func fetchListings() {
        model.fetchListings()
    }
    
    func listingViewModel(at index: Int, isPublished: Bool) -> ListingViewModel {
        return ListingViewModel(
            listing: model.listingModel(at: index, isPublished: isPublished),
            configsService: model.configsService,
            isUserOwnedListing: true
        )
    }
    
    func createListing() {
        model.createListing()
    }
    
    func listingSelected(at index: Int, isPublished: Bool) {
        model.listingSelected(at: index, isPublished: isPublished)
    }

    func isListingNotPurchased(at listingID: Int) -> Bool {
        model.isListingNotPurchased(at: listingID)
    }
    
    func isListingRealtor(at listingID: Int) -> Bool {
        model.isListingRealtor(at: listingID)
    }
    
    func openListing(with id: ListingId) {
        model.openListing(with: id)
    }
    
    func editListing(with id: ListingId) {
        model.editListing(with: id)
    }
    
    func isListingShared(with id: ListingId) -> String {
        model.getShareURL(for: id) ?? ""
    }
    
    func isDataShared(with id: ListingId) -> String {
        model.dataShare(for: id) 
    }
    
    func publishListing(with id: ListingId) {
        model.publishListing(with: id)
    }
    
    func getListingPrice(with id: ListingId) -> Int {
        model.getListingPrice(with: id) ?? 0
    }
    
    func unpublishListing(with id: ListingId) {
        model.unpublishListing(with: id)
    }
    
    func unpublishListing(with id: ListingId, reason: String, priceFinal: Int) {
        model.unpublishListing(with: id, reason: reason, priceFinal: priceFinal)
    }
    
    func deleteListing(with id: ListingId) {
        model.deleteListing(with: id)
    }
    
    func listingOptionsSelected(at index: Int, isPublished: Bool) -> (ListingId, [MyListingOptions]) {
        let listing = model.listingModel(at: index, isPublished: isPublished)

        if listing.status == .draft {
            return (listing.id, [.edit, .delete])
        }
        
        switch listing.state {
        case .published: return (listing.id, [.open, .share, .edit, .unpublish])
        default: return (listing.id, [.open, .edit, .publish])
        }
    }
    
}
