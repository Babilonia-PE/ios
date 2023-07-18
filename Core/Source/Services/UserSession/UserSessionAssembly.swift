import Swinject
import SwinjectAutoregistration
import YALAPIClient
import DBClient
import Alamofire

final class UserSessionAssembly: Assembly {
    
    let userSession: UserSession
    
    // MARK: - Init
    
    init(_ userSession: UserSession) {
        self.userSession = userSession
    }
    
    func assemble(container: Container) {
        container.register(UserSession.self) { [unowned userSession] _ in userSession }
        
        container.register(NetworkClient.self) { resolver in
            let userSession: UserSession = resolver.autoresolve()
            
            let restorationProvider: RestorationResultProvider = resolver.autoresolve()
            let restorationPlugin = RestorationTokenPlugin(
                credentialProvider: userSession,
                shouldHaltRequestsTillResolve: true,
                authErrorResolving: unauthorizedErrorResolving
            )
            restorationPlugin.restorationResultProvider = restorationProvider.restore
            
            let networkClient = APIClient(
                requestExecutor: AlamofireRequestExecutor(baseURL: Constants.API.baseURL),
                plugins: [
                    AuthorizationPlugin(provider: userSession.store),
                    AcceptLanguagePlugin(),
                    ErrorPreprocessorPlugin(errorPreprocessor: ServerErrorProcessor()),
                    restorationPlugin
                ]
            )
            return networkClient
        }.inObjectScope(.container)
        
        container
            .register(DBClient.self) { _ in
                CoreDataDBClient(forModel: "BabiloniaCoreDataModel", in: Bundle(for: UserSessionAssembly.self))
                
            }
            .inObjectScope(.container)
        
        container
            .register(RestorationResultProvider.self) { resolver in
                let userSession: UserSession = resolver.autoresolve()
                let restorationNetworkClient = APIClient(
                    requestExecutor: AlamofireRequestExecutor(baseURL: Constants.API.baseURL),
                    plugins: [
                        ErrorPreprocessorPlugin(errorPreprocessor: ServerErrorProcessor())
                    ]
                )
                let restorationProvider = RestorationResultProvider(
                    networkClient: restorationNetworkClient,
                    store: userSession.store
                )
                
                return restorationProvider
            }
            .inObjectScope(.container)
    }
    
}
