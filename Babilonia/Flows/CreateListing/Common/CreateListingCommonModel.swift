//
//  CreateListingCommonModel.swift
//  Babilonia
//
//  Created by Denis on 6/3/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import RxSwift
import RxCocoa
import Core
import CoreLocation.CLLocation

enum CreateListingCommonEvent: Event {
    case pickPropertyType(from: [String], updateHandler: ((Int) -> Void), title: String, startingIndex: Int)
    case editDescription(updateHandler: ((String) -> Void), initialText: String, maxSymbolsCount: Int)
    case selectAddress(updateHandler: ((MapAddress) -> Void), initialAddress: MapAddress?)
}

final class CreateListingCommonModel: EventNode, CreateListingModelUpdatable {
    
    let listingTypes = ListingType.allCases
    let propertyTypes = PropertyType.allCases
    var listingTypeIndex: Int { return currentListingTypeIndex.value }
    var currentListingTypeFilled: Driver<(ListingType, Bool)> {
        return Driver.combineLatest(
            currentListingType,
            listingFetched.asDriver()
        )
    }
    var currentListingType: Driver<ListingType> {
        return currentListingTypeIndex.asDriver().map { [unowned self] index in
            self.listingTypes[index]
        }
    }
    var currentPropertyType: Driver<PropertyType> {
        return currentPropertyTypeIndex.asDriver().map { [unowned self] index in
            self.propertyTypes[index]
        }
    }
    var listingDescriptionUpdated: Driver<String> { return listingDescription.asDriver() }
    var addressUpdated: Driver<MapAddress?> { return address.asDriver() }
    var yearUpdated: Driver<Int> {
        yearPickerIndex.asDriver().map { [unowned self] in self.yearPickerValues[$0] }
    }
    var currentPriceValue: String { return currentPrice.value }
    var currentAreaValue: String { return area.value }
    var currentCoveredAreaValue: String { return coveredArea.value }
    
    let updateListingCallback: ((UpdateListingBlock, Bool) -> Void)?
    
    let mode: ListingFillMode
    let yearPickerValues: [Int]

    let priceTitle = BehaviorRelay(value: "")
    let commonTypes = BehaviorRelay<[PropertyCommonType]>(value: PropertyCommonType.allCases)
    
    private let currentListingTypeIndex = BehaviorRelay(value: 0)
    private let currentPropertyTypeIndex = BehaviorRelay(value: 0)
    private let area = BehaviorRelay(value: "")
    private let coveredArea = BehaviorRelay(value: "")
    private let address = BehaviorRelay<MapAddress?>(value: nil)
    private let listingDescription = BehaviorRelay(value: "")
    private var currentPrice = BehaviorRelay(value: "")
    private var yearPickerIndex: BehaviorRelay<Int>
    
    private let listingFetched = BehaviorRelay(value: false)
    
    private let disposeBag = DisposeBag()
    
    // MARK: - lifecycle
    
    init(parent: EventNode, mode: ListingFillMode, updateListingCallback: ((UpdateListingBlock, Bool) -> Void)?) {
        self.mode = mode
        self.updateListingCallback = updateListingCallback

        var values = [Int](1900...Calendar.current.component(.year, from: Date()))
        values.append(0)
        self.yearPickerValues = values
        self.yearPickerIndex = BehaviorRelay(value: yearPickerValues.count - 1)
        
        super.init(parent: parent)
        
        setupListingUpdateBindings()
    }
    
    func selectListingType(at index: Int) {
        currentListingTypeIndex.accept(index)
        priceTitle.accept(proccedPriceTitle(for: index))
    }
    
    func proceedWithPropertySelection(titles: [String], title: String) {
        let updateBlock = { [unowned self] (index: Int) in
            self.currentPropertyTypeIndex.accept(index)
            self.cleanUpExcludedTypes()
        }
        raise(event: CreateListingCommonEvent.pickPropertyType(
            from: titles,
            updateHandler: updateBlock,
            title: title,
            startingIndex: currentPropertyTypeIndex.value
        ))
    }

    func proceedWithYearSelection(titles: [String], title: String) {
        let updateBlock = { [unowned self] (index: Int) in
            self.yearPickerIndex.accept(index)
        }
        raise(event: CreateListingCommonEvent.pickPropertyType(
            from: titles,
            updateHandler: updateBlock,
            title: title,
            startingIndex: yearPickerIndex.value
        ))
    }
        
    func updateArea(_ area: String) {
        self.area.accept(area)
    }

    func updateCoveredArea(_ coveredArea: String) {
        self.coveredArea.accept(coveredArea)
    }
    
