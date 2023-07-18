//
//  CreateListingViewModel.swift
//  Babilonia
//
//  Created by Denis on 5/31/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit.UIImage

final class CreateListingViewModel {
    
    var title: String {
        switch model.mode {
        case .create: return L10n.CreateListing.title
        case .edit: return L10n.EditListing.title
        }
    }
    var elements: [(String, UIImage)] { return model.steps.map { ($0.title, $0.image) } }
    var continueTitle: Driver<String> {
        return model.currentIndexUpdated.map { [unowned self] in
            if $0 == self.model.steps.count - 1 {
                return L10n.CreateListing.Preview.title
            } else {
                return L10n.CreateListing.Continue.title($0 + 1, self.model.steps.count)
            }
        }
    }
    var currentIndexUpdated: Driver<Int> { return model.currentIndexUpdated }
    var continueButtonEnabled: Driver<Bool> {
        return Driver.combineLatest(currentIndexUpdated, Driver.combineLatest(validationMap.values)).map { (arg) in
            let (index, map) = arg
            return map.first(
                where: {
                    $0.0 == index
                }
            )?.1 ?? true
        }
    }
    
    //swiftlint:disable:next large_tuple
    var exitPopupSettings: (title: String, text: String, canSave: Bool, continueTitle: String) {
        switch model.mode {
        case .create:
            return (
                L10n.CreateListing.Finish.Popup.title,
                L10n.CreateListing.Finish.Popup.text,
                true,
                L10n.CreateListing.Finish.Popup.Continue.title
            )
        case .edit:
            return (
                L10n.CreateListing.Finish.EditPopup.title,
                L10n.CreateListing.Finish.EditPopup.text,
                false,
                L10n.CreateListing.Finish.EditPopup.Continue.title
            )
        }
    }
    
    private let model: CreateListingModel
    
    private var validationMap = [Int: Driver<(Int, Bool)>]()
    
    init(model: CreateListingModel) {
        self.model = model
    }
    
    func viewAppeared() {
        model.enableDraftUpdates()
    }
    
    func updateCurrentIndex(_ index: Int) {
        model.updateCurrentIndex(index)
    }
    
    func finishCreation() {
        model.finishCreation()
    }
    
    func close() {
        model.close()
    }
    
    func saveAndClose() {
        model.saveAndClose()
    }
    
    func back() {
        model.decreaseCurrentIndex()
    }
    
    //swiftlint:disable force_cast
    func viewModel(at index: Int) -> Any {
        let stepModel = model.model(at: index)
        let viewModel: FieldsValidationApplicable
        switch stepModel {
        case is CreateListingCommonModel:
            viewModel = CreateListingCommonViewModel(model: stepModel as! CreateListingCommonModel)
        case is CreateListingDetailsModel:
            viewModel = CreateListingDetailsViewModel(model: stepModel as! CreateListingDetailsModel)
        case is CreateListingFacilitiesModel:
            viewModel = CreateListingFacilitiesViewModel(model: stepModel as! CreateListingFacilitiesModel)
        case is CreateListingAdvancedModel:
            viewModel = CreateListingAdvancedViewModel(model: stepModel as! CreateListingAdvancedModel)
        case is CreateListingPhotosModel:
            viewModel = CreateListingPhotosViewModel(model: stepModel as! CreateListingPhotosModel)
        default:
            fatalError("undefined type of \(stepModel)")
        }
        
        validationMap[index] = viewModel.fieldsAreValidUpdated.map { (index, $0) }
        
        return viewModel
    }
    //swiftlint:enable force_cast
    
}

private extension CreateListingModel.Step {
    
    var title: String {
        switch self {
        case .common:
            return L10n.CreateListing.Steps.General.title
        case .details:
            return L10n.CreateListing.Steps.Details.title
        case .facilities:
            return L10n.CreateListing.Steps.Facilities.title
        case .advanced:
            return L10n.CreateListing.Steps.Advanced.title
        case .photos:
            return L10n.CreateListing.Steps.Photos.title
        }
    }
    
    var image: UIImage {
        switch self {
        case .common:
            return Asset.CreateListing.createListingPageCommon.image
        case .details:
            return Asset.CreateListing.createListingPageDetails.image
        case .facilities:
            return Asset.CreateListing.createListingPageFacilities.image
        case .advanced:
            return Asset.CreateListing.createListingPageAdvanced.image
        case .photos:
            return Asset.CreateListing.createListingPagePhotos.image
        }
    }
    
}
