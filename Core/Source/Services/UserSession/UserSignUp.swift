//
//  SignUp.swift
//  Core
//
//  Created by Owson on 18/11/22.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation


public struct UserSignUp: Codable {
    public var message: String?
    public var status: String?
    public var action: String?
    public var authorization: String?
    public var userId: Int?
    
    public init(
        message: String?,
        status: String?,
        action: String?,
        authorization: String?,
        userId: Int?
    ) {
        self.message = message
        self.status = status
        self.action = action
        self.authorization = authorization
        self.userId = userId
    }
}
