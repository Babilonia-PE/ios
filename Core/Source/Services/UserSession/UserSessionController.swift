//
//  UserSessionController.swift
//  Core
//
//

import YALAPIClient

public final class UserSessionController {
    
    public var canRestoreUserSession: Bool {
        guard let identifier = userSessionIdentifier, !identifier.isEmpty else { return false }
        
        return true
    }
    
    /// Calls when session has been invalidated / unexpectedly closed. May be called on background thread
    public var sessionInvalidated: (() -> Void)?
    
    private let storage: KeyValueStorage
    private let authService = UserSessionAuthService()
    
    private static let userSessionIdentifierKey = "\(Bundle.main.bundleIdentifier!).userSession.identifier"
    
    public private(set) var userSession: UserSession? {
        didSet {
            oldValue?.close()
            userSession?.open()
            userSession?.invalidated = { [unowned self] in
                self.invalidate()
            }
            
            userSessionIdentifier = userSession?.id
        }
    }
    
    private var userSessionIdentifier: String? {
        get {
            return storage.object(forKey: UserSessionController.userSessionIdentifierKey) as? String
        }
        set {
            storage.set(newValue, forKey: UserSessionController.userSessionIdentifierKey)
            storage.saveChanges()
        }
    }
    
    // MARK: - Init
    
    /**
     - parameter storage: A storage that conforms to `KeyValueStorage` protocol
    */
    public init(storage: KeyValueStorage = UserDefaults.standard) {
        self.storage = storage
    }
    
    // MARK: Session managment
    //swiftlint:disable function_parameter_count
    public func createAccount(
        fullName: String,
        //lastName: String,
        email: String,
        password: String,
        phonePrefix: String,
        phoneNumber: String,
        ipAddress: String,
        userAgent: String,
        signProvider: String,
        completion: @escaping (Result<UserSession>) -> Void
    ) {
        authService.signUp(
            fullName: fullName,
            //lastName: lastName,
            email: email,
            password: password,
            phonePrefix: phonePrefix,
            phoneNumber: phoneNumber,
            ipAddress: ipAddress,
            userAgent: userAgent,
            signProvider: signProvider,
            completion: { [weak self] result in
                guard let `self` = self else { return }

                switch result {
                case .success:
                    var userId = UserId.guest
                    if let id = result.value?.userId {
                        userId = UserId.init(id)
                    }
                    //let user = User.init(id: userId, email: email, firstName: fullName, lastName: "", phoneNumber: nil, avatar: nil)
                    let user = User.init(id: userId, email: email, fullName: fullName, prefix: phonePrefix, phoneNumber: nil, avatar: nil)
                    let authToken = UserAuthTokens.init(
                        authenticationToken: result.value?.authorization ?? "",
                        exchangeToken: ""
                    )
                    let sessionInfo = UserSessionInfo.init(user: user, authTokens: authToken)
                    completion(`self`.openSession(sessionInfo))
                case .failure(let error):
                    completion(Result.failure(error))
                }
            })
    }
    
    public func logInAccount(
        email: String,
        password: String,
        ipAddress: String,
        userAgent: String,
        signProvider: String,
        completion: @escaping (Result<UserSession>) -> Void
    ) {
        authService.logIn(
            email: email,
            password: password,
            ipAddress: ipAddress,
            userAgent: userAgent,
            signProvider: signProvider,
            completion: { [weak self] result in
                guard let `self` = self else { return }

                switch result {
                case .success:
                    var userId = UserId.guest
                    if let id = result.value?.tokens?.userId {
                        userId = UserId.init(id)
                    }
                    let user = User.init(
                        id: userId,
                        email: email,
                        fullName: "",
                        //lastName: "",
                        prefix: "",
                        phoneNumber: "",
                        avatar: nil
                    )
                    let authenticationToken = "\(result.value?.tokens?.type ?? "") \(result.value?.tokens?.authentication ?? "")"
                    let authToken = UserAuthTokens.init(
                        authenticationToken: authenticationToken,
                        exchangeToken: ""
                    )
                    let sessionInfo = UserSessionInfo.init(user: user, authTokens: authToken)
                    completion(`self`.openSession(sessionInfo))
                case .failure(let error):
                    completion(Result.failure(error))
                }
            })
    }
    
    public func getPhonePrefixes(completion: @escaping ([PhonePrefix]) -> Void) {
        let defaultPrefixes: [PhonePrefix] = []
        authService.getPhonePrefixes { [weak self] result in
            switch result {
            case .success(let response):
                completion(response.records ?? defaultPrefixes)
            case .failure(let error):
                completion(defaultPrefixes)
            }
        }
    }
    
    public func verifyToken(
        userSession: UserSession,
        completion: @escaping (Bool) -> Void
    ) {
        authService.verifyToken(
            userSession: userSession
        ) { [weak self] result in
            //guard let `self` = self else { return }
            
            switch result {
            case .success:
                completion(true)
            case .failure:
                `self`?.closeSession()
                completion(false)
            }
        }
    }
    
    public func openSession(_ authorizationToken: String, completion: @escaping (Result<UserSession>) -> Void) {
        authService.signIn(authorizationToken, completion: { [weak self] in
            guard let `self` = self else { return }
            completion($0.next(self.openSession))
        })
    }
    
    public func openSessionGuest() -> UserSession {
        let userSession = UserSession()
        self.userSession = userSession
        return userSession
    }
    
    private func openSession(_ sessionInfo: UserSessionInfo) -> Result<UserSession> {
        let userSession = UserSession(initializationData: sessionInfo)
        self.userSession = userSession
        return .success(userSession)
    }
    
    public func closeSession() {
        assert(userSession != nil, "Can`t close nil session")
        //authService.signOut(exchangeToken: userSession?.store.authTokens?.exchangeToken ?? "")
        
        userSession = nil
    }
    
    // MARK: - Session Restoration
    
    @discardableResult
    public func restorePreviousSession() -> UserSession? {
        assert(userSession == nil, "Can`t open 2 sessions")
        
        guard canRestoreUserSession else { return nil }
        guard let identifier = userSessionIdentifier,
            !identifier.isEmpty,
            let session = UserSession(restoringFromID: identifier) else {
            return nil
        }
        
        self.userSession = session
        return session
    }
    
    // MARK: - private
    
    private func invalidate() {
        closeSession()
        sessionInvalidated?()
    }
    
}
