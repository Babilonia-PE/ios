//
//  VerifyToken.swift
//  Core
//
//  Created by Owson on 8/12/22.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

public struct VerifyToken: Codable {
    public var status: String?
    public var action: String?
    public var userId: Int?
}
