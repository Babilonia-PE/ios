import Foundation

struct UserSessionInfo: Codable {

    var user: User
    var authTokens: UserAuthTokens
    
    var identifier: String {
        return String(user.id)
    }
    
    enum CodingKeys: String, CodingKey {
        case user
        case authTokens = "tokens"
    }
    
    init(user: User, authTokens: UserAuthTokens) {
        self.user = user
        self.authTokens = authTokens
    }
    
}

struct UserAuthTokens: Codable {
    
    var authenticationToken: String
    var exchangeToken: String
    
    enum CodingKeys: String, CodingKey {
        case authenticationToken = "authentication"
        case exchangeToken = "exchange"
    }
    
}
