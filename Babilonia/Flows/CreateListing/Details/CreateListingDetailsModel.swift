//
//  CreateListingDetailsModel.swift
//  Babilonia
//
//  Created by Denis on 6/3/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import RxCocoa
import RxSwift
import Core

final class CreateListingDetailsModel: EventNode, CreateListingModelUpdatable {
    
    let propertyType: BehaviorRelay<PropertyType>
    let listingType: BehaviorRelay<ListingType>
    
    var propertyDetailsTypesUpdated: Driver<[PropertyDetailsType]> {
        return Driver.combineLatest(propertyType.asDriver(), listingType.asDriver())
            .map { [PropertyDetailsType](propertyType: $0, listingType: $1) }
    }
    
    let updateListingCallback: ((UpdateListingBlock, Bool) -> Void)?
    
    private(set) var propertyDetailsTypesMap = [PropertyDetailsType: Any]()
    
    var currentPriceValue: String { return currentPrice.value }
    private var currentPrice = BehaviorRelay(value: "")

    private let disposeBag = DisposeBag()
    
    // MARK: - lifecycle
    
    init(parent: EventNode, updateListingCallback: ((UpdateListingBlock, Bool) -> Void)?) {
         self.updateListingCallback = updateListingCallback
        
        propertyType = BehaviorRelay(value: .apartment)
        listingType = BehaviorRelay(value: .rent)

        super.init(parent: parent)
        
        setupBindings()
        setupListingUpdateBindings()
    }
    
    func updatePropertyDetailsType(_ type: PropertyDetailsType, with value: Any) {
        propertyDetailsTypesMap[type] = value
        
        updateListing(with: type, with: value)
        cleanUpExcludedTypes()
    }

    func updatePrice(_ price: String) {
        currentPrice.accept(price)
    }
    
    // MARK: - private
    
    private func setupBindings() {
        Driver
            .combineLatest(listingType.asDriver(), propertyType.asDriver())
            .distinctUntilChanged { $0.0 == $1.0 && $0.1 == $1.1 }
            .map { _ in }
            .drive(onNext: { [weak self] in
                self?.resetListingProperties()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupListingUpdateBindings() {
        fetchListing { [unowned self] listing in
            self.update(from: listing)
        }
        
        currentPrice.asDriver()
            .debounce(.seconds(2))
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] price in
                self.updateListing {
                    $0.price = Int(price)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func update(from listing: Listing) {
        if let bedroomsCount = listing.bedroomsCount {
            propertyDetailsTypesMap[.bedrooms] = bedroomsCount
        }
        
        if let bathroomsCount = listing.bathroomsCount {
            propertyDetailsTypesMap[.bathrooms] = bathroomsCount
        }

        if let totalFloorsCount = listing.totalFloorsCount {
            propertyDetailsTypesMap[.totalFloors] = totalFloorsCount
        }
        if let floorNumber = listing.floorNumber {
            propertyDetailsTypesMap[.floorNumber] = floorNumber
        }
        
        if let parkingSlotsCount = listing.parkingSlotsCount {
            propertyDetailsTypesMap[.parkingSlots] = parkingSlotsCount
        }

        if let parkingForVisits = listing.parkingForVisits {
            propertyDetailsTypesMap[.parkingForVisitors] = parkingForVisits
        }
        
        if let petFriendly = listing.petFriendly {
            propertyDetailsTypesMap[.petFriendly] = petFriendly
        }
    }
    
    private func resetListingProperties() {
        propertyDetailsTypesMap.forEach {
            self.updateListing(with: $0.key, with: $0.value)
        }
        cleanUpExcludedTypes()
    }
    
    private func updateListing(with type: PropertyDetailsType, with value: Any) {
        updateListing { listing in
            switch type {
            case .bedrooms:
                listing.bedroomsCount = value as? Int
            case .bathrooms:
                listing.bathroomsCount = value as? Int
            case .parkingSlots:
                listing.parkingSlotsCount = value as? Int
            case .totalFloors:
                listing.totalFloorsCount = value as? Int
            case .floorNumber:
                listing.floorNumber = value as? Int
            case .petFriendly:
                listing.petFriendly = value as? Bool
            case .parkingForVisitors:
                listing.parkingForVisits = value as? Bool
            }
        }
    }
    
    private func cleanUpExcludedTypes() {
        updateListing { listing in
            let types = [PropertyDetailsType](propertyType: propertyType.value, listingType: listingType.value)
            let excludedTypes = PropertyDetailsType.allCases.filter { !types.contains($0) }
            excludedTypes.forEach {
                switch $0 {
                case .bedrooms:
                    listing.bedroomsCount = nil
                case .bathrooms:
                    listing.bathroomsCount = nil
                case .parkingSlots:
                    listing.parkingSlotsCount = nil
                case .parkingForVisitors:
                    listing.parkingForVisits = nil
                case .totalFloors:
                    listing.totalFloorsCount = nil
                case .floorNumber:
                    listing.floorNumber = nil
                case .petFriendly:
                    listing.petFriendly = nil
                }
            }
        }
    }
    
}
