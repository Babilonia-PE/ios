//
//  ApplicationFlowCoordinator.swift
//
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Core
import Swinject
import FirebaseAuth

final class ApplicationFlowCoordinator: EventNode {
    
    private let window: UIWindow
    private let userSessionController: UserSessionController
    private let container: Container
    private let deeplinkManager: DeeplinkManager
    
    // MARK: init
    
    init(window: UIWindow, userSessionController: UserSessionController) {
        self.window = window
        self.userSessionController = userSessionController
        self.container = Container {
            ApplicationFlowAssembly(userSessionController).assemble(container: $0)
        }
        self.deeplinkManager = container.autoresolve()
        
        super.init()
        
        addHandler { [weak self] (event: AuthFlowEvent) in
            self?.handle(event)
        }
        addHandler { [weak self] (event: MainFlowEvent) in
            self?.handle(event)
        }
        addHandler { [weak self] (event: CreateProfileFlowEvent) in
            self?.handle(event)
        }
        
        observeSessionEvents()
        deeplinkManager.delegate = self
    }
    
    func execute() {
        if let session = userSessionController.restorePreviousSession() {
            //startFlow(with: session)
            self.verifyToken(session)
        } else {
            presentAuthFlow()
        }
    }
    
    private func verifyToken(_ userSession: UserSession) {
        userSessionController.verifyToken(
            userSession: userSession
        ) { [weak self] result in
            guard let self = self else { return }
            
            if result {
                self.startFlow(with: userSession)
            } else {
                self.presentAuthFlow()
            }
        }
    }

    func handleDeeplink(link: URL) -> Bool {
        deeplinkManager.handleLink(link)
    }
    
    // MARK: Modules presentation
    
    private func presentMainFlow(userSession: UserSession) {
        let flowCoordinator: MainFlowCoordinator = container.autoresolve(arguments: self, userSession)
        let controller = flowCoordinator.createFlow()
        flowCoordinator.containerViewController = controller
        setWindowRootViewController(with: controller)
    }
    
    private func presentAuthFlow(autoPhoneAuth: Bool = false) {
        let authFlowCoordinator: AuthFlowCoordinator = container.autoresolve(argument: self)
        guard let authViewController = authFlowCoordinator.createFlow() as? AuthViewController else { return }
        authViewController.autoPhoneAuth = autoPhoneAuth
        let authNavigationController = UINavigationController(rootViewController: authViewController)
        authNavigationController.navigationBar.isTranslucent = true
        authFlowCoordinator.containerViewController = authNavigationController
        setWindowRootViewController(with: authNavigationController)
    }
    
    private func presentCreateProfileFlow(userSession: UserSession) {
        let coordinator: EditProfileFlowCoordinator = container.autoresolve(
            arguments: self, userSession, EditProfileFlowCoordinatorFlowData(screenType: EditProfileType.signUp)  
        )
        let editNavigationController = UINavigationController(rootViewController: coordinator.createFlow())
        coordinator.containerViewController = editNavigationController
        setWindowRootViewController(with: editNavigationController)
    }
    
    // MARK: Helpers
    
    private func setWindowRootViewController(with viewController: UIViewController) {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    private func handle(_ event: AuthFlowEvent) {
        switch event {
        case .signIn(let userSession):
            startFlow(with: userSession)
        }
    }
    
    private func handle(_ event: MainFlowEvent) {
        switch event {
        case .logout:
            logout()
        case .logoutAndLogin:
            logoutAndLogin()
        }
    }
    
    private func handle(_ event: CreateProfileFlowEvent) {
        switch event {
        case .userCreated(let userSession):
            presentMainFlow(userSession: userSession)
        case .cancel:
            logout()
        }
    }
    
    private func observeSessionEvents() {
        userSessionController.sessionInvalidated = { [unowned self] in
            DispatchQueue.main.async {
                self.presentAuthFlow()
            }
        }
    }
    
    private func startFlow(with userSession: UserSession) {
        print("startFlow userSession = \(userSession)")
        if userSession.id == "0" {
            presentMainFlow(userSession: userSession)
        } else {
            //if userSession.user.firstName == nil && userSession.user.lastName == nil {
            if userSession.user.fullName == nil {
                presentCreateProfileFlow(userSession: userSession)
            } else {
                presentMainFlow(userSession: userSession)
            }
        }
    }
    
    private func logout() {
        userSessionController.closeSession()
        try? Auth.auth().signOut()
        presentAuthFlow()
    }
    
    private func logoutAndLogin() {
        userSessionController.closeSession()
        try? Auth.auth().signOut()
        presentAuthFlow(autoPhoneAuth: true)
        
    }
}

extension ApplicationFlowCoordinator: DeeplinkManagerDelegate {

    func handler(_ handler: DeeplinkManager,
                 didHandleLink linkType: LinkScheme,
                 action: LinkAction?) {
        guard userSessionController.userSession?.state == .opened else { return }

        handleBabilonisAppLink(with: action)
    }

    func handlerDidFailToHandleLink(_ handler: DeeplinkManager) {}

    private func handleBabilonisAppLink(with action: LinkAction?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self, let action = action else { return }

            switch action {
            case .home:
                let listingsTabBarIndex = 0
                self.selectTab(at: listingsTabBarIndex)

            case .listingDetails(let id):
                let listingsTabBarIndex = 0
                if let id = Int(id) {
                    self.selectTab(at: listingsTabBarIndex) { [weak self] in
                        self?.raise(event: SearchFlowEvent.presentListingDetails(listingID: id))
                    }
                }

            case .privacyPolicy:
                let profileTabBarIndex = 4
                self.selectTab(at: profileTabBarIndex) { [weak self] in
                    self?.raise(event: ProfileTabFlowEvent.presentPrivacyPolicy)
                }
            }
        }
    }

    private func selectTab(at index: Int, completion: (() -> Void)? = nil) {
        if let mainViewController = self.window.rootViewController as? MainMenuViewController {
            mainViewController.selectedIndex = index
            completion?()
        }
    }

}
