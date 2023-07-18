//
//  PaymentsPlanModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 27.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Core
import RxCocoa
import RxSwift

enum PaymentsPlanEvent: Event {
    case planSelected(planModel: PaymentPlanContentModel, value: ListingPaymentValue)
}

final class PaymentsPlanModel: EventNode {

    let requestState = PublishSubject<RequestState>()
    let plans = BehaviorRelay<[PaymentPlan]>(value: [])

    private let paymentService: PaymentService
    private let value: ListingPaymentValue

    init(parent: EventNode, paymentService: PaymentService, value: ListingPaymentValue) {
        self.paymentService = paymentService
        self.value = value

        super.init(parent: parent)
    }

    func selectPlan(_ model: PaymentPlanContentModel) {
        raise(event: PaymentsPlanEvent.planSelected(planModel: model, value: value))
    }

    func getPaymentPlan() {
        requestState.onNext(.started)
        paymentService.getPaymentPlan { [weak self] result in
            switch result {
            case .success(let plans):
                self?.requestState.onNext(.finished)
                self?.plans.accept(plans)

            case .failure(let error):
                self?.requestState.onNext(.failed(error))
                self?.plans.accept([])
            }
        }
    }

}
