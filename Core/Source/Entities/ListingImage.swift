//
//  ListingImage.swift
//  Core
//
//  Created by Denis on 6/24/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

public struct ListingImage: Codable {
    
    public let id: Int
    public let photo: RemoteImage
    public let createdAt: String
    
    // 55547 TODO: - Remove this init.
    public init(id: Int, photo: RemoteImage, createdAt: String) {
        self.id = id
        self.photo = photo
        self.createdAt = createdAt
    }

}
