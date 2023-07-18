//
//  ListingPropertyTypes.swift
//  Babilonia
//
//  Created by Denis on 6/12/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation
import Core

typealias ListingType = Core.ListingType
typealias PropertyType = Core.PropertyType

struct MapAddress {
    var title: String?
    var coordinate: CLLocationCoordinate2D
}

enum PropertyDetailsType: CaseIterable {
    case bedrooms, bathrooms, totalFloors, floorNumber, parkingSlots, parkingForVisitors, petFriendly
}

enum PropertyDetailsDisplayType {
    case numberControl, checkboxControl
}

enum PropertyCommonType: Int, CaseIterable {
    case propertyType = 0, address, description, price, totalArea, coveredArea, yearOfConstraction
}
