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
    public let country: String?
    public var department: String?
    public var province: String?
    public var district: String?
    public var zipCode: String?

    public init(id: String = UUID().uuidString, address: String?, latitude: Float, longitude: Float, country: String?,
                department: String?, province: String?, district: String?, zipCode: String?) {
        self.id = id
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.country = country
        self.department = department
        self.province = province
        self.district = district
        self.zipCode = zipCode
    }
    
    enum CodingKeys: String, CodingKey {
        case address
        case latitude
        case longitude
        case country
        case department
        case province
        case district
        case zipCode
    }
}
