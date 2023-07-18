//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import Swinject

final class ___VARIABLE_moduleName___FlowAssembly: Assembly {
    
    func assemble(container: Container) {
        assembleServices(container)
        
        container.autoregister(___VARIABLE_moduleName___Model.self, argument: EventNode.self, initializer: ___VARIABLE_moduleName___Model.init).inObjectScope(.transient)
        container
            .register(___VARIABLE_moduleName___ViewController.self) { (resolver, eventNode: EventNode) in
                ___VARIABLE_moduleName___ViewController(viewModel: ___VARIABLE_moduleName___ViewModel(model: resolver.autoresolve(argument: eventNode)))
            }
            .inObjectScope(.transient)
    }
    
    private func assembleServices(_ container: Container) {
        
    }
    
}
