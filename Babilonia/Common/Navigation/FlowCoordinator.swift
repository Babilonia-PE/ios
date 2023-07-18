//
//  FlowCoordinator.swift
//
//  Copyright © 2018 Yalantis. All rights reserved.
//

import UIKit

protocol FlowCoordinator: class {
    
    var containerViewController: UIViewController? { get set }
    @discardableResult
    func createFlow() -> UIViewController
    
}

extension FlowCoordinator {
    
    var navigationController: UINavigationController? {
        return containerViewController as? UINavigationController
    }
    
}
