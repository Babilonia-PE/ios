//
//  CreateListingPreviewModel.swift
//  Babilonia
//
//  Created by Denis on 7/11/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Core
import RxCocoa
import RxSwift

enum CreateListingPreviewEvent: Event {
    case listingCreated(listing: Listing?)
    case back
    case closeFlow
}

enum ButtonActionType {
    case save
    case publish

    var title: String {
        switch self {
        case .save: return L10n.Buttons.Save.title.uppercased()
        case .publish: return L10n.MyListings.Options.Publish.title.uppercased()
        }
    }
}

final class CreateListingPreviewModel: EventNode {
    let showWarning = PublishSubject<Bool>()
    let requestState = PublishSubject<RequestState>()
    
    var listingDetailsModel: ListingDetailsModel {
        return ListingDetailsModel(
            parent: self,
            config: ListingDetailsModelConfig.local(listing: listing, photos: photos),
            listingsService: listingsService,
            configsService: configsService,
            isUserOwnedListing: true
        )
    }

    var buttonActionType: ButtonActionType = .save
    var createdListing: Listing?
    let buttonActionUpdated = BehaviorSubject<ButtonActionType>(value: .save)
    let listingStatus = BehaviorSubject<String?>(value: nil)
    let mode: ListingFillMode
    
    private let listing: Listing
    private let photos: [CreateListingPhoto]
    private let listingsService: ListingsService
    private let configsService: ConfigurationsService
    
    // MARK: - lifecycle
        
    init(
        parent: EventNode,
        listing: Listing,
        photos: [CreateListingPhoto],
        listingsService: ListingsService,
        configsService: ConfigurationsService,
        mode: ListingFillMode
    ) {
        self.listing = listing
        self.photos = photos
        self.listingsService = listingsService
        self.configsService = configsService
        self.mode = mode
        
        super.init(parent: parent)

        let status = mode == .edit ? L10n.ListingDetails.Status.notPublished : nil
        listingStatus.onNext(status)
    }
    
    func saveListing() {
        switch mode {
        case .create: create(listing: listing)
        case .edit: updateListing()
        }
    }

    func exit() {
        switch mode {
        case .create: raise(event: CreateListingPreviewEvent.closeFlow)
        case .edit: updateListing(isEdit: true)
        }
    }
    
    func publishListing() {
        let listingCopy = createdListing ?? listing
        
        guard listingCopy.status != .draft else {
            var listingCopy = listing
            listingCopy.status = .hidden
            create(listing: listingCopy)
            listingStatus.onNext(L10n.ListingDetails.Status.notPublished)

            return
        }

        switch buttonActionType {
        case .save:
            let shouldCloseAfter = listing.state == .published
            updateListing(shouldCloseAfter: shouldCloseAfter, isEdit: true)

        case .publish:
            if listingCopy.state == .unpublished {
                if listingCopy.role == .realtor { //realtor
                    warningListing()
                } else {
                    var listingCopy = listing
                    listingCopy.status = .visible
                    updateListing()
                }
                
            } else {
                presentPublishListingFlow()
            }
        }
    }
    
    func back() {
        switch buttonActionType {
        case .save:
            raise(event: CreateListingPreviewEvent.back)
        case .publish:
            raise(event: CreateListingPreviewEvent.closeFlow)
        }
    }
    
    // MARK: - private
    
    private func create(listing: Listing) {
        requestState.onNext(.started)
        listingsService.createListing(
            listing,
            photosInfo: CreateListingPhotosInfo(photos: photos)
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let createdListing):
                self.createdListing = createdListing
                self.requestState.onNext(.success(L10n.CreateListing.Created.alert))
                self.changeButtonType()
                self.listingsService.removeDraftListing(self.listing)

            case .failure(let error):
                if self.isUnauthenticated(error) {
                    self.raise(event: MainFlowEvent.logout)
                } else {
                    self.requestState.onNext(.failed(error))
                }
            }
        }
    }
    
    private func isUnauthenticated(_ error: Error?) -> Bool {
        guard let serverError = error as? CompositeServerError,
              let code = serverError.errors.first?.code else { return false }
        
        return code == .unauthenticated
    }

    private func presentPublishListingFlow() {
        let publishListing = createdListing ?? listing
        raise(event: CreateListingPreviewEvent.listingCreated(listing: publishListing))
    }

    private func updateListing(shouldCloseAfter: Bool = true, isEdit: Bool = false) {
        var listingCopy = listing
        listingCopy.isEdit = isEdit
        requestState.onNext(.started)
        listingsService.updateListing(
            listingCopy,
            photosInfo: CreateListingPhotosInfo(photos: photos)
        ) { [weak self] result in
            switch result {
            case .success:
                self?.requestState.onNext(.success(L10n.CreateListing.Created.alert))
                if shouldCloseAfter {
                    self?.raise(event: CreateListingPreviewEvent.closeFlow)
                } else {
                    self?.changeButtonType()
                }
            case .failure(let error):
                if self?.isUnauthenticated(error) == true  {
                    self?.raise(event: MainFlowEvent.logout)
                } else {
                    self?.requestState.onNext(.failed(error))
                }
            }
        }
    }
    
    private func warningListing() {
        showWarning.onNext(true)
    }

    private func changeButtonType(_ type: ButtonActionType = .publish) {
        DispatchQueue.main.async { [weak self] in
            self?.buttonActionType = type
            self?.buttonActionUpdated.onNext(type)
        }
    }
    
}

private extension CreateListingPhotosInfo {
    
    init(photos: [CreateListingPhoto]) {
        let primaryImageID = (photos.first { $0.isMainPhoto } ?? photos.first)?.id ?? 0
        self = CreateListingPhotosInfo(
            primaryImageID: primaryImageID,
            imageIDs: photos.map { $0.id }
        )
    }
    
}
