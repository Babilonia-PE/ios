//
//  PaymentPlan.swift
//  Core
//
//  Created by Alya Filon  on 02.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation

public enum PaymentPlanKey: String, Codable {
    case standard, plus, premium
}

public struct PaymentPlan: Codable {

    public let planKey: PaymentPlanKey
    public let title: String
    public let descriptions: [String]
    public let products: [PaymentProduct]

    public init(planKey: PaymentPlanKey, title: String, descriptions: [String], products: [PaymentProduct]) {
        self.planKey = planKey
        self.title = title
        self.descriptions = descriptions
        self.products = products
    }

}
