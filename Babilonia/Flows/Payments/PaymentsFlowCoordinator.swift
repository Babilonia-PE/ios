//
//  PaymentsFlowCoordinator.swift
//  Babilonia
//
//  Created by Alya Filon  on 27.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation
import Swinject

final class PaymentsFlowCoordinator: EventNode, FlowCoordinator {

    weak var containerViewController: UIViewController?
    private let container: Container
    private let listing: Listing?
    private let isPresented: Bool

    init(container: Container, parent: EventNode, listing: Listing?, isPresented: Bool = false) {
        self.container = Container(parent: container) { (container: Container) in
            PaymentsFlowAssembly().assemble(container: container)
        }
        self.listing = listing
        self.isPresented = isPresented

        super.init(parent: parent)

        addHandlers()
    }

    func createFlow() -> UIViewController {
        let controller: PaymentsProfileViewController = container.autoresolve(arguments: self,
                                                                              listing,
                                                                              isPresented)
        controller.navigationItem.backButtonTitle = ""
        containerViewController = controller

        return controller
    }

    private func presentPlanSelection(value: ListingPaymentValue) {
        let controller: PaymentsPlanViewController = container.autoresolve(arguments: self, value)

        containerViewController?.navigationController?.pushViewController(controller, animated: true)
    }

    private func presentPeriodSelection(planModel: PaymentPlanContentModel, value: ListingPaymentValue) {
        let controller: PaymentsPeriodViewController = container.autoresolve(arguments: self, planModel, value)

        containerViewController?.navigationController?.pushViewController(controller, animated: true)
    }

    private func presentCheckout(model: ListingPaymentModel) {
        let controller: CheckoutViewController = container.autoresolve(arguments: self, model)

        containerViewController?.navigationController?.pushViewController(controller, animated: true)
    }

    private func addHandlers() {
        addHandler { [weak self] (event: PaymentsProfileEvent) in self?.handle(event) }
        addHandler { [weak self] (event: PaymentsPlanEvent) in self?.handle(event) }
        addHandler { [weak self] (event: PaymentsPeriodEvent) in self?.handle(event) }
    }

    private func handle(_ event: PaymentsProfileEvent) {
        switch event {
        case .profileSelected(let value):
            presentPlanSelection(value: value)
        }
    }

    private func handle(_ event: PaymentsPlanEvent) {
        switch event {
        case .planSelected(let planModel, let value):
            presentPeriodSelection(planModel: planModel, value: value)
        }
    }

    private func handle(_ event: PaymentsPeriodEvent) {
        switch event {
        case .checkout(let model):
            presentCheckout(model: model)
        }
    }
    
}
