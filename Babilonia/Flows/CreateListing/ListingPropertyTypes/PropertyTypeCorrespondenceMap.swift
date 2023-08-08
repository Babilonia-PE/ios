//
//  PropertyTypeCorrespondenceMap.swift
//  Babilonia
//
//  Created by Denis on 6/12/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

extension PropertyDetailsType {
    
    var displayType: PropertyDetailsDisplayType {
        switch self {
        case .bathrooms, .bedrooms, .totalFloors, .floorNumber, .parkingSlots:
            return .numberControl
        case .petFriendly, .parkingForVisitors:
            return .checkboxControl
        }
    }
    
}

extension Array where Element == PropertyDetailsType {
    
    init(propertyType: PropertyType, listingType: ListingType) {
        var detailsList = [PropertyDetailsType]()

        switch propertyType {
        case .apartment, .room:
            detailsList = [.bedrooms, .bathrooms, .totalFloors, .floorNumber, .parkingSlots, .parkingForVisitors]
        case .house, .cottage, .beachHouse:
            detailsList = [.bedrooms, .bathrooms, .totalFloors, .parkingSlots, .parkingForVisitors]
        case .commercial, .office, .localIndustrial, .landCommercial, .building, .hotel, .airs:
            detailsList = [.bathrooms, .totalFloors, .floorNumber, .parkingSlots, .parkingForVisitors]
        case .land, .landAgricultural, .landIndustrial, .deposit, .parking:
            detailsList = []
        }

        let petFriedlyPropertyDisable: [PropertyType] = [.commercial, .land]
        if listingType == .rent && !petFriedlyPropertyDisable.contains(propertyType) {
            detailsList.append(.petFriendly)
        }

        self = detailsList
    }
    
}

extension Array where Element == PropertyCommonType {

    static func commonTypes(for propertyType: PropertyType) -> [PropertyCommonType] {
        switch propertyType {
        case .apartment, .house, .office, .commercial, .localIndustrial, .landCommercial, .cottage, .beachHouse, .building, .hotel, .airs:
            return PropertyCommonType.allCases
        case .land, .landAgricultural, .landIndustrial, .deposit, .parking:
            return PropertyCommonType.allCases.filter { $0 != .coveredArea && $0 != .yearOfConstraction }
        case .room:
            return PropertyCommonType.allCases.filter { $0 != .coveredArea }
        }
    }

}
