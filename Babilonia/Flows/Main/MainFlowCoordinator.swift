//
//  MainFlowCoordinator.swift
//
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Core
import Swinject
import ESTabBarController_swift

enum MainFlowEvent: Event {
    case logout
}

final class MainFlowCoordinator: EventNode, FlowCoordinator {
    
    weak var containerViewController: UIViewController?
    
    private let container: Container
    
    init(container: Container, parent: EventNode) {
        self.container = Container(parent: container) { (container: Container) in
            MainFlowAssembly().assemble(container: container)
        }
        
        super.init(parent: parent)
        
        addHandlers()
        updateConfigs()
    }
    
    func createFlow() -> UIViewController {
        let controller: MainMenuViewController = container.autoresolve(argument: self)
        controller.viewControllers = createViewControllers()

        return controller
    }
    
    // MARK: - private
    
    private func createViewControllers() -> [UIViewController] {
        return [
            createSearchFlow(),
            createFavoritesFlow(),
            createMyListingsFlow(),
            createNotificationsFlow(),
            createProfileFlow()
        ]
    }
    
    private func createSearchFlow() -> UIViewController {
        let coordinator: SearchFlowCoordinator = container.autoresolve(arguments: container, self)
        let navigationController = UINavigationController(rootViewController: coordinator.createFlow())
        coordinator.containerViewController = navigationController
        navigationController.tabBarItem = ESTabBarItem(
            MainTabBarItemContentView(),
            title: L10n.TabBar.Search.title,
            image: Asset.Main.searchTabBarIcon.image,
            selectedImage: nil
        )
        return navigationController
    }
    
    private func createFavoritesFlow() -> UIViewController {
        let coordinator: FavoritesFlowCoordinator = container.autoresolve(arguments: container, self)
        let navigationController = UINavigationController(rootViewController: coordinator.createFlow())
        coordinator.containerViewController = navigationController
        navigationController.tabBarItem = ESTabBarItem(
            MainTabBarItemContentView(),
            title: L10n.TabBar.Favorites.title,
            image: Asset.Main.favoritesTabBarIcon.image,
            selectedImage: nil
        )
        return navigationController
    }
    
    private func createMyListingsFlow() -> UIViewController {
        let coordinator: MyListingsFlowCoordinator = container.autoresolve(arguments: container, self)
        let navigationController = UINavigationController(rootViewController: coordinator.createFlow())
        coordinator.containerViewController = navigationController
        navigationController.tabBarItem = ESTabBarItem(
            MainTabBarItemContentView(),
            title: L10n.TabBar.MyListings.title,
            image: Asset.Main.listingTabBarIcon.image,
            selectedImage: nil
            )
        return navigationController
    }
    
    private func createNotificationsFlow() -> UIViewController {
        let coordinator: NotificationsFlowCoordinator = container.autoresolve(arguments: container, self)
        let navigationController = UINavigationController(rootViewController: coordinator.createFlow())
        coordinator.containerViewController = navigationController
        navigationController.tabBarItem = ESTabBarItem(
            MainTabBarItemContentView(),
            title: L10n.TabBar.Notifications.title,
            image: Asset.Main.notificationsTabBarIcon.image,
            selectedImage: nil
        )
        return navigationController
    }
    
    private func createProfileFlow() -> UIViewController {
        let coordinator: ProfileFlowCoordinator = container.autoresolve(arguments: container, self)
        let navigationController = UINavigationController(rootViewController: coordinator.createFlow())
        navigationController.view.backgroundColor = .white
        coordinator.containerViewController = navigationController
        navigationController.tabBarItem = ESTabBarItem(
            MainTabBarItemContentView(),
            title: L10n.TabBar.Profile.title,
            image: Asset.Main.profileTabBarIcon.image,
            selectedImage: nil
        )
        return navigationController
    }
    
    private func addHandlers() {
        addHandler { [weak self] (event: ProfileFlowEvent) in
            self?.handle(event)
        }
    }
    
    private func handle(_ event: ProfileFlowEvent) {
        switch event {
        case .logout:
            containerViewController?.dismiss(animated: true, completion: { [weak self] in
                self?.raise(event: MainFlowEvent.logout)
            })
        }
    }
    
    private func updateConfigs() {
        let configsService: ConfigurationsService = container.autoresolve()
        configsService.updateAppConfigs()
        configsService.getCurrencyRate()
    }
    
}
