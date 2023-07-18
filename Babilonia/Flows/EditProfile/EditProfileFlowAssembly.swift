//
//  EditProfileFlowAssembly.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/17/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject
import Core

final class EditProfileFlowAssembly: Assembly {
    
    func assemble(container: Container) {
        assembleServices(container)
        
        container
            .register(EditProfileViewController.self) { (resolver, eventNode: EventNode, screenType: EditProfileType) in
                let model = EditProfileModel(parent: eventNode,
                                             userSession: resolver.autoresolve(),
                                             userService: resolver.autoresolve(),
                                             screenType: screenType)
                return EditProfileViewController(
                    viewModel: EditProfileViewModel(model: model)
                )
            }
            .inObjectScope(.transient)
    }
    
    private func assembleServices(_ container: Container) {
        container
            .autoregister(UserService.self, initializer: UserService.init)
            .inObjectScope(.container)
    }
    
}
