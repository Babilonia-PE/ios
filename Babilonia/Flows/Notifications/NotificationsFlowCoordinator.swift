//
//  NotificationsFlowCoordinator.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject

final class NotificationsFlowCoordinator: EventNode, FlowCoordinator {
    
    weak var containerViewController: UIViewController?
    
    private let container: Container
    
    init(container: Container, parent: EventNode) {
        self.container = Container(parent: container) { (container: Container) in
            NotificationsFlowAssembly().assemble(container: container)
        }
        
        super.init(parent: parent)
    }
    
    @discardableResult
    func createFlow() -> UIViewController {
        return container.autoresolve(argument: self) as NotificationsViewController
    }
}
