//
//  AuthClientDeserializer.swift
//  Core
//
//

import YALAPIClient

enum AuthClientDeserializerError: Error {
    case authTokenIsEmpty, invalidJSON
}

class AuthClientDeserializer: Deserializer {
    
    enum Keys: String {
        case authToken = "Authorization"
    }
    
    func deserialize(_ response: HTTPURLResponse, data: Data) -> Result<AnyObject> {
        guard let authValue = response.allHeaderFields[Keys.authToken.rawValue] as? String,
            let authToken = authValue.components(separatedBy: " ").last else {
            return .failure(AuthClientDeserializerError.authTokenIsEmpty)
        }
        
        switch JSONDeserializer().deserialize(response, data: data) {
        case .success(let result):
            if var result = result as? [String: Any] {
                result[Keys.authToken.rawValue] = authToken
                return .success(result as AnyObject)
            } else {
                return .failure(AuthClientDeserializerError.invalidJSON)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
}
