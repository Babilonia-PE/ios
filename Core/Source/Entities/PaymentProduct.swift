//
//  PaymentProduct.swift
//  Core
//
//  Created by Alya Filon  on 02.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation

public struct PaymentProduct: Codable {

    public let key: String
    public let duration: Int
    public let price: Double
    public let comment: String

    public init(key: String, duration: Int, price: Double, comment: String) {
        self.key = key
        self.duration = duration
        self.price = price
        self.comment = comment
    }

}
