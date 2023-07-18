//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import Swinject

final class ___VARIABLE_moduleName___FlowCoordinator: EventNode, FlowCoordinator {
    
    weak var containerViewController: UIViewController?
    
    private let container: Container
    
    init(container: Container, parent: EventNode) {
        self.container = Container(parent: container) { (container: Container) in
            ___VARIABLE_moduleName___FlowAssembly().assemble(container: container)
        }
        
        super.init(parent: parent)
    }
    
    @discardableResult
    func createFlow() -> UIViewController {
        return container.autoresolve(argument: self) as ___VARIABLE_moduleName___ViewController
    }
}
