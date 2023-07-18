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
import FirebaseUI

enum AuthFlowEvent: Event {
    case signIn(UserSession)
}

final class AuthFlowCoordinator: EventNode, FlowCoordinator {
    
    weak var containerViewController: UIViewController?
    
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
        }
    }
    
    private func updateConfigs() {
        let configsService: ConfigurationsService = container.autoresolve()
        configsService.updateAppConfigs()
    }
}
