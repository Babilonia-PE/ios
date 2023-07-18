//
//  PaymentPlanContentModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 03.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import Core

struct PaymentPlanContentModel {

    var title: String {
        paymentPlan.title
    }

    var backgroundImage: UIImage {
        switch paymentPlan.planKey {
        case .standard: return Asset.Payments.standartPlanBackground.image
        case .plus: return Asset.Payments.plusPlanBackground.image
        case .premium: return Asset.Payments.premiumPlanBackground.image
        }
    }

    var baseColor: UIColor {
        switch paymentPlan.planKey {
        case .standard: return Asset.Colors.hippieBlue.color
        case .plus: return Asset.Colors.orange.color
        case .premium: return Asset.Colors.biscay.color
        }
    }

    var iconImage: UIImage? {
        switch paymentPlan.planKey {
        case .standard: return nil
        case .plus: return Asset.Payments.planPlusIconWhite.image
        case .premium: return Asset.Payments.planPremiumIconWhite.image
        }
    }

    var planItems: [String] {
        paymentPlan.descriptions
    }

    var fromPrice: String {
        guard let minPrice = paymentPlan.products.first?.price else { return "" }
        let convertedPrice = "\(minPrice)".priceSufixConverted()

        return L10n.Payments.Price.from(convertedPrice)
    }

    var key: PaymentPlanKey {
        paymentPlan.planKey
    }

    var periodItems = [PaymentPeriodContentModel]()

    private let paymentPlan: PaymentPlan

    init(paymentPlan: PaymentPlan) {
        self.paymentPlan = paymentPlan

        periodItems = paymentPlan.products.map { PaymentPeriodContentModel(paymentProduct: $0,
                                                                           planKey: paymentPlan.planKey)
        }
    }

}
