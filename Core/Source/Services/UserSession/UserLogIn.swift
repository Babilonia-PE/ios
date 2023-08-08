//
//  UserLogIn.swift
//  Core
//
//  Created by Owson on 1/12/22.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

public struct UserLogIn: Codable {
    public var tokens: UserLogInTokens?
    
    enum CodingKeys: String, CodingKey {
        case tokens
    }
    
    public init(
        tokens: UserLogInTokens?
    ) {
        self.tokens = tokens
    }
}

public struct UserLogInTokens: Codable {
    
    public var type: String?
    public var authentication: String?
    public var userId: Int?
    
    public init(
        type: String?,
        authentication: String?,
        userId: Int?
    ) {
        self.type = type
        self.authentication = authentication
        self.userId = userId
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case authentication
        case userId
    }
    
}
