//
//  DecoratableRequest.swift
//  Core
//
//

import Foundation

protocol DecoratableRequest {
    
    var authRequired: Bool { get }
    
}

extension DecoratableRequest {
    
    var authRequired: Bool { return false }
    
}
