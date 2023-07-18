//
//  CreateListingDetailsViewModel.swift
//  Babilonia
//
//  Created by Denis on 6/3/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class CreateListingDetailsViewModel: FieldsValidationApplicable {
    
    var endEditingUpdated: Signal<Void> { return endEditing.asSignal() }
    
    var fieldsAreValidUpdated: Driver<Bool> { Driver.just(true) }
    let emptyStateTitle = PublishSubject<String>()

    private(set) var numberControlTypesViewModels = [NumberFieldViewModel]()
    private(set) var ckeckboxControlTypesViewModels = [CreateListingFacilityViewModel]()
    
    private let model: CreateListingDetailsModel
    
    /// doing it in a non-reactive way because we're updating fields on screen only ones per view appearance
    private var propertyDetailsTypes = [PropertyDetailsType]()
    
    private var numberControlTypes = [PropertyDetailsType]()
    private var checkboxControlTypes = [PropertyDetailsType]()

    private let endEditing = PublishRelay<Void>()
    
    private let fieldsAreValid = BehaviorRelay<Bool>(value: false)
    
    private let disposeBag = DisposeBag()
    private var formFieldsDisposeBag = DisposeBag()
    
    // MARK: - lifecycle
    
    init(model: CreateListingDetailsModel) {
        self.model = model
        
        setupBindings()
    }
    
    func viewAppeared() {
        updateDisplayTypes()
        setupFormFields()
    }
    
    // MARK: - private
    
    private func setupBindings() {
        model.propertyDetailsTypesUpdated
            .drive(onNext: { [weak self] value in
                self?.typesUpdated(value)
            })
            .disposed(by: disposeBag)
    }
    
    private func typesUpdated(_ types: [PropertyDetailsType]) {
        propertyDetailsTypes = types
    }
    
    private func updateDisplayTypes() {
        /// we could use `numberControlTypes = propertyDetailsTypes.filter { $0.displayType == .numberControl }`
        /// for each array here but decided to do it with `switch` statement to prevent types losing in case new
        /// ones are added
        
        numberControlTypes = []
        checkboxControlTypes = []

        propertyDetailsTypes.forEach {
            switch $0.displayType {
            case .numberControl:
                numberControlTypes.append($0)
            case .checkboxControl:
                checkboxControlTypes.append($0)
            }
        }
    }
    
    private func setupFormFields() {
        formFieldsDisposeBag = DisposeBag()
        numberControlTypesViewModels = []
        ckeckboxControlTypesViewModels = []

        numberControlTypes.forEach { type in
            let value = BehaviorRelay(value: self.valueForNumberControlType(type))
            value.bind(onNext: { [unowned self] value in
                self.model.updatePropertyDetailsType(type, with: value)
            }).disposed(by: formFieldsDisposeBag)
            let viewModel = NumberFieldViewModel(
                title: type.title,
                value: value
            )
            numberControlTypesViewModels.append(viewModel)
        }

        checkboxControlTypes.forEach { type in
            let value = BehaviorRelay(value: self.valueForCheckboxControlType(type))
            value.bind(onNext: { [unowned self] value in
                self.model.updatePropertyDetailsType(type, with: value)
            }).disposed(by: formFieldsDisposeBag)
            let viewModel = CreateListingFacilityViewModel(title: type.title,
                                                           image: type.image,
                                                           value: value)
            ckeckboxControlTypesViewModels.append(viewModel)
        }

        if numberControlTypes.isEmpty && checkboxControlTypes.isEmpty {
            let propertyTitle = model.propertyType.value.title
            let text = L10n.CreateListing.Details.EmptyDetails.title(propertyTitle)
            emptyStateTitle.onNext(text)
        }
    }
    
    private func valueForNumberControlType(_ type: PropertyDetailsType) -> Int {
        let value = (model.propertyDetailsTypesMap[type] ?? type.defaultValue) as? Int
        return value ?? 0
    }
    
    private func valueForCheckboxControlType(_ type: PropertyDetailsType) -> Bool {
        let value = (model.propertyDetailsTypesMap[type] ?? type.defaultValue) as? Bool
        return value ?? false
    }
    
}

private extension PropertyDetailsType {
    
    var title: String {
        switch self {
        case .bathrooms:
            return L10n.CreateListing.Details.Bathrooms.title
        case .bedrooms:
            return L10n.CreateListing.Details.Bedrooms.title
        case .parkingSlots:
            return L10n.CreateListing.Details.ParkingSlots.title
        case .petFriendly:
            return L10n.CreateListing.Details.PetFriendly.title
        case .totalFloors:
            return L10n.Filters.totalFloors
        case .floorNumber:
            return L10n.Filters.floorNumber
        case .parkingForVisitors:
            return L10n.CreateListing.Details.parkingForVisitors
        }
    }
    
    var image: UIImage? {
        switch self {
        case .petFriendly:
            return Asset.Common.petFriendlyIcon.image
        case .parkingForVisitors:
            return Asset.CreateListing.parkingForVisitsIcon.image
        default:
            return nil
        }
    }
    
    var defaultValue: Any {
        switch self {
        case .bathrooms, .bedrooms:
            return 1
        case .parkingSlots, .totalFloors, .floorNumber:
            return 0
        case .petFriendly, .parkingForVisitors:
            return false
        }
    }
    
}

private extension String {
    
    init(year: Int) {
        switch year {
        case 0:
            self = "--"
        default:
            self = String(year)
        }
    }
    
}
