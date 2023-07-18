import Foundation

final class IDGen {
    
    static var `default`: String {
        let bundleID = Bundle(for: IDGen.self).bundleIdentifier!.lowercased()
        return bundleID
    }
    
    static func make(for value: String) -> String {
        return "\(IDGen.default).\(value)"
    }
    
}
