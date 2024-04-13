//
//  ProfileFlowCoordinator.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject
import Core

enum ProfileFlowEvent: Event {
    case logout
}

enum ProfileTabFlowEvent: Event {
    case presentPrivacyPolicy
}

final class ProfileFlowCoordinator: EventNode, FlowCoordinator {
    
    weak var containerViewController: UIViewController?
    
    private var profileViewController: ProfileViewController!
    
    private let container: Container
    
    init(container: Container, parent: EventNode) {
        self.container = Container(parent: container) { (container: Container) in
            ProfileFlowAssembly().assemble(container: container)
        }
        
        super.init(parent: parent)
        
        addHandlers()
    }
    
    @discardableResult
    func createFlow() -> UIViewController {
        profileViewController = container.autoresolve(argument: self) as ProfileViewController
        return profileViewController
    }
    
    // MARK: - Modules presentation
    
    private func createEditProfileFlow(screenType: EditProfileType, _ phonePrefixes: [PhonePrefix] = []) {
        let coordinator: EditProfileFlowCoordinator = container.autoresolve(arguments: self, container, EditProfileFlowCoordinatorFlowData(screenType: screenType, phonePrefixes: phonePrefixes))
        // TODO: uncomment after resolving Tabbar hiding
        //navigationController?.pushViewController(coordinator.createFlow(), animated: true)
        let flow = UINavigationController(rootViewController: coordinator.createFlow())
        flow.modalPresentationStyle = .fullScreen
        containerViewController?.present(
            flow,
            animated: true,
            completion: nil
        )
    }
    
    // MARK: - private
    
    private func addHandlers() {
        addHandler { [weak self] (event: ProfileEvent) in self?.handle(event) }
        addHandler { [weak self] (event: EditProfileFlowEvent) in self?.handle(event) }
        addHandler { [weak self] (event: AccountEvent) in self?.handle(event) }
        addHandler { [weak self] (event: WebLinkEvent) in self?.handle(event) }
        addHandler { [weak self] (event: CurrencyEvent) in self?.handle(event) }
        addHandler { [weak self] (event: ProfileTabFlowEvent) in self?.handle(event) }
    }
    
    private func handle(_ event: ProfileEvent) {
        switch event {
        case .editProfile:
            createEditProfileFlow(screenType: .editProfile)
            
        case .editEmail:
            createEditProfileFlow(screenType: .editEmail)
            
        case .editPhoneNumber(let phonePrefixes):
            createEditProfileFlow(screenType: .editPhoneNumber, phonePrefixes)
            
        case .open(let link, let title):
            showTermsAndPrivacy(link, with: title)
            
        case .openCurrencies:
            showCurrencies()
            
        case .openAccount:
            showAccount()
        }
    }
    
    private func handle(_ event: EditProfileFlowEvent) {
        switch event {
        case .refresh(let user, let avatarImage):
            profileViewController.updateUser(user, avatarImage: avatarImage)
            
        case .updateRefreshMode(let isOn):
            profileViewController.updateRefreshMode(isOn: isOn)
            
        case .close: // TODO: edit after resolving Tabbar hiding
            containerViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func handle(_ event: CurrencyEvent) {
        switch event {
        case .close:
            // TODO: uncomment after resolving Tabbar hiding
            //navigationController?.popViewController(animated: true)
            containerViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func handle(_ event: AccountEvent) {
        switch event {
        case .logout:
            raise(event: ProfileFlowEvent.logout)
        case .close: // TODO: uncomment after resolving Tabbar hiding
//            navigationController?.popViewController(animated: true)
            containerViewController?.dismiss(animated: true, completion: nil)
        }
    }

    private func handle(_ event: ProfileTabFlowEvent) {
        switch event {
        case .presentPrivacyPolicy:
            let configService: ConfigurationsService = container.autoresolve()
            guard let link = configService.appConfigs?.privacyURLString else { return }
            showTermsAndPrivacy(link, with: L10n.Profile.About.Privacy.title)
        }
    }
    
    private func handle(_ event: WebLinkEvent) {
        switch event {
        case .close: // TODO: uncomment after resolving Tabbar hiding
            //navigationController?.popViewController(animated: true)
            containerViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func showAccount() {
        let controller: AccountViewController = container.autoresolve(argument: self)
        // TODO: uncomment after resolving Tabbar hiding
//        controller.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(controller, animated: true)
        let flow = UINavigationController(rootViewController: controller)
        flow.modalPresentationStyle = .fullScreen
        containerViewController?.present(
            flow,
            animated: true,
            completion: nil
        )
    }
    
    private func showTermsAndPrivacy(_ link: String, with title: String) {
        let controller: WebLinkViewController = container.autoresolve(arguments: self, link, title)
        // TODO: uncomment after resolving Tabbar hiding
//        navigationController?.pushViewController(controller, animated: true)
        let flow = UINavigationController(rootViewController: controller)
        flow.modalPresentationStyle = .fullScreen
        containerViewController?.present(
            flow,
            animated: true,
            completion: nil
        )
    }
    
    private func showCurrencies() {
        let controller: CurrencyViewController = container.autoresolve(argument: self)
        let flow = UINavigationController(rootViewController: controller)
        flow.modalPresentationStyle = .fullScreen
        containerViewController?.present(
            flow,
            animated: true,
            completion: nil
        )
    }
    
}
