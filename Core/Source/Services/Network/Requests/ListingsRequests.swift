//
//  ListingsRequests.swift
//  Core
//
//  Created by Anna Sahaidak on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import YALAPIClient
import CoreLocation
import Alamofire

struct FetchMyListingsRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .get
    var path = "me/listing/listings"
    let authRequired: Bool = true
    private(set) var parameters: [String: Any]?
    
    init(page: Int, state: String) {
        parameters = [
            "page": page,
            "per_page": 1500,
            "publisher_role": "all",
            "listing_type": "all",
            "property_type": "all",
            "state": state
        ]
    }
}

struct GetMyListingRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .get
    var path: String {
        "me/listing/detail?id=\(listingID)"
    }
    let authRequired = true

    private let listingID: String

    init(listingID: String) {
        self.listingID = listingID
    }
}

struct CreateListingRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .post
    var path = "me/validation_data"
    let authRequired: Bool = true
    var encoding: APIRequestEncoding? = JSONEncoding.default
    private(set) var parameters: [String: Any]?
    
    init(listing: Listing, photosInfo: CreateListingPhotosInfo) {
        parameters = listing.JSON(with: photosInfo)
    }
    
}

struct UpdateListingRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .put
    let path: String
    let authRequired: Bool = true
    var encoding: APIRequestEncoding? = JSONEncoding.default
    private(set) var parameters: [String: Any]?
    
    init(listing: Listing, photosInfo: CreateListingPhotosInfo) {
        path = "me/validation_data"
        parameters = listing.JSON(with: photosInfo)
    }
    
}

struct FetchAllListingsRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .get
    let path = "public/listings"
    let authRequired = true
    private(set) var parameters: [String: Any]?
    
    init(areaInfo: FetchListingsAreaInfo? = nil,
         sort: String?,
         direction: String?,
         filters: ListingFilterModel? = nil,
         placeInfo: FetchListingsPlaceInfo?,
         perPage: Int = 25,
         page: Int = 1) {
        var params = [String: Any]()

        if let areaInfo = areaInfo {
            params = areaInfo.JSONRepresentation()
        }
        print("FetchListingsAreaInfo = \(params)")

        if let sort = sort {
            params["sort"] = sort
        }
        
        if let direction = direction {
            params["direction"] = direction
        }

        if var filters = filters {
            filters.areaInfo = areaInfo
            params.merge(filters.convertToJSON()) { (_, second) in second }
        }

        if let placeInfo = placeInfo, !placeInfo.placeID.isEmpty, !placeInfo.searchPlace.isEmpty {
            params["query_string"] = placeInfo.searchPlace
            params["google_places_location_id"] = placeInfo.placeID
        }
        params["per_page"] = perPage
        params["page"] = page
        
        parameters = params
    }

}

struct FetchAllListingsAddressRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .get
    let path = "public/listings"
    let authRequired = true
    private(set) var parameters: [String: Any]?
    
    init(searchLocation: SearchLocation,
         sort: String?,
         direction: String?,
         filters: ListingFilterModel? = nil,
         perPage: Int = 25,
         page: Int = 1) {
        var params = [String: Any]()

        if !searchLocation.address.isEmpty {
            params["location[address]"] = searchLocation.address
        }
        
        if !searchLocation.country.isEmpty {
            params["location[country]"] = searchLocation.country
        }
        if !searchLocation.department.isEmpty {
            params["location[department]"] = searchLocation.department
        }
        
        if !searchLocation.province.isEmpty {
            params["location[province]"] = searchLocation.province
        }
        
        if !searchLocation.district.isEmpty {
            params["location[district]"] = searchLocation.district
        }
        
        if let sort = sort {
            params["sort"] = sort
        }
        
        if let direction = direction {
            params["direction"] = direction
        }
        
        if var filters = filters {
            filters.searchLocation = searchLocation
            params.merge(filters.convertToJSON()) { (_, second) in second }
        }

        params["per_page"] = perPage
        params["page"] = page
        
        parameters = params
    }

}

struct ListingDetailsRequest: APIRequest, DecoratableRequest {

    let method: APIRequestMethod = .get
    var path: String {
        "public/listing/detail?id=\(listingID)"
    }
    let authRequired = true

    private let listingID: String

    init(listingID: String) {
        self.listingID = listingID
    }

}

struct ListingSearchMetadataRequest: APIRequest, DecoratableRequest {

