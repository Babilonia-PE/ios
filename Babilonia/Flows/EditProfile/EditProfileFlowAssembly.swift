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
            .register(EditProfileViewController.self) { (resolver, eventNode: EventNode, screenType: EditProfileType, phonePrefixes: [PhonePrefix]) in
                let model = EditProfileModel(parent: eventNode,
                                             userSession: resolver.autoresolve(),
                                             userService: resolver.autoresolve(),
                                             imagesService: resolver.autoresolve(),
                                             screenType: screenType,
                                             phonePrefixes: phonePrefixes
                )
                return EditProfileViewController(
                    viewModel: EditProfileViewModel(model: model)
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
        container
            //.autoregister(ImagesService.self, initializer: ImagesService.init)
            .register(ImagesService.self) { (resolver) in
                return ImagesService(client: resolver.autoresolve(),
                                     newClient: resolver.autoresolve(name: "newClient"))
            }
            .inObjectScope(.container)
    }
    
}
