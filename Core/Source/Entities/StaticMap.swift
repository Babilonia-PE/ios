//
//  StaticMap.swift
//  Core
//
//  Created by Emily L. on 7/15/21.
//  Copyright © 2021 Babilonia. All rights reserved.
//

import Foundation

public struct StaticMap: Codable {
    public let url: String

    enum CodingKeys: String, CodingKey {
        case url
    }
}
