//
//  ServerErrorProcessor.swift
//  Core
//
//

import Foundation
import YALAPIClient

public struct ServerErrorProcessor: ErrorProcessing {
    
    private let deserializer = JSONDeserializer()
    
    public init() { }
    
    public func processError(using response: APIClient.HTTPResponse) -> Error? {
        print(response.httpResponse.statusCode)
        print(String(decoding: response.data, as: UTF8.self))
        if
            let responseJSON = deserializer.deserialize(
                response.httpResponse,
                data: response.data
            ).value as? [String: [String: AnyObject]],
            let array = responseJSON["data"]?["errors"] as? [[String: AnyObject]] {
            // TODO: recheck error deserialization here
            let errors = array.compactMap { dictionary -> ServerError? in
                var code = (dictionary["key"] as? String).flatMap(ServerError.Code.init) ?? .undefined
                
                if code == .undefined && response.httpResponse.statusCode == 500 {
                    code = .internalServer
                }

                if response.httpResponse.statusCode == 422 {
                    code = .alreadyExist
                }
                
                if response.httpResponse.statusCode == 401 {
                    code = .unauthenticated
                }
                
                let message = dictionary["message"] as? String
                let payload = dictionary["payload"] as? [String: Any]
                let type = (dictionary["type"] as? String).flatMap(ServerError.ErrorType.init) ?? .undefined
                
                return ServerError(
                    code: code,
                    message: message,
                    payload: payload,
                    type: type
                )
            }
            
            if !errors.isEmpty {
                return CompositeServerError(errors: errors)
            }
        }
        
        return ServerError()
    }
    
}
