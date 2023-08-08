//
//  FavoritesModel.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import RxCocoa
import RxSwift
import Core

enum FavoritesEvent: Event { }

final class FavoritesModel: EventNode {

    let requestState = PublishSubject<RequestState>()
    var listingsUpdated = BehaviorRelay(value: ())
    let listings = BehaviorRelay(value: [Listing]())
    let configService: ConfigurationsService

    private let listingsService: ListingsService

    init(parent: EventNode, listingsService: ListingsService, configService: ConfigurationsService) {
        self.listingsService = listingsService
        self.configService = configService

        super.init(parent: parent)
    }

    func fetchFavoritesListings() {
        requestState.onNext(.started)

        listingsService.favoriteListings { [weak self] result in
            switch result {
            case .success(let listings):
                self?.requestState.onNext(.finished)
                self?.listings.accept(listings)
                self?.listingsUpdated.accept(())

            case .failure(let error):
                self?.requestState.onNext(.failed(error))
            }
        }
    }

    func deleteListingFromFavorite(at index: Int) {
        let listingID = String(listings.value[index].id)

        requestState.onNext(.started)
        listingsService.deleteListingFromFavorite(listingID: listingID,
                                                  ipAddress: NetworkUtil.getWiFiAddress() ?? "",
                                                  userAgent: "ios",
                                                  signProvider: "email") { [weak self] result in
            switch result {
            case .success:
                self?.requestState.onNext(.finished)
                self?.fetchFavoritesListings()

            case .failure(let error):
                if self?.isUnauthenticated(error) == true {
                    self?.raise(event: MainFlowEvent.logout)
                } else {
                self?.requestState.onNext(.failed(error))
                }
            }
        }
    }

    func presentListingDetails(for index: Int) {
        let listing = listings.value[index]
        raise(event: ListingDetailsPresentableEvent.presentListingDetails(listing: listing))
    }
    
    private func isUnauthenticated(_ error: Error?) -> Bool {
        guard let serverError = error as? CompositeServerError,
              let code = serverError.errors.first?.code else { return false }
        
        return code == .unauthenticated
    }
}
