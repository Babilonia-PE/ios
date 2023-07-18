/// https://gist.github.com/dhiraj/cf8666bbc1ca7efefeb99112cd40c5ad

import Foundation

public struct DictionaryKeyPath {
    var segments: [String]
    
    var isEmpty: Bool { return segments.isEmpty }
    var path: String {
        return segments.joined(separator: ".")
    }
    
    /// Strips off the first segment and returns a pair
    /// consisting of the first segment and the remaining key path.
    /// Returns nil if the key path has no segments.
    func headAndTail() -> (head: String, tail: DictionaryKeyPath)? {
        guard !isEmpty else { return nil }
        var tail = segments
        let head = tail.removeFirst()
        return (head, DictionaryKeyPath(segments: tail))
    }
}

/// Initializes a DictionaryKeyPath with a string of the form "this.is.a.keypath"
extension DictionaryKeyPath {
    init(_ string: String) {
        segments = string.components(separatedBy: ".")
    }
}

extension DictionaryKeyPath: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
}

// Needed because Swift 3.0 doesn't support extensions with concrete
// same-type requirements (extension Dictionary where Key == String).
public protocol DictionaryStringProtocol {
    init(string: String)
}

extension String: DictionaryStringProtocol {
    public init(string: String) {
        self = string
    }
}

public extension Dictionary where Key: DictionaryStringProtocol {
    subscript(keyPath keyPath: DictionaryKeyPath) -> Any? {
        get {
            switch keyPath.headAndTail() {
            case nil:
                // key path is empty.
                return nil
            case let (head, remainingDictionaryKeyPath)? where remainingDictionaryKeyPath.isEmpty:
                // Reached the end of the key path.
                let key = Key(string: head)
                return self[key]
            case let (head, remainingDictionaryKeyPath)?:
                // Key path has a tail we need to traverse.
                let key = Key(string: head)
                switch self[key] {
                case let nestedDict as [Key: Any]:
                    // Next nest level is a dictionary.
                    // Start over with remaining key path.
                    return nestedDict[keyPath: remainingDictionaryKeyPath]
                default:
                    // Next nest level isn't a dictionary.
                    // Invalid key path, abort.
                    return nil
                }
            }
        }
        set {
            switch keyPath.headAndTail() {
            case nil:
                // key path is empty.
                return
            case let (head, remainingDictionaryKeyPath)? where remainingDictionaryKeyPath.isEmpty:
                // Reached the end of the key path.
                let key = Key(string: head)
                self[key] = newValue as? Value
            case let (head, remainingDictionaryKeyPath)?:
                let key = Key(string: head)
                let value = self[key]
                switch value {
                case var nestedDict as [Key: Any]:
                    // Key path has a tail we need to traverse
                    nestedDict[keyPath: remainingDictionaryKeyPath] = newValue
                    self[key] = nestedDict as? Value
                default:
                    // Invalid keyPath
                    return
                }
            }
        }
    }
}
