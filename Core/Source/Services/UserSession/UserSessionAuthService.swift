import YALAPIClient

final class UserSessionAuthService {

    private var networkClient: NetworkClient

    // MARK: - Init
    
    init() {
        let networkClient = UserSessionAuthService.makeDefaultDependencies()
        self.networkClient = networkClient
    }
    
    // MARK: -
    
    func signIn(_ authorizationToken: String, completion: @escaping (Result<UserSessionInfo>) -> Void) {
        let request = SignInRequest(authorizationToken: authorizationToken)
        networkClient.execute(
            request: request,
            parser: DecodableParser<UserSessionInfo>(keyPath: "data"),
            completion: completion
        )
    }
    
    func signOut(exchangeToken: String) {
        let request = LogoutRequest(exchangeToken: exchangeToken)
        networkClient.execute(request: request, parser: EmptyParser(), completion: { _ in })
    }
    
    private func resetDependencies() {
        let networkClient = UserSessionAuthService.makeDefaultDependencies()
        self.networkClient = networkClient
    }
    
    // MARK: - Dependencies
    
    private static func makeDefaultDependencies() -> NetworkClient {
        let networkClient = APIClient(
            requestExecutor: AlamofireRequestExecutor(baseURL: Constants.API.baseURL),
            plugins: [
                ErrorPreprocessorPlugin(errorPreprocessor: ServerErrorProcessor())
            ]
        )
        return networkClient
    }
    
}
