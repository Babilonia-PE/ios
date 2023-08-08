//
//  Facility.swift
//  Core
//
//  Created by Denis on 6/14/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

public struct Facility: Codable {
    
    public let id: Int
    public let key: String
    public let title: String
    public let icon: RemoteImage?
    public let iconIos: RemoteImage?
    public var propertyTypes: [PropertyType]?

    enum CodingKeys: String, CodingKey {
        case icon
        case iconIos
        case key
        case title
        case id 
    }

}

extension Facility: Equatable {

    public static func == (lhs: Facility, rhs: Facility) -> Bool {
        lhs.id == rhs.id
    }

}
