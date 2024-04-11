import YALAPIClient

final class UserSessionAuthService {

    private var networkClient: NetworkClient
    private var newClient: NetworkClient

    // MARK: - Init
    
    init() {
        let networkClient = UserSessionAuthService.makeDefaultDependencies()
        self.networkClient = networkClient
        
        let newClient = UserSessionAuthService.makeNewDependencies()
        self.newClient = newClient
    }
    
    // MARK: -
    
    func signUp(
        fullName: String,
        //lastName: String,
        email: String,
        password: String,
        //phonePrefix: String,
        phoneNumber: String,
        ipAddress: String,
        userAgent: String,
        signProvider: String,
        completion: @escaping (Result<UserSignUp>) -> Void
    ) {
        var request: APIRequest = SignUpRequest(fullName: fullName,
                                    //lastName: lastName,
                                    email: email,
                                    password: password,
                                    ipAddress: ipAddress,
                                    userAgent: userAgent,
                                    signProvider: signProvider)
        //if !phonePrefix.isEmpty && !phoneNumber.isEmpty {
        if !phoneNumber.isEmpty {
            request = SignUpWithPhoneRequest(fullName: fullName,
                                             //lastName: lastName,
                                             email: email,
                                             password: password,
                                             //phonePrefix: phonePrefix,
                                             phoneNumber: phoneNumber,
                                             ipAddress: ipAddress,
                                             userAgent: userAgent,
                                             signProvider: signProvider)
        }
        
        newClient.execute(
            request: request,
            parser: DecodableParser<UserSignUp>(keyPath: "data"),
            completion: completion
        )
    }
    
    func logIn(
        email: String,
        password: String,
        ipAddress: String,
        userAgent: String,
        signProvider: String,
        completion: @escaping (Result<UserLogIn>) -> Void
    ) {
        let request = LogInRequest(
            email: email,
            password: password,
            ipAddress: ipAddress,
            userAgent: userAgent,
            signProvider: signProvider
        )
        newClient.execute(
            request: request,
            parser: DecodableParser<UserLogIn>(keyPath: "data"),
            completion: completion
        )
    }
    
    func verifyToken(
        userSession: UserSession,
        completion: @escaping (Result<VerifyToken>) -> Void
    ) {
        let request = ValidateTokeRequest()
        
        let newClient = UserSessionAuthService.makeAuthNewDependencies(userSession: userSession)
        
        newClient.execute(
            request: request,
            parser: DecodableParser<VerifyToken>(keyPath: "data"),
            completion: completion
        )
    }
    
    func getPhonePrefixes(
        completion: @escaping (Result<PhonePrefixResponse>) -> Void
    ) {
        let request = PhonePrefixesRequest()
        newClient.execute(request: request, parser: DecodableParser<PhonePrefixResponse>(keyPath: "data"), completion: completion)
    }
    
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
    
    private static func makeNewDependencies() -> NetworkClient {
        let networkClient = APIClient(
            requestExecutor: AlamofireRequestExecutor(baseURL: Constants.API.paymentBaseURL),
            plugins: [
                LoggingPlugin(),
                ErrorPreprocessorPlugin(errorPreprocessor: ServerErrorProcessor())
            ]
        )
        return networkClient
    }
    
    private static func makeAuthNewDependencies(userSession: UserSession) -> NetworkClient {
        let networkClient = APIClient(
            requestExecutor: AlamofireRequestExecutor(baseURL: Constants.API.paymentBaseURL),
            plugins: [
                LoggingPlugin(),
                AuthorizationPlugin(provider: userSession.store),
                ErrorPreprocessorPlugin(errorPreprocessor: ServerErrorProcessor())
            ]
        )
        return networkClient
    }
}
