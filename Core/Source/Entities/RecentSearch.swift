//
//  RecentSearch.swift
//  Core
//
//  Created by Alya Filon  on 28.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation

public struct RecentSearch: Codable {

    public let queryString: String?
    public let googlePlacesLocationId: String?
    public let location: AutoCompleteSearchLocation?

    public init(queryString: String, googlePlacesLocationId: String, location: AutoCompleteSearchLocation) {
        self.queryString = queryString
        self.googlePlacesLocationId = googlePlacesLocationId
        self.location = location
    }
    
    enum CodingKeys: String, CodingKey {
        case queryString = "query_string"
        case googlePlacesLocationId = "google_places_location_id"
        case location
    }

}

public struct RecentSearchLocation: Codable {

    public let queryString: String
    public let googlePlacesLocationId: String?

    public init(queryString: String, googlePlacesLocationId: String) {
        self.queryString = queryString
        self.googlePlacesLocationId = googlePlacesLocationId
    }

}
