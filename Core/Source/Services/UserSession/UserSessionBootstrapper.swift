import Foundation
import Swinject
import DBClient

enum UserSessionBoostrapperError: Error {
    case unableToFindExistingUserInDB(userId: UserId)
    case wrongUserUpdating(userId: UserId)
}

struct UserSessionBoostrapper {
    
    private let userSession: UserSession
    
    init(userSession: UserSession) {
        self.userSession = userSession
    }
    
    func bootstrap(using initData: UserSessionInfo) throws {
        assert(userSession.state == .initial)
        
        //swiftlint:disable force_try
        try! FileManager.default.createDirectory(
            at: userSession.rootURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
        //swiftlint:enable force_try

        userSession.store.userId = initData.user.id
        userSession.store.authTokens = initData.authTokens
        
        let client: DBClient = userSession.container.autoresolve()
        let result = client.upsert([initData.user])
        
        if case .failure(let error) = result {
            throw error
        }
    }
    
    func tearup() throws {
        let client: DBClient = userSession.container.autoresolve()
        
        let userId = userSession.store.userId!
        let result = client.findFirst(User.self, primaryValue: String(userId))
        guard case .success(let value) = result, let user = value else {
            throw UserSessionBoostrapperError.unableToFindExistingUserInDB(userId: userId)
        }
        
        userSession.user = user
    }
    
    func update(with user: User) throws {
        guard user.id == userSession.user.id else {
            throw UserSessionBoostrapperError.wrongUserUpdating(userId: user.id)
        }
        
        let client: DBClient = userSession.container.autoresolve()
        let result = client.upsert(user)
        
        if case .failure(let error) = result {
            throw error
        }
        
        userSession.user = user
    }
    
    func teardown() {
        assert(userSession.state == .opened)
        
        let client: DBClient = userSession.container.autoresolve()
        client.delete([userSession.user])
        
        // cleaning up DB
        client.deleteAllObjects(of: Listing.self) { _ in }
        client.deleteAllObjects(of: Facility.self) { _ in }
        client.deleteAllObjects(of: User.self) { _ in }
        
        userSession.user = nil
        userSession.store.userId = nil
        userSession.store.authTokens = nil
        
        try? FileManager.default.removeItem(at: userSession.rootURL)
    }
    
}
