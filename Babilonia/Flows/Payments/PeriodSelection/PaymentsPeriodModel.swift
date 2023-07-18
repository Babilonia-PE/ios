//
//  PaymentsPeriodModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 27.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Core

enum PaymentsPeriodEvent: Event {
    case checkout(model: ListingPaymentModel)
}

final class PaymentsPeriodModel: EventNode {

    let planModel: PaymentPlanContentModel
    private let value: ListingPaymentValue
    private let paymentService: PaymentService

    init(parent: EventNode,
         paymentService: PaymentService,
         planModel: PaymentPlanContentModel,
         value: ListingPaymentValue) {
        self.planModel = planModel
        self.value = value
        self.paymentService = paymentService

        super.init(parent: parent)
    }

    func chechout(with period: PaymentPeriodContentModel) {
        let model = ListingPaymentModel(listing: value.listing,
                                        role: value.role,
                                        period: period)

        raise(event: PaymentsPeriodEvent.checkout(model: model))
    }

}
