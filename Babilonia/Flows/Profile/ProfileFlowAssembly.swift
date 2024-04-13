//
//  ProfileFlowAssembly.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject
import Core

final class ProfileFlowAssembly: Assembly {
    
    func assemble(container: Container) {
        assembleServices(container)
        
        container
            .autoregister(ProfileModel.self, argument: EventNode.self, initializer: ProfileModel.init)
            .inObjectScope(.transient)
        container
            .register(ProfileViewController.self) { (resolver, eventNode: EventNode) in
                ProfileViewController(viewModel: ProfileViewModel(model: resolver.autoresolve(argument: eventNode)))
            }
            .inObjectScope(.transient)
        
        container
            .autoregister(AccountModel.self, argument: EventNode.self, initializer: AccountModel.init)
            .inObjectScope(.transient)
        container
            .register(AccountViewController.self) { (resolver, eventNode: EventNode) in
                AccountViewController(
                    viewModel: AccountViewModel(model: resolver.autoresolve(argument: eventNode))
                )
            }
            .inObjectScope(.transient)
        container.autoregister(
            EditProfileFlowCoordinator.self,
            arguments: EventNode.self, Container.self, EditProfileFlowCoordinatorFlowData.self,
            initializer: EditProfileFlowCoordinator.init
        )
        .inObjectScope(.transient)
        container
            .autoregister(
                WebLinkModel.self,
                arguments: EventNode.self, String.self,
                initializer: WebLinkModel.init
            )
            .inObjectScope(.transient)
        container
            .register(WebLinkViewController.self) { (resolver, eventNode: EventNode, link: String, title: String) in
                WebLinkViewController(
                    viewModel: WebLinkViewModel(model: resolver.autoresolve(arguments: eventNode, link), title: title)
                )
            }
            .inObjectScope(.transient)
        
        container
            .autoregister(CurrencyModel.self, argument: EventNode.self, initializer: CurrencyModel.init)
            .inObjectScope(.transient)
        container
            .register(CurrencyViewController.self) { (resolver, eventNode: EventNode) in
                CurrencyViewController(
                    viewModel: CurrencyViewModel(model: resolver.autoresolve(argument: eventNode))
                )
            }
            .inObjectScope(.transient)
    }
    
    private func assembleServices(_ container: Container) {
        container
            .register(UserService.self) { (resolver) in
                return UserService(userSession: resolver.autoresolve(),
                                       client: resolver.autoresolve(),
                                       storage: resolver.autoresolve(),
                                       newClient: resolver.autoresolve(name: "newClient"))
            }
            .inObjectScope(.container)
    }
    
}
