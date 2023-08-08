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
    var country: String?
    var department: String?
    var province: String?
    var district: String?
    var zipCode: String?

}

enum PropertyDetailsType: CaseIterable {
    case bedrooms, bathrooms, totalFloors, floorNumber, parkingSlots, parkingForVisitors, petFriendly
}

enum PropertyDetailsDisplayType {
    case numberControl, checkboxControl
}

enum PropertyCommonType: Int, CaseIterable {
    case propertyType = 0, address, country, department, province, district, description, price, totalArea, coveredArea, yearOfConstraction
}