    func proceedWithAddressSelection() {
        let updateBlock = { [unowned self] (address: MapAddress) in
            self.address.accept(address)
        }
        raise(event: CreateListingCommonEvent.selectAddress(updateHandler: updateBlock, initialAddress: address.value))
    }
    
    func proceedWithDescriptionEdit(maxSymbolsCount: Int) {
        let updateHandler = { [unowned self] (string: String) in
            self.listingDescription.accept(string)
        }
        raise(event: CreateListingCommonEvent.editDescription(
            updateHandler: updateHandler,
            initialText: listingDescription.value,
            maxSymbolsCount: maxSymbolsCount)
        )
    }

    func updatePrice(_ price: String) {
        currentPrice.accept(price)
    }

    func updateYear(_ year: Int) {
        guard let index = yearPickerValues.firstIndex(of: year) else { return }
        yearPickerIndex.accept(index)
    }
    
    // MARK: - private

    private func proccedPriceTitle(for listingTypeIndex: Int) -> String {
        switch listingTypes[listingTypeIndex] {
        case .sale:
            return L10n.CreateListing.Details.Price.Sale.title
        case .rent:
            return L10n.CreateListing.Details.Price.Rent.title
        }
    }

    //swiftlint:disable:next function_body_length
    private func setupListingUpdateBindings() {
        fetchListing { [unowned self] listing in
            self.update(from: listing)
            self.listingFetched.accept(true)
        }
        
        currentListingType
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] type in
                self.updateListing { listing in
                    listing.listingType = type
                }
            })
            .disposed(by: disposeBag)
        currentPropertyType
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] type in
                self.updateListing { listing in
                    listing.propertyType = type
                }
                self.commonTypes.accept([PropertyCommonType].commonTypes(for: type))
            })
            .disposed(by: disposeBag)
        listingDescriptionUpdated
            .debounce(.seconds(2))
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] description in
                self.updateListing { listing in
                    listing.listingDescription = description
                }
            })
            .disposed(by: disposeBag)
        area.asDriver()
            .debounce(.seconds(2))
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] area in
                self.updateListing { listing in
                    listing.area = Int(area)
                }
            })
            .disposed(by: disposeBag)
        addressUpdated
            .drive(onNext: { [unowned self] address in
                self.updateListing { listing in
                    listing.location = address.flatMap { (address: MapAddress) in
                        Location(
                            address: address.title,
                            latitude: Float(address.coordinate.latitude),
                            longitude: Float(address.coordinate.longitude)
                        )
                    }
                }
            })
            .disposed(by: disposeBag)
        currentPrice.asDriver()
            .debounce(.seconds(2))
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] price in
                self.updateListing {
                    $0.price = Int(price)
                }
            })
            .disposed(by: disposeBag)
        coveredArea.asDriver()
            .debounce(.seconds(2))
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] coveredArea in
                self.updateListing { listing in
                    listing.coveredArea = Int(coveredArea)
                }
            })
            .disposed(by: disposeBag)
        yearPickerIndex.asDriver()
            .distinctUntilChanged()
            .map { self.yearPickerValues[$0] }
            .drive(onNext: { [unowned self] year in
                self.updateListing {
                    $0.yearOfConstruction = Int(year)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func update(from listing: Listing) {
        if let type = listing.listingType, let index = listingTypes.firstIndex(of: type) {
            currentListingTypeIndex.accept(index)
        }
        if let type = listing.propertyType, let index = propertyTypes.firstIndex(of: type) {
            currentPropertyTypeIndex.accept(index)
        }
        if let area = listing.area {
            self.area.accept(String(area))
        }
        if let location = listing.location {
            address.accept(MapAddress(
                title: location.address,
                coordinate: CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(location.latitude),
                    longitude: CLLocationDegrees(location.longitude)
                )
            ))
        }
        listingDescription.accept(listing.listingDescription)
        if let price = listing.price {
            self.currentPrice.accept(String(price))
        }
        if let coveredArea = listing.coveredArea {
            self.coveredArea.accept(String(coveredArea))
        }
        if let year = listing.yearOfConstruction, let index = yearPickerValues.firstIndex(of: year) {
            yearPickerIndex.accept(index)
        }
    }

    private func cleanUpExcludedTypes() {
        updateListing { listing in
            let types = commonTypes.value
            let excludedTypes = PropertyCommonType.allCases.filter { !types.contains($0) }
            excludedTypes.forEach {
                switch $0 {
                case .coveredArea:
                    listing.coveredArea = nil
                case .yearOfConstraction:
                    listing.yearOfConstruction = nil
                default: break
                }
            }
        }
    }
    
}
