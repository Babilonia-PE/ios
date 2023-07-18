//
//  Currency.swift
//  Core
//
//  Created by Anna Sahaidak on 7/22/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

public struct Currency {
    
    public let title: String
    public let symbol: String
    public let code: String
    public var rate: Double
    
    public init(title: String, symbol: String, code: String, rate: Double = 0) {
        self.title = title
        self.symbol = symbol
        self.code = code
        self.rate = rate
    }
    
}
