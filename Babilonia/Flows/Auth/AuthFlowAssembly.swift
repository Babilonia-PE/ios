//
//  AuthFlowAssembly.swift
//  Babilonia
//
//  Created by Denis on 5/31/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject
import Core
import YALAPIClient
import DBClient

final class AuthFlowAssembly: Assembly {
    
    func assemble(container: Container) {
        container
            .autoregister(AuthModel.self, argument: EventNode.self, initializer: AuthModel.init)
            .inObjectScope(.transient)
        container
            .register(AuthViewController.self) { (resolver, eventNode: EventNode) in
                AuthViewController(viewModel: AuthViewModel(model: resolver.autoresolve(argument: eventNode)))
            }
            .inObjectScope(.transient)
        
        container
            .autoregister(AuthSignUpModel.self, argument: EventNode.self, initializer: AuthSignUpModel.init)
            .inObjectScope(.transient)
        container
            .register(AuthSignUpViewController.self) { (resolver, eventNode: EventNode, phonePrefixes: [PhonePrefix]) in
                let model = AuthSignUpModel(
                    parent: eventNode,
                    userSessionController: resolver.autoresolve(),
                    phonePrefixes: phonePrefixes
                )
                return AuthSignUpViewController(
                    viewModel: AuthSignUpViewModel(model: model)
                )
            }
            .inObjectScope(.transient)
        
        container
            .autoregister(AuthLogInModel.self, argument: EventNode.self, initializer: AuthLogInModel.init)
            .inObjectScope(.transient)
        container
            .register(AuthLogInViewController.self) { (resolver, eventNode: EventNode) in
                let model = AuthLogInModel(
                    parent: eventNode,
                    userSessionController: resolver.autoresolve()
                )
                return AuthLogInViewController(
                    viewModel: AuthLogInViewModel(model: model)
                )
            }
            .inObjectScope(.transient)
        
        assembleServices(in: container)
    }
    
    private func assembleServices(in container: Container) {
        container
            .register(NetworkClient.self) { _ in
                return APIClient(requestExecutor: AlamofireRequestExecutor(baseURL: Constants.API.baseURL))
            }
            .inObjectScope(.container)
        
        container
            .register(DBClient.self) { _ in
                CoreDataDBClient(forModel: "BabiloniaCoreDataModel", in: Bundle(for: ConfigurationsService.self))
            }
            .inObjectScope(.container)
        
        container
            .register(Currency.self) { _ in
                let storage: DBClient = container.autoresolve()
                guard let currency = storage.execute(FetchRequest<Currency>()).value?.first else {
                    let currency = Currency(
                        title: L10n.Currency.Usd.title,
                        symbol: L10n.Currency.Usd.symbol,
                        code: L10n.Currency.Usd.code
                    )
                    storage.upsert(currency)
                    return currency
                }
                
                return currency
            }
            .inObjectScope(.container)
        
        container
            .autoregister(ConfigurationsService.self, initializer: ConfigurationsService.init)
            .inObjectScope(.container)
        print("AuthAssembleServices container = \(container)")
    }
}
