//
//  Location.swift
//  Core
//
//  Created by Denis on 6/24/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

public struct Location: Codable {
    
    public var id: String = UUID().uuidString
    public var address: String?
    public let latitude: Float
    public let longitude: Float
    
    public init(id: String = UUID().uuidString, address: String?, latitude: Float, longitude: Float) {
        self.id = id
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
    
    enum CodingKeys: String, CodingKey {
        case address
        case latitude
        case longitude
    }
}
