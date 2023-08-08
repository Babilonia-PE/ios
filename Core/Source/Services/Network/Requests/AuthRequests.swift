//
//  AuthRequests.swift
//  Core
//
//  Created by Denis on 5/29/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import YALAPIClient
import CoreLocation
import Alamofire

struct SignUpRequest: APIRequest, DecoratableRequest {
    let method: APIRequestMethod = .post
    let path = "auth/signup"
    let authRequired: Bool = false
    var encoding: APIRequestEncoding? = JSONEncoding.default
    private(set) var parameters: [String: Any]?
    
    init(
        fullName: String,
        //lastName: String,
        email: String,
        password: String,
        ipAddress: String,
        userAgent: String,
        signProvider: String
    ) {
        var params = [String: Any]()
        
        params["full_name"] = fullName
        //params["data[last_name]"] = lastName
        params["email"] = email
        params["password"] = password
        params["ipa"] = ipAddress
        params["ua"] = userAgent
        params["sip"] = signProvider
        
        parameters = params
    }
}

struct SignUpWithPhoneRequest: APIRequest, DecoratableRequest {
    let method: APIRequestMethod = .post
    let path = "auth/signup"
    let authRequired: Bool = false
    var encoding: APIRequestEncoding? = JSONEncoding.default
    private(set) var parameters: [String: Any]?
    
    init(
        fullName: String,
        //lastName: String,
        email: String,
        password: String,
        //phonePrefix: String,
        phoneNumber: String,
        ipAddress: String,
        userAgent: String,
        signProvider: String
    ) {
        var params = [String: Any]()
        
        params["full_name"] = fullName
        //params["data[last_name]"] = lastName
        params["email"] = email
        //params["data[prefix]"] = phonePrefix
        params["phone_number"] = phoneNumber
        params["password"] = password
        params["ipa"] = ipAddress
        params["ua"] = userAgent
        params["sip"] = signProvider
        
        parameters = params
    }
}

struct LogInRequest: APIRequest, DecoratableRequest {
    let method: APIRequestMethod = .post
    let path = "auth/login"
    let authRequired: Bool = false
    var encoding: APIRequestEncoding? = JSONEncoding.default
    private(set) var parameters: [String: Any]?
    
    init(
        email: String,
        password: String,
        ipAddress: String,
        userAgent: String,
        signProvider: String
    ) {
        var params = [String: Any]()
        
        params["email"] = email
        params["password"] = password
        params["ipa"] = ipAddress
        params["ua"] = userAgent
        params["sip"] = signProvider
        
        parameters = params
    }
}

struct SignInRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .post
    let path = "firebase/authentication"
    let authRequired: Bool = false
    private(set) var parameters: [String: Any]?
    
    init(authorizationToken: String) {
        parameters = ["token": authorizationToken]
    }
}

struct ValidateTokeRequest: APIRequest, DecoratableRequest {
    let method: APIRequestMethod = .post
    let path = "auth/authentication"
    let authRequired: Bool = true
    private(set) var parameters: [String: Any]?
    
    init() {
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
