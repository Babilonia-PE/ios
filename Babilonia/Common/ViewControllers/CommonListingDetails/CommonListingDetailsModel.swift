//
//  CommonListingDetailsModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 24.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Core
import RxCocoa
import RxSwift

enum CommonListingDetailsEvent: Event {
    case editListing(listing: Listing)
    case alertGuest//osemy
}

enum ListingDetailsViewState {
    case `default`
    case owned
}

final class CommonListingDetailsModel: EventNode {
    let showWarning = PublishSubject<Bool>()
    let requestState = PublishSubject<RequestState>()
    var listingUpdated: Driver<Listing?> { return listingSubject.asDriver() }
    var listingDetailsModel: ListingDetailsModel?

    let listingSubject = BehaviorRelay<Listing?>(value: nil)
    let listingIsFavorite = BehaviorRelay<Bool>(value: false)
    let viewState: ListingDetailsViewState
    var listingID: String {
        String(listing.id)
    }
    var phoneNumber: String {
        if let phoneNumber = listing.contacts?.first?.contactPhone {
            return phoneNumber
        } else {
            return listing.user.phoneNumber ?? ""
        }
    }
    var listingURL: String {
        String(listing.url?.share ?? "")
    }
    var listingState: ListingState {
        listing.state
    }

    let isModalPresentation: Bool
    let stateOnAppear: RequestState?
    let shouldHideEditAction: Bool
    var config: ListingDetailsModelConfig!
    
    private var listing: Listing
    private let listingsService: ListingsService
    private let configsService: ConfigurationsService
    private let userService: UserService

    init(parent: EventNode,
         listing: Listing,
         listingsService: ListingsService,
         configsService: ConfigurationsService,
         userService: UserService,
         viewState: ListingDetailsViewState = .default,
         isModalPresentation: Bool = true,
         stateOnAppear: RequestState? = nil) {
        self.listing = listing
        self.listingsService = listingsService
        self.configsService = configsService
        self.userService = userService
        self.viewState = listing.user.id == userService.userID ? .owned : viewState
        self.isModalPresentation = isModalPresentation
        self.stateOnAppear = stateOnAppear
        self.shouldHideEditAction = viewState == .default && listing.user.id == userService.userID

        super.init(parent: parent)
    }

    func getListingDetails() {
        
        switch viewState {
        case .default:
            requestState.onNext(.started)
            listingsService.getListingDetails(for: listingID) { [weak self] result in
                switch result {
                case .success(let listing):
                    self?.requestState.onNext(.finished)
                    guard let listing = listing else { return }

                    self?.listing = listing
                    self?.proccedListing(listing)

                case .failure(let error):
                    if self?.isUnauthenticated(error) == false {
                        self?.raise(event: MainFlowEvent.logout)
                    } else {
                        self?.requestState.onNext(.failed(nil))
                    }
                }
            }

        case .owned:
            requestState.onNext(.started)
            listingsService.getMyListingDetails(for: listingID) { [weak self] result in
                switch result {
                case .success(let listing):
                    self?.requestState.onNext(.finished)
                    guard let listing = listing else { return }

                    self?.listing = listing
                    self?.proccedListing(listing)

                case .failure(let error):
                    if self?.isUnauthenticated(error) == true {
                        self?.raise(event: MainFlowEvent.logout)
                    } else {
                        self?.requestState.onNext(.failed(nil))
                    }
                }
            }
        }
    }
    
    private func isUnauthenticated(_ error: Error?) -> Bool {
        guard let serverError = error as? CompositeServerError,
              let code = serverError.errors.first?.code else { return false }
        
        return code == .unauthenticated
    }

    func addListingToFavorites() {
        if userService.userID == .guest {
            raise(event: CommonListingDetailsEvent.alertGuest)
        } else {
            requestState.onNext(.started)
            listingsService.addListingToFavorite(
                listingID: listingID,
                ipAddress: NetworkUtil.getWiFiAddress() ?? "",
                userAgent: "ios",
                signProvider: "email") { [weak self] result in
                switch result {
                case .success:
                    self?.requestState.onNext(.finished)
                    self?.listingIsFavorite.accept(true)

                case .failure(let error):
                    if self?.isUnauthenticated(error) == true {
                        self?.raise(event: MainFlowEvent.logout)
                    } else {
                        self?.requestState.onNext(.failed(error))
                    }
                }
            }
        }
    }

