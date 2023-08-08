//
//  FacilitiesRequests.swift
//  Core
//
//  Created by Denis on 6/14/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import YALAPIClient

public enum FacilitiesType: String, Codable {
    case facility
    case advancedDetail = "advanced_detail"
}

struct FetchFacilitiesRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .get
    var path: String {
        "public/listing_amenities/\(type.rawValue)"
    }
    let authRequired: Bool = true
    private(set) var parameters: [String: Any]?
    private let type: FacilitiesType
    
    init(propertyType: PropertyType, type: FacilitiesType) {
        self.parameters = ["data": ["property_type": propertyType.rawValue]]
        self.type = type
    }
    
}
