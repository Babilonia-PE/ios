//
//  EditProfileFlowCoordinator.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/17/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject
import Core

enum CreateProfileFlowEvent: Event {
    case userCreated(userSession: UserSession)
    case cancel
}

enum EditProfileFlowEvent: Event {
    case refresh(user: User, avatar: UIImage?)
    case updateRefreshMode(isOn: Bool)
    case close
}

struct EditProfileFlowCoordinatorFlowData {
    
    let screenType: EditProfileType
    var phonePrefixes: [PhonePrefix] = []
    
}

final class EditProfileFlowCoordinator: EventNode, FlowCoordinator {
    
    weak var containerViewController: UIViewController?
    
    private var editProfileViewController: EditProfileViewController!
    
    private let container: Container
    
    private let screenType: EditProfileType
    
    private let phonePrefixes: [PhonePrefix]
    
    init(container: Container, parent: EventNode, flowData: EditProfileFlowCoordinatorFlowData) {
        self.container = Container(parent: container) { (container: Container) in
            EditProfileFlowAssembly().assemble(container: container)
        }
        self.screenType = flowData.screenType
        self.phonePrefixes = flowData.phonePrefixes
        super.init(parent: parent)
        
        addHandlers()
    }
    
    @discardableResult
    func createFlow() -> UIViewController {
        editProfileViewController = container.autoresolve(arguments: self, screenType, phonePrefixes) as EditProfileViewController
        return editProfileViewController
    }
    
    // MARK: - private
    
    private func addHandlers() {
        addHandler { [weak self] (event: EditProfileEvent) in
            self?.handle(event)
        }
        addHandler { [weak self] (event: CreateProfileEvent) in
            self?.handle(event)
        }
    }
    
    private func handle(_ event: EditProfileEvent) {
        switch event {
        case .refresh(let user, let avatarImage):
            raise(event: EditProfileFlowEvent.refresh(user: user, avatar: avatarImage))
            
        case .updateRefreshMode(let isOn):
            raise(event: EditProfileFlowEvent.updateRefreshMode(isOn: isOn))
            
        case .close:
            raise(event: EditProfileFlowEvent.close)
        }
    }
    
    private func handle(_ event: CreateProfileEvent) {
        switch event {
        case .userCreated(let userSession):
            editProfileViewController.userCreated()
            raise(event: CreateProfileFlowEvent.userCreated(userSession: userSession))
        case .cancel:
            containerViewController?.dismiss(animated: true, completion: nil)
            raise(event: CreateProfileFlowEvent.cancel)
        }
    }
}
