//
//  AuthorizationCredentialsProvider.swift
//  Core
//
//

public protocol AuthorizationCredentialsProvider: class {
    
    var authorizationToken: String { get }
    var authorizationType: AuthType { get }
    
}
