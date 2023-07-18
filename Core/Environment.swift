import Foundation

public struct Environment: Codable {
    
    public var name: String = "undefined"
    public var hostURL: URL = URL(string: "localhost")!
    public var stripePublishableKey: String!
    public var deeplinkHost: String!
    public var webSiteURL: String!
    
    public static let `default` = Environment(named: "Environment") ?? Environment()
}

extension Environment {
    
    public init?(named name: String, in bundle: Bundle = .main) {
        if
            let url = Bundle.main.url(forResource: name, withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let value = try? PropertyListDecoder().decode(Environment.self, from: data)
        {
            self = value
        } else {
            return nil
        }
    }
}