    let method: APIRequestMethod = .get
    var path: String {
        "public/search_metadata"
    }
    let authRequired = false
    private(set) var parameters: [String: Any]?

    init(listingFilterModel: ListingFilterModel) {
        parameters = listingFilterModel.convertToJSON()
    }

}

struct ListingPriceHistogramRequest: APIRequest, DecoratableRequest {

    let method: APIRequestMethod = .get
    var path: String {
        "listings/prices_histogram_slots"
    }
    let authRequired = true
    private(set) var parameters: [String: Any]?

    init(listingFilterModel: ListingFilterModel) {
        parameters = listingFilterModel.convertToJSON()
    }

}

struct TopListingsRequest: APIRequest, DecoratableRequest {

    let method: APIRequestMethod = .get
    var path: String {
        "public/last_viewed_listings"
    }
    let authRequired = true
    private(set) var parameters: [String: Any]?

    init(areaInfo: FetchListingsAreaInfo? = nil) {
        if let areaInfo = areaInfo {
            parameters = areaInfo.JSONFlatRepresentation()
        }
    }

}

private extension Listing {

    //swiftlint:disable:next cyclomatic_complexity
    func JSON(with photosInfo: CreateListingPhotosInfo) -> [String: Any] {
        var dataJSON = [String: Any]()

        // General step listing creation
        if !isEdit {
            dataJSON["status"] = status == .visible ? status.rawValue : ListingStatus.hidden.rawValue
        }
        dataJSON["source"] = "ios"
        dataJSON["id"] = id
        dataJSON["listing_type"] = (listingType ?? .sale).rawValue
        dataJSON["property_type"] = (propertyType ?? .apartment).rawValue

        if let location = location {
            var locationJSON = [String: Any]()
            if let address = location.address {
                locationJSON["address"] = address
            }
            locationJSON["latitude"] = location.latitude
            locationJSON["longitude"] = location.longitude
            if let country = location.country {
                locationJSON["country"] = country
            }
            if let department = location.department {
                locationJSON["department"] = department
            }
            if let province = location.province {
                locationJSON["province"] = province
            }
            if let district = location.district {
                locationJSON["district"] = district
            }
            if let zipCode = location.zipCode {
                locationJSON["zipCode"] = zipCode
            }
            dataJSON["location_attributes"] = locationJSON
        }

        dataJSON["description"] = listingDescription
        if let price = price {
            dataJSON["price"] = price
        }
        if let area = area {
            dataJSON["area"] = area
        }
        if let coveredArea = coveredArea {
            dataJSON["built_area"] = coveredArea
        }
        if let yearOfConstruction = yearOfConstruction, yearOfConstruction != 0 {
            dataJSON["year_of_construction"] = yearOfConstruction
        }

        // Details step listing creation
        if propertyType != .office, let bedroomsCount = bedroomsCount {
            dataJSON["bedrooms_count"] = bedroomsCount
        }
        if let bathroomsCount = bathroomsCount {
            dataJSON["bathrooms_count"] = bathroomsCount
        }
        if let totalFloors = totalFloorsCount {
            dataJSON["total_floors_count"] = totalFloors
        }
        if let floorNumber = floorNumber {
            dataJSON["floor_number"] = floorNumber
        }
        if let parkingSlotsCount = parkingSlotsCount {
            dataJSON["parking_slots_count"] = parkingSlotsCount
        }
        if let parkingForVisits = parkingForVisits {
            dataJSON["parking_for_visits"] = parkingForVisits
        }
        if let petFriendly = petFriendly {
            dataJSON["pet_friendly"] = petFriendly
        }

        // Facilities step listing creation

        if let facilities = facilities {
            dataJSON["facility_ids"] = facilities.map { $0.id }
        }

        // Advanced step listing creation

        if let advancedDetails = advancedDetails {
            dataJSON["advanced_detail_ids"] = advancedDetails.map { $0.id }
        }

        // Photos step listing creation

        dataJSON["primary_image_id"] = photosInfo.primaryImageID
        dataJSON["image_ids"] = photosInfo.imageIDs
        
        // Contact
        if let contacts = contacts {
            dataJSON["contact_name"] = contacts.first?.contactName
            dataJSON["contact_email"] = contacts.first?.contactEmail
            dataJSON["contact_phone"] = contacts.first?.contactPhone
        }
        
#if DEBUG
        print("dataJSON = \(dataJSON)")
#endif
        return dataJSON
    }
    
}
