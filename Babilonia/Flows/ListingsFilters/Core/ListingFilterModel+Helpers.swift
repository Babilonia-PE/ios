//
//  ListingFilterModel+Helpers.swift
//  Babilonia
//
//  Created by Alya Filon  on 19.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import Core

extension ListingFilterModel {

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    func convertToFilterInfo() -> [FilterInfo] {
        let priceConverter = FilterPriceConverter()
        var infos = [FilterInfo]()

        if listingType != nil {
            let listingTypeTitle = (listingType == .sale ? L10n.CreateListing.Common.ListingType.Sale.title
                                                        : L10n.CreateListing.Common.ListingType.Rent.title)
                .appliedFilterTitle(isListingType: true)
            infos.append(FilterInfo(attributedTitle: listingTypeTitle,
                                    mode: .type(listingType!),
                                    filterType: .listingType))
        }

        if let propertyType = propertyType {
            infos.append(FilterInfo(attributedTitle: propertyType.title.appliedFilterTitle(),
                                    mode: .common,
                                    filterType: .propertyType))
        }

        if listingType != nil {
            let isPricesApplied = priceStart != nil || priceEnd != nil
            let isPricesNotDefault = priceStart != 0 && priceEnd != priceConverter.maxPrice(for: listingType!)
            if isPricesApplied && isPricesNotDefault {
                let start = "\(priceStart ?? 0)".commaConverted()
                let end = "\(priceEnd ?? priceConverter.maxPrice(for: listingType!))".shortPriceConverting()
                let title = "$\(start) - $\(end)".appliedFilterTitle()
                infos.append(FilterInfo(attributedTitle: title, mode: .common, filterType: .priceRange))
            }
        }

        if let fromArea = totalAreaFrom, let toArea = totalAreaTo {
            let title = L10n.Filters.Applied.areaRange(fromArea, toArea)
                .appliedFilterTitle(title: L10n.Filters.Applied.TotalArea.type)
            infos.append(FilterInfo(attributedTitle: title, mode: .common, filterType: .totalArea))
        }

        if let fromBuilt = builtAreaFrom, let toBuilt = builtAreaTo {
            let title = L10n.Filters.Applied.areaRange(fromBuilt, toBuilt)
                .appliedFilterTitle(title: L10n.Filters.Applied.CoveredArea.type)
            infos.append(FilterInfo(attributedTitle: title, mode: .common, filterType: .builtArea))
        }

        if let fromYear = yearFrom, let toYear = yearTo {
            let title = "\(fromYear) - \(toYear)".appliedFilterTitle()
            infos.append(FilterInfo(attributedTitle: title, mode: .common, filterType: .yearOfConstruction))
        }

        if let bedrooms = bedroomsCount, bedrooms != 0 {
            let plural = "\(bedrooms) " + L10n.CreateListing.Details.Bedrooms.title.lowercased()
            let singular = "\(bedrooms) " + L10n.CreateListing.Details.Bedrooms.Title.singular.lowercased()
            let title = bedrooms == 1 ? singular : plural
            infos.append(FilterInfo(attributedTitle: title.appliedFilterTitle(),
                                    mode: .common,
                                    filterType: .bedrooms))
        }

        if let bathrooms = bathroomsCount, bathrooms != 0 {
            let plural = "\(bathrooms) " + L10n.CreateListing.Details.Bathrooms.title.lowercased()
            let singular = "\(bathrooms) " + L10n.CreateListing.Details.Bathrooms.Title.singular.lowercased()
            let title = bathrooms == 1 ? singular : plural
            infos.append(FilterInfo(attributedTitle: title.appliedFilterTitle(),
                                    mode: .common,
                                    filterType: .bathrooms))
        }

        if let floors = totalFloorsCount, floors != 0 {
            let plural = "\(floors) " + L10n.Filters.Applied.floors
            let singular = "\(floors) " + L10n.Filters.Applied.Floors.singular
            let title = floors == 1 ? singular : plural
            infos.append(FilterInfo(attributedTitle: title.appliedFilterTitle(),
                                    mode: .common,
                                    filterType: .totalFloors))
        }

        if let floors = floorNumber, floors != 0 {
            let title = L10n.ListingDetails.FloorNumber.text(floors)
            infos.append(FilterInfo(attributedTitle: title.appliedFilterTitle(),
                                    mode: .common,
                                    filterType: .floorNumber))
        }

        if let slots = parkingSlotsCount, slots != 0 {
            let plural = L10n.Filters.parkingSlots(slots)
            let singular = L10n.Filters.ParkingSlots.singular(slots)
            let title = slots == 1 ? singular : plural
            infos.append(FilterInfo(attributedTitle: title.appliedFilterTitle(),
                                    mode: .common,
                                    filterType: .parkingSlots))
        }

        if parkingForVisits {
            infos.append(FilterInfo(attributedTitle: L10n.ListingDetails.ParkingForVisitors.text.appliedFilterTitle(),
                                    mode: .common,
                                    filterType: .parkingForVisitors))
        }

        if !facilityIds.isEmpty {
            let title = "\(facilityIds.count) " + L10n.CreateListing.Facilities.title.capitalized
            infos.append(FilterInfo(attributedTitle: title.appliedFilterTitle(),
                                    mode: .common,
                                    filterType: .facilities))
        }

        return infos
    }

    mutating func removeFilter(for filterType: FilterType) {
        switch filterType {
        case .listingType:
            listingType = nil

        case .propertyType:
            propertyType = nil

        case .priceRange:
            priceStart = nil
            priceEnd = nil

        case .totalArea:
            totalAreaFrom = nil
            totalAreaTo = nil

        case .builtArea:
            builtAreaFrom = nil
            builtAreaTo = nil

        case .yearOfConstruction:
            yearTo = nil
            yearFrom = nil

        case .bedrooms:
            bedroomsCount = nil

        case .bathrooms:
            bathroomsCount = nil

        case .totalFloors:
            totalFloorsCount = nil

        case .floorNumber:
            floorNumber = nil

        case .parkingSlots:
            parkingSlotsCount = nil

        case .parkingForVisitors:
            parkingForVisits = false

        case .facilities:
            facilityIds.removeAll()
        }
    }

}
