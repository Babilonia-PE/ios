//
//  UnauthorizedErrorResolving.swift
//  Core
//
//  Created by Denis on 7/11/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import YALAPIClient

let unauthorizedErrorResolving = { (error: Error) -> Bool in
    print("unauthorizedErrorResolving = \(error)")
    
    if let error = error as? ServerError, case .unauthenticated = error.code {
        print("ServerError unauthenticated")
        return true
    }
    
    if let error = error as? CompositeServerError, !error.errors.filter({ $0.code == .unauthenticated }).isEmpty {
        print("CompositeServerError unauthenticated")
        
        return true
    }
    
    return false
}

class RestorationResultProvider {
    
    private let networkClient: NetworkClient
    private let store: UserSessionStore
    
    var restore: ((@escaping (Result<TokenType>) -> Void) -> Void) {
        return { [weak self] update in
            guard let self = self, let tokens = self.store.authTokens else { return }
            
            let request = RestoreSessionRequest(tokens: tokens)
            let parser = DecodableParser<UserAuthTokens>(keyPath: "data.tokens")
            
            self.networkClient.execute(request: request, parser: parser) { (result: Result<UserAuthTokens>) in
                update(result.map { $0 })
            }
        }
    }
    
    init(networkClient: NetworkClient, store: UserSessionStore) {
        self.networkClient = networkClient
        self.store = store
    }
    
}

extension UserAuthTokens: TokenType {
    
    var accessToken: String {
        get { return authenticationToken }
        set { authenticationToken = newValue }
    }
    
}
