//
//  UserDelete.swift
//  Core
//
//  Created by Owson on 31/03/23.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import Foundation

public struct UserDelete: Codable {
    public var message: String?
    public var status: String?
    public var action: String?
    
    public init(
        message: String?,
        status: String?,
        action: String?
    ) {
        self.message = message
        self.status = status
        self.action = action
    }
}
