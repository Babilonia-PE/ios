//
//  CommonListingDetailsViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 24.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Core
import RxCocoa
import RxSwift

final class CommonListingDetailsViewModel {

    var requestState: Observable<RequestState> {
        model.requestState.asObservable().observeOn(MainScheduler.instance)
    }
    var listingUpdated: Driver<Void> {
        model.listingUpdated.map { _ in }
    }
    var listingIsFavoriteObservable: Observable<Bool> {
        model.listingIsFavorite.asObservable()
    }
    var listingDetailsViewModel: ListingDetailsViewModel? {
        guard let model = model.listingDetailsModel else { return nil }
        
        return ListingDetailsViewModel(model: model)
    }
    var viewState: ListingDetailsViewState {
        model.viewState
    }
    var phoneNumber: String {
        model.phoneNumber
    }
    var isModalPresentation: Bool {
        model.isModalPresentation
    }
    var stateOnAppear: RequestState? {
        model.stateOnAppear
    }
    var isListingPublished: Bool {
        model.listingState == .published
    }
    var isListingNotPurchased: Bool {
        model.listingState == .notPublished || model.listingState == .expired
    }
    var shouldHideEditAction: Bool {
        model.shouldHideEditAction
    }
    var title: String {
        viewState == .owned ? L10n.CreateListing.ListingPreview.title : ""
    }
    var statusTitle: String? {
        guard viewState == .owned, !shouldHideEditAction else { return nil }

        switch model.listingState {
        case .published: return L10n.ListingDetails.Status.published
        case .notPublished: return L10n.ListingDetails.Status.notPublished
        case .unpublished, .expired: return L10n.ListingDetails.Status.unpublished
        }
    }
    
    private let model: CommonListingDetailsModel
    
    init(model: CommonListingDetailsModel) {
        self.model = model
    }

    func getListingDetails() {
        model.getListingDetails()
    }

    func addListingToFavorites() {
        model.addListingToFavorites()
    }

    func removeListingFromFavorites() {
        model.removeListingFromFavorites()
    }

    func editListing() {
        model.editListing()
    }

    func unpublishListing() {
        model.unpublishListing()
    }

    func publishListing() {
        model.publishListing()
    }

    func triggerContact() {
        model.triggerContact()
    }

    func openMap() {
        model.openMap()
    }

    func openPhotoGallery() {
        model.openPhotoGallery()
    }
    
}
