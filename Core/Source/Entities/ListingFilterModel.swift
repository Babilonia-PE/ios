//
//  ListingFilterModel.swift
//  Core
//
//  Created by Alya Filon  on 09.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation

public struct ListingFilterModel {

    public var listingType: ListingType = .sale
    public var propertyType: PropertyType?
    public var petFriendly: Bool = false
    public var totalAreaFrom: Int?
    public var totalAreaTo: Int?
    public var builtAreaFrom: Int?
    public var builtAreaTo: Int?
    public var priceStart: Int?
    public var priceEnd: Int?
    public var yearFrom: Int?
    public var yearTo: Int?
    public var bedroomsCount: Int?
    public var bathroomsCount: Int?
    public var totalFloorsCount: Int?
    public var floorNumber: Int?
    public var parkingSlotsCount: Int?
    public var parkingForVisits: Bool = false
    public var warehouse: Bool = false
    public var facilityIds = [Int]()
    public var areaInfo: FetchListingsAreaInfo?

    public init() { }

    func convertToJSON() -> [String: Any] {
        var parameters = [String: Any]()

        parameters["listing_type"] = listingType.rawValue
        parameters["property_type"] = propertyType?.rawValue
        parameters["pet_friendly"] = petFriendly.requestValue
        parameters["price_start"] = priceStart
        parameters["price_end"] = priceEnd
        parameters["year_of_construction"] = convertYear()
        parameters["total_area"] = convertTotalArea()
        parameters["built_area"] = convertBuiltArea()
        parameters["bedrooms_count"] = bedroomsCount == 0 ? nil : bedroomsCount
        parameters["bathrooms_count"] = bathroomsCount == 0 ? nil : bathroomsCount
        parameters["total_floors_count"] = totalFloorsCount == 0 ? nil : totalFloorsCount
        parameters["floor_number"] = floorNumber == 0 ? nil : floorNumber
        parameters["parking_slots_count"] = parkingSlotsCount == 0 ? nil : parkingSlotsCount
        parameters["parking_for_visits"] = parkingForVisits.requestValue
        parameters["warehouse"] = warehouse.requestValue
        parameters["facility_ids"] = facilityIds

        if let areaInfo = areaInfo {
            var area = [String: Any]()
            area["latitude"] = areaInfo.latitude
            area["longitude"] = areaInfo.longitude
            area["radius"] = areaInfo.radius

            parameters["area"] = area
        }

        return parameters
    }

    private func convertTotalArea() -> [String: Any]? {
        var parameters = [String: Any]()
        parameters["from"] = totalAreaFrom
        parameters["to"] = totalAreaTo

        return parameters.isEmpty ? nil : parameters
    }

    private func convertBuiltArea() -> [String: Any]? {
        var parameters = [String: Any]()
        parameters["from"] = builtAreaFrom
        parameters["to"] = builtAreaTo

        return parameters.isEmpty ? nil : parameters
    }

    private func convertYear() -> [String: Any]? {
        var parameters = [String: Any]()
        parameters["from"] = yearFrom
        parameters["to"] = yearTo

        return parameters.isEmpty ? nil : parameters
    }

}

private extension Bool {

    var requestValue: String {
        self ? "yes" : "any"
    }
}
