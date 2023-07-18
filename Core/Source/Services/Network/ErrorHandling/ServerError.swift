//
//  ServerError.swift
//  Core
//
//

import Foundation

public struct ServerError: Error {
    
    public enum Code: String {
        case undefined
        
        case invalidAccountKitCode = "account_kit_invalid_code"
        case unauthenticated = "token_auth_unauthenticated"
        case invalidExchangeToken = "token_auth_find_entity_exception"
        case internalServer
        case alreadyExist
        
    }
    
    public enum ErrorType: String {
        case undefined
        case params
        case custom
    }
    
    public let code: Code
    public let message: String?
    public let payload: [String: Any]?
    public let type: ErrorType
    
    public init(
        code: Code = .undefined,
        message: String? = nil,
        payload: [String: Any]? = nil,
        type: ErrorType = .undefined
    ) {
        self.code = code
        self.message = message
        self.payload = payload
        self.type = type
    }
    
}
