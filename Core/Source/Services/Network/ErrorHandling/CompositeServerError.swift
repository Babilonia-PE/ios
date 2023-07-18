//
//  CompositeServerError.swift
//  Core
//
//

import Foundation

public struct CompositeServerError: Error {
    
    public let errors: [ServerError]
    
    public init(errors: [ServerError]) {
        self.errors = errors
    }
    
}
