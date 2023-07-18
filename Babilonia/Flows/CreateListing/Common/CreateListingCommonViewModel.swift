//
//  CreateListingCommonViewModel.swift
//  Babilonia
//
//  Created by Denis on 6/3/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class CreateListingCommonViewModel: FieldsValidationApplicable {
    
    var listingTypeTitles: [String] { return model.listingTypes.map { $0.title } }
    var listingTypeIndex: Int { return model.listingTypeIndex }
    var endEditingUpdated: Signal<Void> { return endEditing.asSignal() }
    var commonTypes: Observable<[PropertyCommonType]> { model.commonTypes.asObservable() }
    
    var fieldsAreValidUpdated: Driver<Bool> {
        return Driver
            .combineLatest(inputFieldViewModels
                            .map { $0.value }.map { $0.validationDriver })
            .map { $0.allSatisfy({ $0 }) }
    }

    var typeFieldsAvailable: Bool {
        switch model.mode {
        case .create: return true
        case .edit: return false
        }
    }
    
    private var propertyTypeTitles: [String] { return model.propertyTypes.map { $0.title } }
    private(set) var inputFieldViewModels = [PropertyCommonType: InputFieldViewModel]()
    private(set) var priceViewModel: InputFieldViewModel!
    
    private let model: CreateListingCommonModel
    private let endEditing = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
    init(model: CreateListingCommonModel) {
        self.model = model

        setupFormFields()
    }
    
    func selectListingType(at index: Int) {
        model.selectListingType(at: index)
    }
    
    // MARK: - private

    //swiftlint:disable:next function_body_length
    private func setupFormFields() {
        let propertyTypeText = BehaviorRelay(value: "")
        model.currentPropertyType
            .map { $0.title }
            .drive(propertyTypeText)
            .disposed(by: disposeBag)
        let propertyTypeViewModel = InputFieldViewModel(
            title: BehaviorRelay(value: L10n.CreateListing.Common.PropertyType.title),
            text: propertyTypeText,
            validator: nil,
            editingMode: .action({ [unowned self] in
                self.endEditing.accept(())
                self.model.proceedWithPropertySelection(
                    titles: self.propertyTypeTitles,
                    title: L10n.CreateListing.Common.PropertyType.title
                )
            }),
            image: Asset.Common.dropdownIcon.image,
            placeholder: nil,
            isFieldEnabled: typeFieldsAvailable
        )
        
        let area = BehaviorRelay(value: model.currentAreaValue)
        area.bind(onNext: model.updateArea).disposed(by: disposeBag)
        let areaViewModel = InputFieldViewModel(
            title: BehaviorRelay(value: L10n.Filters.totalArea),
            text: area,
            validator: NumbersValidator(),
            textFormatter: LargeIntegerTextFormatter(),
            editingMode: .text,
            image: nil,
            placeholder: L10n.CreateListing.Common.Area.placeholder,
            keyboardType: .numberPad
        )
        let address = BehaviorRelay(value: "")
        model.addressUpdated.map { $0?.title ?? "" }.drive(address).disposed(by: disposeBag)
        let addressViewModel = InputFieldViewModel(
            title: BehaviorRelay(value: L10n.CreateListing.Common.Address.title),
            text: address,
            validator: NotEmptyValidator(),
            editingMode: .action({ [unowned self] in
                self.endEditing.accept(())
                self.model.proceedWithAddressSelection()
            }),
            image: Asset.Common.pinIcon.image,
            placeholder: L10n.CreateListing.Common.Address.placeholder
        )
        
        let validator = ListingDescriptionValidator()
        let descriptionTitle = BehaviorRelay(value: "")
        let descriptionText = BehaviorRelay(value: "")
        model.listingDescriptionUpdated
            .map { L10n.CreateListing.Common.Description.title($0.count, Int(validator.maximumCount)) }
            .drive(descriptionTitle)
            .disposed(by: disposeBag)
        model.listingDescriptionUpdated
            .delay(.milliseconds(1)) // avoiding strange label behavior when loading from draft here... =\
            .drive(descriptionText)
            .disposed(by: disposeBag)
        let descriptionViewModel = InputFieldViewModel(
            title: descriptionTitle,
            text: descriptionText,
            validator: ListingDescriptionValidator(),
            editingMode: .action({ [unowned self] in
                self.endEditing.accept(())
                self.model.proceedWithDescriptionEdit(maxSymbolsCount: Int(validator.maximumCount))
            }),
            image: nil,
            placeholder: L10n.CreateListing.Common.Description.placeholder,
            isAttributedText: true
        )

        let price = BehaviorRelay(value: model.currentPriceValue)
        price.bind(onNext: model.updatePrice).disposed(by: disposeBag)
        priceViewModel = InputFieldViewModel(
            title: model.priceTitle,
            text: price,
            validator: NumbersValidator(),
            textFormatter: LargeIntegerTextFormatter(),
            editingMode: .text,
            image: nil,
            placeholder: nil,
            keyboardType: .numberPad
        )

        let coveredArea = BehaviorRelay(value: model.currentCoveredAreaValue)
        coveredArea.bind(onNext: model.updateCoveredArea).disposed(by: disposeBag)
        let coveredAreaViewModel = InputFieldViewModel(
            title: BehaviorRelay(value: L10n.Filters.coveredArea),
            text: coveredArea,
            validator: EmptyNumbersValidator(),
            textFormatter: LargeIntegerTextFormatter(),
            editingMode: .text,
            image: nil,
            placeholder: L10n.CreateListing.Common.Area.placeholder,
            keyboardType: .numberPad
        )

        let yearFieldText = BehaviorRelay(value: "--")
        model.yearUpdated
            .map { String(year: $0) }
            .drive(yearFieldText)
            .disposed(by: disposeBag)
        let yearPickerViewModel = InputFieldViewModel(
            title: BehaviorRelay(value: L10n.CreateListing.Details.YearOfConstruction.title),
            text: yearFieldText,
            validator: nil,
            editingMode: .action({ [unowned self] in
                self.endEditing.accept(())
                self.model.proceedWithYearSelection(
                    titles: self.model.yearPickerValues.map { String(year: $0) },
                    title: L10n.CreateListing.Details.YearOfConstruction.title
                )
            }),
            image: Asset.Common.dropdownIcon.image,
            placeholder: nil
        )
        
        inputFieldViewModels = [.propertyType: propertyTypeViewModel,
                                .address: addressViewModel,
                                .description: descriptionViewModel,
                                .price: priceViewModel,
                                .totalArea: areaViewModel,
                                .coveredArea: coveredAreaViewModel,
                                .yearOfConstraction: yearPickerViewModel]
    }
    
}

extension ListingType {
    
    var title: String {
        switch self {
        case .sale:
            return L10n.CreateListing.Common.ListingType.Sale.title
        case .rent:
            return L10n.CreateListing.Common.ListingType.Rent.title
        }
    }
    
}

extension PropertyType {
    
    var title: String {
        switch self {
        case .apartment:
            return L10n.CreateListing.Common.PropertyType.Apartment.title
        case .house:
            return L10n.CreateListing.Common.PropertyType.House.title
        case .commercial:
            return L10n.CreateListing.Common.PropertyType.Commercial.title
        case .office:
            return L10n.CreateListing.Common.PropertyType.Office.title
        case .land:
            return L10n.CreateListing.Common.PropertyType.Land.title
        case .room:
            return L10n.CreateListing.Common.PropertyType.Room.title
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
