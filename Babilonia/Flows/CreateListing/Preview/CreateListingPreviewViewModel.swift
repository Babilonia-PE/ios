//
//  CreateListingPreviewViewModel.swift
//  Babilonia
//
//  Created by Denis on 7/11/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class CreateListingPreviewViewModel {
    
    var requestState: Observable<RequestState> {
        return model.requestState.asObservable().observeOn(MainScheduler.instance)
    }
    
    var showWarning: Observable<Bool> {
        model.showWarning.asObservable().observeOn(MainScheduler.instance)
    }
    
    var listingDetailsViewModel: ListingDetailsViewModel {
        return ListingDetailsViewModel(model: model.listingDetailsModel)
    }
    
    var finishButtonTitle: String {
        switch model.mode {
        case .create: return L10n.CreateListing.Finish.Button.title
        case .edit: return L10n.Buttons.Save.title
        }
    }
    var buttonActionUpdated: BehaviorSubject<ButtonActionType> { model.buttonActionUpdated }
    var listingStatus: BehaviorSubject<String?> { model.listingStatus }
    
    private let model: CreateListingPreviewModel
    
    init(model: CreateListingPreviewModel) {
        self.model = model
    }
    
    func saveListing() {
        model.saveListing()
    }
    
    func publishListing() {
        model.publishListing()
    }
    
    func back() {
        model.back()
    }

    func exit() {
        model.exit()
    }
}
