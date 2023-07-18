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
    
    public func openSession(_ authorizationToken: String, completion: @escaping (Result<UserSession>) -> Void) {
        authService.signIn(authorizationToken, completion: { [weak self] in
            guard let `self` = self else { return }
            completion($0.next(self.openSession))
        })
    }
    
    private func openSession(_ sessionInfo: UserSessionInfo) -> Result<UserSession> {
        let userSession = UserSession(initializationData: sessionInfo)
        self.userSession = userSession
        return .success(userSession)
    }
    
    public func closeSession() {
        assert(userSession != nil, "Can`t close nil session")
        authService.signOut(exchangeToken: userSession?.store.authTokens?.exchangeToken ?? "")
        
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
