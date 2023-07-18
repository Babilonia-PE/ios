//
//  TempMyListingsFlowAssembly.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject

final class TempMyListingsFlowAssembly: Assembly {
    
    func assemble(container: Container) {
        assembleServices(container)
        
        container
            .autoregister(TempMyListingsModel.self, argument: EventNode.self, initializer: TempMyListingsModel.init)
            .inObjectScope(.transient)
        container
            .register(TempMyListingsViewController.self) { (resolver, eventNode: EventNode) in
                TempMyListingsViewController(
                    viewModel: TempMyListingsViewModel(model: resolver.autoresolve(argument: eventNode))
                )
            }
            .inObjectScope(.transient)
        container
            .autoregister(
                CreateListingFlowCoordinator.self,
                arguments: Container.self, EventNode.self,
                initializer: CreateListingFlowCoordinator.init
            )
            .inObjectScope(.transient)
    }
    
    private func assembleServices(_ container: Container) {
        
    }
    
}
