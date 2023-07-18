//
//  InlinePropertiesInfo.swift
//  Babilonia
//
//  Created by Denis on 7/19/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit.UIColor
import Core

struct InlinePropertiesInfo {
    let strings: [String]
    let attributedStrings: [NSAttributedString]
    let color: UIColor

    init(strings: [String] = [],
         attributedStrings: [NSAttributedString] = [],
         color: UIColor = Asset.Colors.almostBlack.color) {
        self.strings = strings
        self.attributedStrings = attributedStrings
        self.color = color
    }
}

enum InlinePropertiesConfig {
    case list(Listing), details(Listing), annotation(Listing), areas(Listing)
}

private enum InlinePropertiesFormat {
    case shorten, full
}

private enum InlinePropertiesFields {
    case bedrooms, bathrooms, parkingSlots, parkingForVisitors, area, coveredArea

    var title: String? {
        switch self {
        case .area:
            return L10n.ListingDetails.TotalArea.text
        case .coveredArea:
            return L10n.ListingDetails.CoveredArea.text
        default: return nil
        }
    }
}

private extension InlinePropertiesConfig {
    
    var fields: [InlinePropertiesFields] {
        switch self {
        case .details:
            return [.bedrooms, .bathrooms, .parkingSlots, .parkingForVisitors]
        case .list:
            return [.bedrooms, .bathrooms, .area]
        case .annotation:
            return [.bedrooms, .bathrooms]
        case .areas:
            return [.area, .coveredArea]
        }
    }
    
    var format: InlinePropertiesFormat {
        switch self {
        case .details, .areas:
            return .full
        case .list, .annotation:
            return .shorten
        }
    }
    
    var color: UIColor {
        switch self {
        case .details, .areas:
            return Asset.Colors.almostBlack.color
        case .list, .annotation:
            return Asset.Colors.trout.color
        }
    }
    
}

private extension InlinePropertiesFields {
    
    func formatted(from listing: Listing, as format: InlinePropertiesFormat) -> String? {
        switch self {
        case .bedrooms:
            guard let value = listing.bedroomsCount, value > 0 else { return nil }
            switch format {
            case .shorten:
                return L10n.MyListings.Bedrooms.abbreviation(value)
            case .full:
                let singular = L10n.ListingDetails.Bedrooms.Text.singular(value)
                let plural = L10n.ListingDetails.Bedrooms.text(value)

                return value == 1 ? singular : plural
            }
        case .bathrooms:
            guard let value = listing.bathroomsCount, value > 0 else { return nil }
            switch format {
            case .shorten:
                return L10n.MyListings.Bathrooms.abbreviation(value)
            case .full:
                let singular = L10n.ListingDetails.Bathrooms.Text.singular(value)
                let plural = L10n.ListingDetails.Bathrooms.text(value)

                return value == 1 ? singular : plural
            }
        case .parkingSlots:
            guard let value = listing.parkingSlotsCount, value > 0 else { return nil }
            switch format {
            case .shorten:
                return L10n.MyListings.ParkingSlots.abbreviation(value)
            case .full:
                let singular = L10n.Filters.ParkingSlots.singular(value)
                let plural = L10n.Filters.parkingSlots(value)

                return value == 1 ? singular : plural
            }
        case .parkingForVisitors:
            guard let value = listing.parkingForVisits, value else { return nil }
            switch format {
            case .shorten:
                return nil
            case .full:
                return L10n.ListingDetails.ParkingForVisitors.text
            }
        case .area:
            guard let area = listing.area, area > 0 else { return nil }

            return L10n.MyListings.Area.abbreviation("\(area)".commaConverted())
        case .coveredArea:
            guard let coveredArea = listing.coveredArea, coveredArea > 0 else { return nil }

            return L10n.MyListings.Area.abbreviation("\(coveredArea)".commaConverted())
        }
    }

    func attributeFormatted(from listing: Listing, as format: InlinePropertiesFormat) -> NSAttributedString? {
        switch self {
        case .area:
            guard let area = listing.area, area > 0, let title = title else { return nil }
            let string = "\(area)".commaConverted()

            return L10n.MyListings.Area.abbreviation(string).inlineProperty(title: title + " ")
        case .coveredArea:
            guard let coveredArea = listing.coveredArea, coveredArea > 0, let title = title else { return nil }
            let string = "\(coveredArea)".commaConverted()

            return L10n.MyListings.Area.abbreviation(string).inlineProperty(title: title + " ")

        default:
            return nil
        }
    }
    
}

extension InlinePropertiesConfig {
    
    var info: InlinePropertiesInfo {
        switch self {
        case .list(let listing), .details(let listing), .annotation(let listing):
            return InlinePropertiesInfo(
                strings: fields.compactMap { $0.formatted(from: listing, as: format) },
                attributedStrings: [],
                color: color
            )

        case .areas(let listing):
            return InlinePropertiesInfo(
                strings: [],
                attributedStrings: fields.compactMap { $0.attributeFormatted(from: listing, as: format) },
                color: color
            )
        }
    }
    
}