    func removeListingFromFavorites() {
        requestState.onNext(.started)
        listingsService.deleteListingFromFavorite(listingID: listingID,
                                                  ipAddress: NetworkUtil.getWiFiAddress() ?? "",
                                                  userAgent: "ios",
                                                  signProvider: "email") { [weak self] result in
            switch result {
            case .success:
                self?.requestState.onNext(.finished)
                self?.listingIsFavorite.accept(false)

            case .failure(let error):
                if self?.isUnauthenticated(error) == true {
                    self?.raise(event: MainFlowEvent.logout)
                } else {
                    self?.requestState.onNext(.failed(error))
                }
            }
        }
    }

    func triggerContact() -> Bool {
        if userService.userID == .guest {
            raise(event: CommonListingDetailsEvent.alertGuest)
            return false
        } else {
            listingsService.triggerContactFromFavorite(listingID: listingID,
                                                       ipAddress: NetworkUtil.getWiFiAddress() ?? "",
                                                       userAgent: "ios",
                                                       signProvider: "email") { [weak self] result in
                if case .failure(let error) = result {
                    self?.requestState.onNext(.failed(error))
                }
            }
            return true
        }
    }
    
    func triggerWhatsapp() -> Bool {
        if userService.userID == .guest {
            raise(event: CommonListingDetailsEvent.alertGuest)
            return false
        } else {
            listingsService.triggerWhatsappFromDetail(listingID: listingID,
                                                      ipAddress: NetworkUtil.getWiFiAddress() ?? "",
                                                      userAgent: "ios",
                                                      signProvider: "email") { [weak self] result in
                if case .failure(let error) = result {
                    self?.requestState.onNext(.failed(error))
                }
            }
            return true
        }
    }
    
    func triggerView() {
        if userService.userID == .guest {
            raise(event: CommonListingDetailsEvent.alertGuest)
        } else {
            listingsService.triggerViewFromDetail(listingID: listingID,
                                                  ipAddress: NetworkUtil.getWiFiAddress() ?? "",
                                                  userAgent: "ios",
                                                  signProvider: "email") { [weak self] result in
                if case .failure(let error) = result {
                    self?.requestState.onNext(.failed(error))
                }
            }
        }
    }

    func editListing() {
        raise(event: CommonListingDetailsEvent.editListing(listing: listing))
    }

    func unpublishListing() {
        var editableListing = listing
        editableListing.status = .hidden
        editableListing.state = .unpublished
        updateListing(editableListing)
    }

    func publishListing() {
        if listing.role == .realtor {
            showWarning.onNext(true)
        } else {
            if listing.isPurchased {
                var editableListing = listing
                editableListing.status = .visible
                editableListing.state = .published
                updateListing(editableListing)
            } else {
                raise(event: MyListingsEvent.publishListing(listing: listing))
            }
        }
    }

    private func updateListing(_ listing: Listing) {
        guard let primaryImageId = listing.primaryImageId else { return }

        let photosInfo = CreateListingPhotosInfo(primaryImageID: primaryImageId,
                                                 imageIDs: listing.createListingPhotos.map { $0.id })
        requestState.onNext(.started)
        listingsService.updateListing(listing,
                                      photosInfo: photosInfo) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.requestState.onNext(.finished)
                DispatchQueue.main.async {
                    self.listing = listing
                    self.proccedListing(self.listing)
                }

            case .failure(let error):
                if self.isUnauthenticated(error) {
                    self.raise(event: MainFlowEvent.logout)
                } else {
                    self.requestState.onNext(.failed(error))
                }
            }
        }
    }

    func openMap() {
        guard let location = listing.location else { return }

        raise(event: ListingDetailsEvent.showMap(location: location, propertyType: listing.propertyType))
    }

    func openPhotoGallery() {
        raise(event: ListingDetailsEvent.showPhotoGallery(config: config))
    }
    
}

extension CommonListingDetailsModel {

    private func configurateListingModel(for listing: Listing) {
        var config: ListingDetailsModelConfig
        switch viewState {
        case .default:
            config = ListingDetailsModelConfig.remote(listingId: listing.id, cachedListing: listing)

        case .owned:
            config = ListingDetailsModelConfig.local(listing: listing, photos: listing.createListingPhotos)
        }

        let userID = listing.user.id
        listingDetailsModel = ListingDetailsModel(parent: self,
                                                  config: config,
                                                  listingsService: listingsService,
                                                  configsService: configsService,
                                                  isUserOwnedListing: userID == userService.userID)
        self.config = config
    }

    private func proccedListing(_ listing: Listing) {
        configurateListingModel(for: listing)
        listingSubject.accept(listing)
        listingIsFavorite.accept(listing.favourited ?? false)
    }

}
