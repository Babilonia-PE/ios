//
//  FilterViewType.swift
//  Babilonia
//
//  Created by Alya Filon  on 06.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

enum FilterViewType: CaseIterable {
    case listingType
    case priceRange
    case totalArea
    case builtArea
    case yearOfConstruction
    case bedrooms
    case bathrooms
    case parkingForVisitors
    case facilities
    case totalFloors
    case floorNumber
    case parkingSlots

    static var commonTypes: [FilterViewType] {
        [.listingType, .priceRange, .totalArea, builtArea]
    }

    static var counterFilters: [FilterViewType] {
        [.bedrooms, .bathrooms, .totalFloors, .floorNumber, .parkingSlots]
    }

    static var checkmarksFilters: [FilterViewType] {
        [.parkingForVisitors]
    }

    var title: String {
        switch self {
        case .bedrooms: return L10n.CreateListing.Details.Bedrooms.title
        case .bathrooms: return L10n.CreateListing.Details.Bathrooms.title
        case .parkingForVisitors: return L10n.CreateListing.Details.parkingForVisitors
        case .totalFloors: return L10n.Filters.totalFloors
        case .floorNumber: return L10n.Filters.floorNumber
        case .parkingSlots: return L10n.CreateListing.Details.ParkingSlots.title

        default: return ""
        }
    }

    var sectionViewHeight: CGFloat {
        switch self {
        case .listingType: return 184
        case .priceRange: return 144
        case .totalArea, .builtArea: return 180
        case .yearOfConstruction: return 128
        default: return 0
        }
    }

    var icon: UIImage? {
        switch self {
        case .parkingForVisitors: return Asset.CreateListing.parkingForVisitsIcon.image
        default: return nil
        }
    }

}

enum FilterType: CaseIterable {

    case listingType
    case propertyType
    case priceRange
    case totalArea
    case yearOfConstruction
    case bedrooms
    case bathrooms
    case parkingForVisitors
    case facilities
    case builtArea
    case totalFloors
    case floorNumber
    case parkingSlots

}
