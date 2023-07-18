//
//  ErrorsLocalization.swift
//  Babilonia
//
//  Created by Denis on 6/21/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Core
import YALAPIClient

extension ServerError: LocalizedError {
    
    /// All errors localization is assumed to be implemented on server so just passing raw message here
    
    public var errorDescription: String? {
        return message
    }
    
}

extension CompositeServerError: LocalizedError {
    
    public var errorDescription: String? {
        return errors.compactMap { $0.localizedDescription }.joined(separator: "\n")
    }
    
}

extension NetworkError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        /// assuming `response` case is parsed into `ServerError`
        case .response, .undefined:
            return L10n.Errors.Network.undefined
        case .unsatisfiedHeader:
            return L10n.Errors.Network.unsatisfiedHeader
        case .canceled:
            return L10n.Errors.Network.canceled
        case .connection:
            return L10n.Errors.Network.connection
        case .unauthorized:
            return L10n.Errors.Network.unauthorized
        case .internalServer:
            return L10n.Errors.Network.internalServer
        }
    }
    
}
