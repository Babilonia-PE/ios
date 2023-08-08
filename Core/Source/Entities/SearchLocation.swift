//
//  AutoCompleteSearchLocation.swift
//  Core
//
//  Created by Emily L. on 7/15/21.
//  Copyright © 2021 Babilonia. All rights reserved.
//

import Foundation

public struct AutoCompleteSearchLocation: Codable {
    
    public var address: String?
    public let country: String?
    public var department: String?
    public var province: String?
    public var district: String?

    public init(address: String?, country: String?,
                department: String?, province: String?, district: String?) {
        self.address = address
        self.country = country
        self.department = department
        self.province = province
        self.district = district
    }
    
    enum CodingKeys: String, CodingKey {
        case address
        case country
        case department
        case province
        case district
    }
    
    public func toSearchLocation() -> SearchLocation {
        return SearchLocation(address: address ?? "",
                              country: country ?? "",
                              department: department ?? "",
                              province: province ?? "",
                              district: district ?? "")
    }
}

public struct SearchLocation {
    public var address: String
    public let country: String
    public var department: String
    public var province: String
    public var district: String
    
    public var addressField: String {
        if address.isEmpty {
            var names: [String] = []
            if !district.isEmpty {
                names.append(district)
            }
            if !province.isEmpty {
                names.append(province)
            }
            if !department.isEmpty {
                names.append(department)
            }
            
            return names.joined(separator: ", ")
        } else {
            return address
        }
    }
    
    public init (address: String,
                 country: String,
                 department: String,
                 province: String,
                 district: String) {
        self.address = address
        self.country = country
        self.department = department
        self.province = province
        self.district = district
    }
}
