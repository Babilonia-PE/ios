//
//  MyListingsFlowCoordinator.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 6/26/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject
import Core

protocol MyListingsAlertPresentable: class {
    func showAlert(_ message: String)
}

final class MyListingsFlowCoordinator: EventNode, FlowCoordinator {
    
    weak var containerViewController: UIViewController?
    weak var listingDetailsNavigationController: UINavigationController?
    private weak var alertPresentableDelegate: MyListingsAlertPresentable?

    private let container: Container
    
    init(container: Container, parent: EventNode) {
        self.container = Container(parent: container) { (container: Container) in
            MyListingsFlowAssembly().assemble(container: container)
        }
        
        super.init(parent: parent)
        
        addHandlers()
    }
    
    @discardableResult
    func createFlow() -> UIViewController {
        let model: MyListingsModel = container.autoresolve(argument: self)
        let controller = MyListingsViewController(viewModel: MyListingsViewModel(model: model))
        alertPresentableDelegate = model

        return controller
    }
    
    // MARK: - private
    
    private func showCreateListingFlow(_ listing: Listing?, mode: ListingFillMode) {
        let coordinator: CreateListingFlowCoordinator = container.autoresolve(
            arguments: self, container, listing, mode
        )
        let controller = coordinator.createFlow()

        if listingDetailsNavigationController != nil {
            coordinator.containerViewController = listingDetailsNavigationController
            listingDetailsNavigationController?.pushViewController(controller, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: controller)
            coordinator.containerViewController = navigationController
            navigationController.modalPresentationStyle = .fullScreen
            containerViewController?.present(navigationController, animated: true, completion: nil)
        }
    }

    private func presentListingDetail(for listing: Listing, state: RequestState? = nil) {
        let controller: CommonListingDetailsViewController = container.autoresolve(arguments: self,
                                                                                   listing,
                                                                                   state)
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        listingDetailsNavigationController = navigationController

        containerViewController?.present(navigationController, animated: true, completion: nil)
    }

    private func presentPaymentFlow(listing: Listing?) {
        let controller = PaymentsFlowCoordinator(container: container,
                                                 parent: self,
                                                 listing: listing,
                                                 isPresented: true).createFlow()

        containerViewController?.navigationItem.backButtonTitle = ""
        let paymentNavigationController = UINavigationController(rootViewController: controller)
        paymentNavigationController.modalPresentationStyle = .fullScreen

        if let navigationController = containerViewController?.presentedViewController as? UINavigationController {
            navigationController.pushViewController(controller, animated: true)
        } else {
            containerViewController?.present(paymentNavigationController, animated: true, completion: nil)
        }
    }

    private func presentListingDescription(_ descriptionString: String) {
        let controller: ListingDetailsDescriptionViewController = container.autoresolve(
            arguments: self, descriptionString
        )
        listingDetailsNavigationController?.pushViewController(controller, animated: true)
    }

    private func presentListingDetailsMap(with location: Location, propertyType: PropertyType?) {
        let controller: ListingLocationMapViewController = container.autoresolve(
            arguments: self, location, propertyType
        )
        listingDetailsNavigationController?.pushViewController(controller, animated: true)
    }

    private func presentPhotoGalleryController(config: ListingDetailsModelConfig) {
        let controller: PhotoGalleryViewController = container.autoresolve(arguments: self, config)
        listingDetailsNavigationController?.pushViewController(controller, animated: true)
    }

}

// MARK:- Handlers

extension MyListingsFlowCoordinator {

    private func addHandlers() {
        addHandler { [weak self] (event: MyListingsEvent) in self?.handle(event) }
        addHandler { [weak self] (event: CreateListingFlowEvent) in self?.handle(event) }
        addHandler { [weak self] (event: CommonListingDetailsEvent) in self?.handle(event) }
        addHandler { [weak self] (event: ListingDetailsEvent) in self?.handle(event) }
    }

    private func handle(_ event: ListingDetailsEvent) {
        switch event {
        case .showDescription(let string):
            presentListingDescription(string)

        case .showMap(let location, let propertyType):
            presentListingDetailsMap(with: location, propertyType: propertyType)

        case .showPhotoGallery(let config):
            presentPhotoGalleryController(config: config)
        }
    }

    private func handle(_ event: MyListingsEvent) {
        switch event {
        case .createListing(let listing):
            showCreateListingFlow(listing, mode: .create)
        case .openListing(let listing):
            presentListingDetail(for: listing)
        case .editListing(let listing):
            showCreateListingFlow(listing, mode: .edit)
        case .publishListing(let listing):
            presentPaymentFlow(listing: listing)
        }
    }

    private func handle(_ event: CreateListingFlowEvent) {
        switch event {
        case .listingCreated:
            containerViewController?.dismiss(animated: true, completion: nil)
        case .close(let alertMessage):
            containerViewController?.dismiss(animated: true, completion: nil)

            if let message = alertMessage {
                alertPresentableDelegate?.showAlert(message)
            }
        case .published(let listing, let state):
            containerViewController?.dismiss(animated: true, completion: nil)

            if let listing = listing {
                presentListingDetail(for: listing, state: state)
            }
        }
    }

    private func handle(_ event: CommonListingDetailsEvent) {
        switch event {
        case .editListing(let listing):
            showCreateListingFlow(listing, mode: .edit)
        }
    }

}
