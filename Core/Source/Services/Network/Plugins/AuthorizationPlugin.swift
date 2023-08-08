//
//  AuthorizationPluginPlugin.swift
//  Core
//
//

import YALAPIClient

final class AuthorizationPlugin: PluginType {
    
    private let provider: AuthorizationCredentialsProvider
    
    init(provider: AuthorizationCredentialsProvider) {
        self.provider = provider
    }
    
    func prepare(_ request: APIRequest) -> APIRequest {
        var requestProxy = APIRequestProxy(request: request)
        
        if let request = request as? DecoratableRequest {
            applyHeaders(&requestProxy, applyAuthorization: request.authRequired)
        }
        
        return requestProxy
    }
    
    private func applyHeaders(_ request: inout APIRequestProxy, applyAuthorization: Bool) {
        var headers = request.headers ?? [:]
        
        if applyAuthorization {
            if !provider.authorizationToken.isEmpty {
                var prefix = ""
                if let authPrefix = provider.authorizationType.valuePrefix {
                    prefix = authPrefix + ""
                }
                headers[provider.authorizationType.key] = prefix + provider.authorizationToken
#if DEBUG
                print("authorizationToken=", headers[provider.authorizationType.key] ?? "")
#endif
            }
        }
        
        request.headers = headers
    }
    
}
