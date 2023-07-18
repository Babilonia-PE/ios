//
//  TempMyListingsFlowCoordinator.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject

final class TempMyListingsFlowCoordinator: EventNode, FlowCoordinator {
    
    weak var containerViewController: UIViewController?
    
    private let container: Container
    
    init(container: Container, parent: EventNode) {
        self.container = Container(parent: container) { (container: Container) in
            TempMyListingsFlowAssembly().assemble(container: container)
        }
        
        super.init(parent: parent)
        
        addHandlers()
    }
    
    @discardableResult
    func createFlow() -> UIViewController {
        return container.autoresolve(argument: self) as TempMyListingsViewController
    }
    
    // MARK: - private
    
    private func addHandlers() {
        addHandler { [weak self] (event: TempMyListingsEvent) in
            self?.handle(event)
        }
        addHandler { [weak self] (event: CreateListingFlowEvent) in
            self?.handle(event)
        }
    }
    
    private func handle(_ event: TempMyListingsEvent) {
        switch event {
        case .createListing:
            showCreateListingFlow()
        }
    }
    
    private func handle(_ event: CreateListingFlowEvent) {
        switch event {
        case .listingCreated:
            containerViewController?.dismiss(animated: true, completion: nil)
        case .close:
            containerViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func showCreateListingFlow() {
        let coordinator: CreateListingFlowCoordinator = container.autoresolve(arguments: container, self)
        let navigationController = UINavigationController(rootViewController: coordinator.createFlow())
        coordinator.containerViewController = navigationController
        containerViewController?.present(navigationController, animated: true, completion: nil)
    }
    
}
