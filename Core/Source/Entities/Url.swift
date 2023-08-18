//
//  Url.swift
//  Core
//
//  Created by Brayan Munoz Campos on 11/08/23.
//  Copyright © 2023 Yalantis. All rights reserved.
//

public struct Url: Codable {
    
    public let main: String?
    public let share: String?
    
    public init(main: String? = nil, share: String? = nil) {
        self.main = main
        self.share = share
    }
    
    enum CodingKeys: String, CodingKey {
        case main, share
    }
}

