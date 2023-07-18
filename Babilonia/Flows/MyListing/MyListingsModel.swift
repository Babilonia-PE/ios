//
//  MyListingsModel.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 6/26/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import RxCocoa
import RxSwift
import Core
import DBClient

enum MyListingsEvent: Event {
    case createListing(Listing?)
    case openListing(Listing)
    case editListing(Listing)
    case publishListing(listing: Listing?)
}

final class MyListingsModel: EventNode {

    var listingsUpdated: Driver<[Listing]> { return allListings.asDriver() }
    var listingsAreEmptyUpdated: Driver<Bool> { return listingsAreEmpty.asDriver().distinctUntilChanged() }
    var publishedListingsCount: Int { return publishedListings.count }
    var notPublishedListingsCount: Int { return notPublishedListings.count }

    let requestState = PublishSubject<RequestState>()
    let configsService: ConfigurationsService
    
    private var publishedListings = [Listing]()
    private var notPublishedListings = [Listing]()
    private var listingsObserver: RequestObservable<Listing>!
    private let allListings = BehaviorRelay(value: [Listing]())
    private let listingsAreEmpty = BehaviorRelay(value: false)
    private let listingsService: ListingsService
    
    // MARK: - lifecycle
    
    init(parent: EventNode, listingsService: ListingsService, configsService: ConfigurationsService) {
        self.listingsService = listingsService
        self.configsService = configsService
        
        super.init(parent: parent)
    }
    
    func fetchListings() {
        requestState.onNext(.started)
        publishedListings = []
        notPublishedListings = []
        allListings.accept([])
        listingsObserver = listingsService.getMyListingsObserver()
        listingsObserver.observe { [weak self] change in
            switch change {
            case .initial(let objects), .change((let objects, _, _, _)):
                self?.processListings(objects)
            case .error: break
            }
        }
        
        listingsService.fetchMyListings { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.requestState.onNext(.finished)
                self.listingsAreEmpty.accept(self.allListings.value.isEmpty)
                
            case .failure(let error):
                self.requestState.onNext(.failed(error))
            }
        }
    }
    
    func listingModel(at index: Int, isPublished: Bool) -> Listing {
        return isPublished ? publishedListings[index] : notPublishedListings[index]
    }

    func isListingNotPurchased(at listingID: Int) -> Bool {
        guard let listing = notPublishedListings.first(where: { $0.id == listingID }) else { return false }
        
        return listing.state == .notPublished || listing.state == .expired
    }
    
    func createListing() {
        raise(event: MyListingsEvent.createListing(nil))
    }
    
    func listingSelected(at index: Int, isPublished: Bool) {
        let listing = isPublished ? publishedListings[index] : notPublishedListings[index]
        
        switch listing.status {
        case .draft:
            raise(event: MyListingsEvent.createListing(listing))
            
        case .hidden, .visible:
            raise(event: MyListingsEvent.openListing(listing))
        }
    }
    
    func openListing(with id: ListingId) {
        guard let listing = (allListings.value.first { $0.id == id }) else { return }
        
        raise(event: MyListingsEvent.openListing(listing))
    }
    
    func editListing(with id: ListingId) {
        guard let listing = (allListings.value.first { $0.id == id }) else { return }
        
        switch listing.status {
        case .draft:
            raise(event: MyListingsEvent.createListing(listing))
        case .hidden, .visible:
            raise(event: MyListingsEvent.editListing(listing))
        }
    }
    
    func publishListing(with id: ListingId) {
        guard var listing = (allListings.value.first { $0.id == id }) else { return }

        if listing.isPurchased {
            listing.status = .visible
            editListing(listing)
        } else {
            raise(event: MyListingsEvent.publishListing(listing: listing))
        }
    }
    
    func unpublishListing(with id: ListingId) {
        guard var listing = (allListings.value.first { $0.id == id }) else { return }

        listing.status = .hidden
        editListing(listing)
    }

    private func editListing(_ listing: Listing) {
        guard let primaryImageId = listing.primaryImageId else { return }

        requestState.onNext(.started)
        let photosInfo = CreateListingPhotosInfo(primaryImageID: primaryImageId,
                                                 imageIDs: listing.createListingPhotos.map { $0.id })
        listingsService.updateListing(listing,
                                      photosInfo: photosInfo) { [weak self] result in
            switch result {
            case .success:
                self?.requestState.onNext(.finished)
                self?.fetchListings()

            case .failure(let error):
                self?.requestState.onNext(.failed(error))
            }
        }
    }
    
    func deleteListing(with id: ListingId) {
        guard let listing = (allListings.value.first { $0.id == id }) else { return }
        
        switch listing.status {
        case .draft:
            listingsService.removeDraftListing(listing) { [weak self] in
                self?.requestState.onNext(.success(L10n.Popups.ListingDeleted.text))
            }
        case .hidden, .visible: break
        }
    }
    
    // MARK: - private
    
    private func processListings(_ listings: [Listing]) {
        var objects = [Listing]()
        objects.append(contentsOf: listings.filter { $0.status == .draft })
        objects.append(contentsOf: listings.filter { $0.status != .draft })
        publishedListings = listings.filter { $0.state == .published }
        notPublishedListings = listings.filter { $0.state != .published }

        allListings.accept(objects)
    }
    
}

extension MyListingsModel: MyListingsAlertPresentable {

    func showAlert(_ message: String) {
        requestState.onNext(.success(message))
    }

}
