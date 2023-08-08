//
//  CurrencyRate.swift
//  Core
//
//  Created by Owson on 9/03/23.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import Foundation

public struct CurrencyRate: Codable {
    public let tc: Double
    
    public init(tc: Double) {
        self.tc = tc
    }
}
