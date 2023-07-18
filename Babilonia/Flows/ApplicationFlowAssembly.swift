import Swinject
import SwinjectAutoregistration
import Core

final class ApplicationFlowAssembly: Assembly {
    
    let userSessionController: UserSessionController
    
    init(_ userSessionController: UserSessionController) {
        self.userSessionController = userSessionController
    }
    
    func assemble(container: Container) {
        container
            .register(UserSessionController.self) { [unowned userSessionController] _ in
                userSessionController
            }
            .inObjectScope(.container)
        container.register(DeeplinkManager.self) { _ in
            DeeplinkManager()
        }.inObjectScope(.container)
        
        assembleAuth(in: container)
        assembeMain(in: container)
    }
    
    private func assembleAuth(in container: Container) {
        container
            .autoregister(AuthModel.self, argument: EventNode.self, initializer: AuthModel.init)
            .inObjectScope(.transient)
        
        container
            .register(AuthViewController.self) { (resolver, parent: EventNode) in
                let viewModel = AuthViewModel(model: resolver.autoresolve(argument: parent))
                let controller = AuthViewController(viewModel: viewModel)
                return controller
            }
            .inObjectScope(.transient)
        
        container
            .register(AuthFlowCoordinator.self) { [unowned container] _, parent in
                AuthFlowCoordinator(container: container, parent: parent)
            }
            .inObjectScope(.transient)
        
        //swiftlint:disable line_length
        container
            .register(EditProfileFlowCoordinator.self) { (_, parent: EventNode, session: UserSession, type: EditProfileType) in
                return EditProfileFlowCoordinator(container: session.container, parent: parent, screenType: type)
            }
            .inObjectScope(.transient)
    }
    
    private func assembeMain(in container: Container) {
        container
            .register(MainFlowCoordinator.self) { (_, parent: EventNode, userSession: UserSession) in
                return MainFlowCoordinator(container: userSession.container, parent: parent)
            }
            .inObjectScope(.transient)
    }
}
