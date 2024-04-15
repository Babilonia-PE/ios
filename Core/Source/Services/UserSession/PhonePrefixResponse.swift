//created on  11/04/24

import Foundation

public struct PhonePrefixResponse: Codable {
    public let records: [PhonePrefix]?
}

public struct PhonePrefix: Codable {
    public var name: String?
    public var prefix: Int?
    public var mask: String?
    public var isoCode: String?
}
