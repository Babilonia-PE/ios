//
//  DecodableParser.swift
//  APIClient
//
//  Created by Vodolazkyi Anton on 9/19/18.
//

import Foundation
import YALAPIClient

public final class DecodableParser<T: Decodable>: KeyPathParser, ResponseParser {
    
    public typealias Representation = T
    
    public let decoder: JSONDecoder
    
    public init(keyPath: String? = nil, decoder: JSONDecoder = defaultDecoder) {
        self.decoder = decoder
        
        super.init(keyPath: keyPath)
    }
    
    public func parse(_ object: AnyObject) -> Result<T> {
        do {
            let value = try valueForKeyPath(in: object)
            let data = try JSONSerialization.data(withJSONObject: value, options: [])
            let decoded = try decoder.decode(T.self, from: data)
#if DEBUG
            print("DecodableParser = \(value)")
#endif
            return .success(decoded)
        } catch let error {
#if DEBUG
            print("DecodableParser error=", error)
#endif
            return .failure(error)
        }
    }
    
}
