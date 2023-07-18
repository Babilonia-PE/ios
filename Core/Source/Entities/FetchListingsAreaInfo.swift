//
//  FetchListingsAreaInfo.swift
//  Core
//
//  Created by Alya Filon  on 11.01.2021.
//  Copyright © 2021 Yalantis. All rights reserved.
//

import Foundation

public struct FetchListingsAreaInfo {

    public static var empty: FetchListingsAreaInfo {
        FetchListingsAreaInfo(latitude: 0, longitude: 0, radius: 0)
    }

    public let latitude: Float
    public let longitude: Float
    public var radius: Float

    public init(latitude: Float, longitude: Float, radius: Float) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }

    func JSONRepresentation() -> [String: Any] {
        var dataJSON = [String: Any]()
        dataJSON["longitude"] = longitude
        dataJSON["latitude"] = latitude
        dataJSON["radius"] = radius

        return ["area": dataJSON]
    }

}

public struct FetchListingsPlaceInfo {

    public static var empty: FetchListingsPlaceInfo {
        FetchListingsPlaceInfo(searchPlace: "", placeID: "")
    }

    public let searchPlace: String
    public let placeID: String

    public init(searchPlace: String, placeID: String) {
        self.searchPlace = searchPlace
        self.placeID = placeID
    }
}
