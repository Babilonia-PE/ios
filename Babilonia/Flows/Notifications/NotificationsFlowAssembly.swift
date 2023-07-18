//
//  NotificationsFlowAssembly.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject

final class NotificationsFlowAssembly: Assembly {
    
    func assemble(container: Container) {
        assembleServices(container)
        
        container
            .autoregister(NotificationsModel.self, argument: EventNode.self, initializer: NotificationsModel.init)
            .inObjectScope(.transient)
        container
            .register(NotificationsViewController.self) { (resolver, eventNode: EventNode) in
                NotificationsViewController(
                    viewModel: NotificationsViewModel(model: resolver.autoresolve(argument: eventNode))
                )
            }
            .inObjectScope(.transient)
    }
    
    private func assembleServices(_ container: Container) {
        
    }
    
}
