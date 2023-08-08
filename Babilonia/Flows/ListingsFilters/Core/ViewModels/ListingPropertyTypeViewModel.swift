//
//  ListingPropertyTypeViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 08.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import RxSwift
import RxCocoa

typealias FilterPropertyTypeValue = (titles: [String], startingIndex: Int)

final class ListingPropertyTypeViewModel {

    let listingType = BehaviorRelay<ListingType?>(value: nil)
    let proceedPropertyTypePicker: BehaviorRelay<FilterPropertyTypeValue>
    var listingTypeChanged: BehaviorRelay<ListingType?>
    var propertyTypeChanged: BehaviorRelay<PropertyType?>
    var currentPropertyType: PropertyType?

    var propertyStartingIndex: Int {
        guard let currentType = currentPropertyType,
            let index = self.propertyTypes.firstIndex(of: currentType) else { return 0 }

        return index + 1
    }

    var listingTypeObservable: Observable<ListingType?> {
        listingTypeChanged.asObservable()
    }
    
    var propertyTypeViewModel: InputFieldViewModel {
        let viewModel = InputFieldViewModel(
            title: BehaviorRelay(value: L10n.CreateListing.Common.PropertyType.title),
            text: propertyTypeText,
            validator: nil,
            editingMode: .action({ [unowned self] in
                self.proceedPropertyTypePicker.accept((titles: self.propertyTypesTitles,
                                                       startingIndex: self.propertyStartingIndex))
            }),
            image: Asset.Common.dropdownIcon.image,
            placeholder: nil
        )

        return viewModel
    }

    private var propertyTypes: [PropertyType] {
        PropertyType.allCases
    }

    private var propertyTypesTitles: [String] {
        [L10n.Filters.PropertyType.any] + PropertyType.allCases.map { $0.title }
    }
    
    private let propertyTypeText = BehaviorRelay(value: "")
    private let bag = DisposeBag()

    init(listingTypeChanged: BehaviorRelay<ListingType?>,
         propertyTypeChanged: BehaviorRelay<PropertyType?>,
         proceedPropertyTypePicker: BehaviorRelay<FilterPropertyTypeValue>) {
        self.listingTypeChanged = listingTypeChanged
        self.propertyTypeChanged = propertyTypeChanged
        self.proceedPropertyTypePicker = proceedPropertyTypePicker

        setupBinding()
        propertyTypeText.accept(propertyTypesTitles[0])
    }

    func updatePropertyType(for index: Int) {
        currentPropertyType = index == 0 ? nil : propertyTypes[index - 1]
        propertyTypeText.accept(propertyTypesTitles[index])
        propertyTypeChanged.accept(currentPropertyType)
    }

    func updatePropertyType(_ type: PropertyType?) {
        guard let type = type, let index = propertyTypes.firstIndex(of: type) else {
            updatePropertyType(for: 0)

            return
        }
        updatePropertyType(for: index + 1)
    }

    func reset() {
        listingTypeChanged.accept(nil)
        propertyTypeChanged.accept(nil)
        updatePropertyType(for: 0)
    }

    private func setupBinding() {
        listingType
            .subscribe(onNext: { [weak self] type in
                self?.listingTypeChanged.accept(type)
            })
            .disposed(by: bag)
    }

}
