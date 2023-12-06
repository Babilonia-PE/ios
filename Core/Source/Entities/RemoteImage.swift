//
//  RemoteImage.swift
//  Core
//
//  Created by Denis on 5/31/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

public struct RemoteImage: Codable {
    
    public let originalURLString: String?
    public let smallURLString: String?
    public let mediumURLString: String?
    public let largeURLString: String?
    
    // 55547 TODO: - Remote this init
    public init(
        originalURLString: String?,
        smallURLString: String?,
        mediumURLString: String?,
        largeURLString: String?
    ) {
        self.originalURLString = originalURLString
        self.smallURLString = smallURLString
        self.mediumURLString = mediumURLString
        self.largeURLString = largeURLString
    }

    enum CodingKeys: String, CodingKey {
        case originalURLString = "url"
        case smallURLString = "urlMin"
        case mediumURLString = "urlMiddle"
        case largeURLString = "urlLarge"
    }
    
    public var renderURLString: String? {
        return self.originalURLString
    }
}
