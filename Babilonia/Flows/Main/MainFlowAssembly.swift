import Swinject
import SwinjectAutoregistration
import YALAPIClient
import DBClient
import Core

final class MainFlowAssembly: Assembly {
    
    func assemble(container: Container) {
        assembleUI(in: container)
        assembleServices(in: container)
    }
    
    private func assembleUI(in container: Container) {
        container.autoregister(MainMenuModel.self, argument: EventNode.self, initializer: MainMenuModel.init)
            .inObjectScope(.transient)
        container
            .register(MainMenuViewController.self) { (resolver, eventNode: EventNode) in
                let viewModel = MainMenuViewModel(model: resolver.autoresolve(argument: eventNode))
                let controller = MainMenuViewController(viewModel: viewModel)
                return controller
            }
            .inObjectScope(.transient)
        
        container
            .autoregister(
                SearchFlowCoordinator.self,
                arguments: Container.self, EventNode.self,
                initializer: SearchFlowCoordinator.init
            )
            .inObjectScope(.transient)
        container
            .autoregister(
                FavoritesFlowCoordinator.self,
                arguments: Container.self, EventNode.self,
                initializer: FavoritesFlowCoordinator.init
            )
            .inObjectScope(.transient)
        container
            .autoregister(
                MyListingsFlowCoordinator.self,
                arguments: Container.self, EventNode.self,
                initializer: MyListingsFlowCoordinator.init
            )
            .inObjectScope(.transient)
        container
            .autoregister(
                NotificationsFlowCoordinator.self,
                arguments: Container.self, EventNode.self,
                initializer: NotificationsFlowCoordinator.init
            )
            .inObjectScope(.transient)
        container
            .autoregister(
                ProfileFlowCoordinator.self,
                arguments: Container.self, EventNode.self,
                initializer: ProfileFlowCoordinator.init
            )
            .inObjectScope(.transient)
    }
    
    private func assembleServices(in container: Container) {
        container
            .register(Currency.self) { _ in
                let storage: DBClient = container.autoresolve()
                guard let currency = storage.execute(FetchRequest<Currency>()).value?.first else {
                    let currency = Currency(
                        title: L10n.Currency.Usd.title,
                        symbol: L10n.Currency.Usd.symbol,
                        code: L10n.Currency.Usd.code
                    )
                    storage.upsert(currency)
                    return currency
                }
                
                return currency
            }
            .inObjectScope(.container)
        
        container
            .autoregister(ConfigurationsService.self, initializer: ConfigurationsService.init)
            .inObjectScope(.container)
    }
    
}
