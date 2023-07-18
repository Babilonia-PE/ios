//
//  KeyPathParser.swift
//  APIClient
//
//  Created by Vodolazkyi Anton on 9/19/18.
//

import YALAPIClient

internal typealias JSON = [String: Any]

open class KeyPathParser {
    
    private let keyPath: String?
    
    public init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }
    
    internal func valueForKeyPath(in object: Any) throws -> Any {
        if let keyPath = keyPath, let dictionary = object as? JSON {
            if let value = dictionary[keyPath: DictionaryKeyPath(keyPath)] {
                return value
            }
            throw ParserError.keyNotFound
        } else {
            return object
        }
    }
    
}
