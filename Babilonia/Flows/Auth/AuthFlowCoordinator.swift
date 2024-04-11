//
//  AuthFlowCoordinator.swift
//  Babilonia
//
//  Created by Denis on 5/31/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject
import Core
import FirebasePhoneAuthUI

enum AuthFlowEvent: Event {
    case signIn(UserSession)
}

final class AuthFlowCoordinator: EventNode, FlowCoordinator {
    
    weak var containerViewController: UIViewController?
    weak var signUpNavigationController: UINavigationController?
    weak var logInNavigationController: UINavigationController?
    
    private let container: Container
    private var authViewController: AuthViewController!
    
    init(container: Container, parent: EventNode) {
        self.container = Container(parent: container) { (container: Container) in
            AuthFlowAssembly().assemble(container: container)
        }
        
        super.init(parent: parent)
        
        addHandlers()
        updateConfigs()
    }
    
    @discardableResult
    func createFlow() -> UIViewController {
        authViewController = container.autoresolve(argument: self)
        return authViewController
    }
    
    private func showSignUpFlow(phonePrefixes: [PhonePrefix]) {
        let controller: AuthSignUpViewController = container.autoresolve(arguments: self, phonePrefixes)
        
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        signUpNavigationController = navigationController
        
        containerViewController?.present(signUpNavigationController!, animated: true, completion: nil)
    }
    
    private func showLogInFlow() {
        let controller: AuthLogInViewController = container.autoresolve(argument: self)
        
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        logInNavigationController = navigationController
        
        containerViewController?.present(logInNavigationController!, animated: true, completion: nil)
    }
    
    // MARK: - private
    
    private func addHandlers() {
        addHandler { [weak self] (event: AuthEvent) in
            self?.handle(event)
        }
    }
    
    private func handle(_ event: AuthEvent) {
        switch event {
        case .signIn(let userSession):
            raise(event: AuthFlowEvent.signIn(userSession))
        case .signUp(let phonePrefixes):
            showSignUpFlow(phonePrefixes: phonePrefixes)
        case .logIn:
            showLogInFlow()
        case .cancelSignUp:
            containerViewController?.dismiss(animated: true, completion: nil)
        case .cancelLogIn:
            containerViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func updateConfigs() {
        let configsService: ConfigurationsService = container.autoresolve()
        let version = Bundle.main.buildVersionNumber
        configsService.updateAppConfigs(version)
    }
}
