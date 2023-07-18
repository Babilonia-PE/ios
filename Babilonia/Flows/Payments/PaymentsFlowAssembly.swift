//
//  PaymentsFlowAssembly.swift
//  Babilonia
//
//  Created by Alya Filon  on 27.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation
import Swinject
import Core

final class PaymentsFlowAssembly: Assembly {

    func assemble(container: Container) {
        assembleServices(container)

        container
            //swiftlint:disable:next line_length
            .register(PaymentsProfileViewController.self) { (_, eventNode: EventNode, listing: Listing?, isPresented: Bool) in
                let model = PaymentsProfileModel(parent: eventNode, listing: listing)
                let viewModel = PaymentsProfileViewModel(model: model)

                return PaymentsProfileViewController(viewModel: viewModel, isPresented: isPresented)
            }
            .inObjectScope(.transient)

        container
            .register(PaymentsPlanViewController.self) { (resolver, eventNode: EventNode, value: ListingPaymentValue) in
                let model = PaymentsPlanModel(parent: eventNode,
                                              paymentService: resolver.autoresolve(),
                                              value: value)
                let viewModel = PaymentsPlanViewModel(model: model)

                return PaymentsPlanViewController(viewModel: viewModel)
            }
            .inObjectScope(.transient)

        container
            //swiftlint:disable:next line_length
            .register(PaymentsPeriodViewController.self) { (resolver, eventNode: EventNode, planModel: PaymentPlanContentModel, value: ListingPaymentValue) in
                let model = PaymentsPeriodModel(parent: eventNode,
                                                paymentService: resolver.autoresolve(),
                                                planModel: planModel,
                                                value: value)
                let viewModel = PaymentsPeriodViewModel(model: model)

                return PaymentsPeriodViewController(viewModel: viewModel)
            }
            .inObjectScope(.transient)

        container
            .register(CheckoutViewController.self) { (resolver, eventNode: EventNode, model: ListingPaymentModel) in
                let model = CheckoutModel(parent: eventNode,
                                          model: model,
                                          paymentService: resolver.autoresolve(),
                                          listingsService: resolver.autoresolve())
                let viewModel = CheckoutViewModel(model: model)

                return CheckoutViewController(viewModel: viewModel)
            }
            .inObjectScope(.transient)
    }

    // MARK: - Services

    private func assembleServices(_ container: Container) {
        container
            .autoregister(PaymentService.self, initializer: PaymentService.init)
            .inObjectScope(.container)
        container
            .autoregister(ListingsService.self, initializer: ListingsService.init)
            .inObjectScope(.container)
    }
}
