final class UserSessionStore {
    
    private let effectiveStore: KeyValueStorage = UserDefaults.standard
    
    private let id: String
    
    init(id: String) {
        self.id = id
    }
 
    var userId: UserId? {
        get {
            return effectiveStore.object(forKey: key(for: "userId")) as? UserId
        }
        
        set {
            if let newValue = newValue {
                effectiveStore.set(newValue, forKey: key(for: "userId"))
            } else {
                effectiveStore.set(nil, forKey: key(for: "userId"))
            }
        }
    }
    
    var authTokens: UserAuthTokens? {
        get {
            guard
                let authenticationToken = effectiveStore.object(forKey: key(for: "authenticationToken")) as? String,
                let exchangeToken = effectiveStore.object(forKey: key(for: "exchangeToken")) as? String
                else { return nil }
            
            return UserAuthTokens(authenticationToken: authenticationToken, exchangeToken: exchangeToken)
        }
        
        set {
            if let newValue = newValue {
                effectiveStore.set(newValue.authenticationToken, forKey: key(for: "authenticationToken"))
                effectiveStore.set(newValue.exchangeToken, forKey: key(for: "exchangeToken"))
            } else {
                effectiveStore.set(nil, forKey: key(for: "authenticationToken"))
                effectiveStore.set(nil, forKey: key(for: "exchangeToken"))
            }
        }
    }
    
    private func key(for value: String) -> String {
        return IDGen.make(for: value)
    }
    
}

extension UserSessionStore: AuthorizationCredentialsProvider {
    
    var authorizationToken: String {
        return authTokens!.authenticationToken
    }
    
    var authorizationType: AuthType {
        return .bearer
    }
    
}
