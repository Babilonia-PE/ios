//
//  SortOptionModels.swift
//  Babilonia
//
//  Created by Alya Filon  on 02.01.2021.
//  Copyright © 2021 Yalantis. All rights reserved.
//

import Foundation

enum SortOption: Int, CaseIterable {
    case newestToOldest
    case oldestToNewest
    case priceHighToLow
    case priceLowToHigh
    case m2PriceHighestToLowest
    case m2PriceLowestToHighest
    case areaHighestToLowest
    case areaLowestToHighest
   // case closestToFarthest //osemy
   // case farthestToClosest
    case mostRelevant
}

extension SortOption {

    var sortParam: String {
        switch self {
        case .priceLowToHigh, .priceHighToLow: return "price"
        case .newestToOldest, .oldestToNewest: return "created_at"
     //   case .closestToFarthest, .farthestToClosest: return "distance" //osemy
        case .areaHighestToLowest, .areaLowestToHighest: return "area"
        case .m2PriceHighestToLowest, .m2PriceLowestToHighest: return "m2price"
        case .mostRelevant: return "relevant_position"
        }
    }

    var directionParam: String {
        switch self {
        case .priceLowToHigh, .oldestToNewest,
             .areaLowestToHighest,
             .m2PriceLowestToHighest: return "asc"
        case .priceHighToLow, .newestToOldest,
             .areaHighestToLowest,
             .m2PriceHighestToLowest, .mostRelevant: return "desc"
            
//        case .priceLowToHigh, .oldestToNewest,
//             .closestToFarthest, .areaLowestToHighest,
//             .m2PriceLowestToHighest: return "asc"
//        case .priceHighToLow, .newestToOldest,
//             .farthestToClosest, .areaHighestToLowest,
//             .m2PriceHighestToLowest, .mostRelevant: return "desc"
        }
    }

    var title: String {
        switch self {
        case .priceLowToHigh: return L10n.Listing.SortOption.priceLowToHigh
        case .priceHighToLow: return L10n.Listing.SortOption.priceHighToLow
        case .newestToOldest: return L10n.Listing.SortOption.newestToOldest
        case .oldestToNewest: return L10n.Listing.SortOption.oldestToNewest
    //    case .closestToFarthest: return L10n.Listing.SortOption.closestToFarthest
    //    case .farthestToClosest: return L10n.Listing.SortOption.farthestToClosest
        case .areaHighestToLowest: return L10n.Listing.SortOption.areaHighestToLowest
        case .areaLowestToHighest: return L10n.Listing.SortOption.areaLowestToHighest
        case .m2PriceHighestToLowest: return L10n.Listing.SortOption.m2PriceHighestToLowest
        case .m2PriceLowestToHighest: return L10n.Listing.SortOption.m2PriceLowestToHighest
        case .mostRelevant: return L10n.Listing.SortOption.mostRelevant
        }
    }

}
