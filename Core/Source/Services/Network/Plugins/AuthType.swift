//
//  AuthType.swift
//  Core
//
//

import Foundation

public enum AuthType {
    
    case `default`, basic, bearer, token
    case custom(key: String, valuePrefix: String?)
    
    var key: String {
        switch self {
        case .default, .basic, .bearer, .token: return "Authorization"
        case .custom(let key, _): return key
        }
    }
    
    var valuePrefix: String? {
        switch self {
        case .default: return ""
        case .basic: return "Basic "
        case .bearer: return "Bearer "
        case .token: return "Token token="
        case .custom(_, let prefix): return prefix
        }
    }
    
}
