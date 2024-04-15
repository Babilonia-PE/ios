import Foundation
import Swinject
import YALAPIClient

public final class UserSession {
    
    /**
     User session can be in the following states:
     
     - initial: after init(), does nothing
     - Opened: session has been opened successfuly, all services are running
     - Invalid: sessions credential has been invalidated and can not be renewd automatically
     (see `StoredCredentialProvider`).
     After session become invalid services stoped, but none of the data removed.
     - Closed: all services stoped, linked data such as intermediate sync state, credentials has been removed.
     */
    public enum State {
        case initial, opened, invalid, closed
    }
    
    public let id: String
    public let rootURL: URL
    public let container = Container()
    public private(set) var state: State = .initial {
        didSet {
            NotificationCenter.default.post(name: .UserSessionStateDidChange, object: self)
        }
    }
    
    public internal(set) var user: User!
    
    let store: UserSessionStore
    
    var invalidated: (() -> Void)?
    
    private var initializationData: UserSessionInfo?
    
    // MARK: - Init
    
    init?(restoringFromID id: String) {
        self.id = id
        self.rootURL = URL(userSessionID: id)
        self.store = UserSessionStore(id: id)
        
        if store.authTokens == nil
            || store.userId == nil {
            return nil
        }
    }
    
    init(initializationData: UserSessionInfo) {
        self.id = initializationData.identifier
        self.rootURL = URL(userSessionID: id)
        self.initializationData = initializationData
        self.store = UserSessionStore(id: id)
    }
    
    public init() {
        //let user = User(id: 0, email: nil, firstName: "guest", lastName: "", phoneNumber: "", avatar: nil)
        let user = User(id: 0, email: nil, fullName: "guest", prefix: "", phoneNumber: "", avatar: nil)
        let userAuthTokens = UserAuthTokens(authenticationToken: "", exchangeToken: "")
        let initializationData = UserSessionInfo(user: user, authTokens: userAuthTokens)
        self.initializationData = initializationData
        self.id = initializationData.identifier
        self.rootURL = URL(userSessionID: id)
        self.store = UserSessionStore(id: id)
    }
    
    // MARK: - State Change
    
    func open() {
        assert(state == .initial, "Session can be opened once")
        
        UserSessionAssembly(self).assemble(container: container)
        
        if let data = initializationData {
            //swiftlint:disable force_try
            try! UserSessionBoostrapper(userSession: self).bootstrap(using: data)
            //swiftlint:enable force_try
        }
        
        do {
            try UserSessionBoostrapper(userSession: self).tearup()
        } catch {
            close(updateState: false)
            state = .invalid
            
            return
        }
        
        if store.authTokens != nil {
            state = .opened
        } else {
            close(updateState: false)
            state = .invalid
        }
    }
    
    func close() {
        assert(state == .opened, "Only opened or invalid session can be closed")
        UserSessionBoostrapper(userSession: self).teardown()
        close(updateState: true)
    }
    
    @discardableResult
    func updateSession(with user: User) -> Result<Bool> {
        assert(state == .opened, "Only opened session can be updated")
        do {
            try UserSessionBoostrapper(userSession: self).update(with: user)
        } catch {
            return .failure(error)
        }
        
        return .success(true)
    }
    
    private func close(updateState: Bool) {
        container.removeAll()
        
        if updateState {
            state = .closed
        }
    }
}

extension Notification.Name {
    
    static let UserSessionStateDidChange = Notification.Name(rawValue: "UserSession.UserSessionStateDidChange")
    
}

extension UserSession: AccessCredentialsProvider {
    
    public var accessToken: String? {
        get { return store.authTokens?.authenticationToken }
        set {
            var tokens = store.authTokens
            if let token = newValue {
                tokens?.authenticationToken = token
            }
            store.authTokens = tokens
        }
    }
    public var exchangeToken: String? {
        get { return store.authTokens?.exchangeToken }
        set {
            var tokens = store.authTokens
            if let token = newValue {
                tokens?.exchangeToken = token
            }
            store.authTokens = tokens
        }
    }
    
    public func commitCredentialsUpdate(_ update: (AccessCredentialsProvider) -> Void) {
        update(self)
    }
    
    public func invalidate() {
        invalidated?()
    }
    
}
