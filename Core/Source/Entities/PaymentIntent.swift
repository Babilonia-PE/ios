//
//  PaymentIntent.swift
//  Core
//
//  Created by Emily L. on 10/24/21.
//  Copyright © 2021 Yalantis. All rights reserved.
//

import Foundation

public struct PaymentIntent: Codable {
    
    public let orderId: Int
    public let deviceSessionId: String
    public let paymentIntentId: String
}
