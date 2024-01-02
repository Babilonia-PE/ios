//
//  NewVersion.swift
//  Core
//
//  Created by Brayan Munoz Campos on 23/08/23.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import Foundation

public struct NewVersion: Codable {
    
    public var update: Bool?

    public init(update: Bool) {
        self.update = update
    }
    
    enum CodingKeys: String, CodingKey {
        case update = "ios"
    }
}

