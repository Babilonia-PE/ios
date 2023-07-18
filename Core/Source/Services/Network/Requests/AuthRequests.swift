//
//  AuthRequests.swift
//  Core
//
//  Created by Denis on 5/29/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import YALAPIClient

struct SignInRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .post
    let path = "firebase/authentication"
    let authRequired: Bool = false
    private(set) var parameters: [String: Any]?
    
    init(authorizationToken: String) {
        parameters = ["token": authorizationToken]
    }
}

struct LogoutRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .delete
    let path = "users/session"
    let authRequired: Bool = true
    private(set) var parameters: [String: Any]?
    
    init(exchangeToken: String) {
        parameters = ["exchange_token": exchangeToken]
    }
    
}

struct RestoreSessionRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .put
    let path = "users/session/restore"
    let authRequired: Bool = false
    private(set) var parameters: [String: Any]?
    
    init(tokens: UserAuthTokens) {
        parameters = ["exchange_token": tokens.exchangeToken]
    }
}
