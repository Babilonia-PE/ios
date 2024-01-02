//
//  AppConfig.swift
//  Core
//
//  Created by Anna Sahaidak on 7/16/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import CoreLocation.CLLocation

public struct AppConfig: Codable {
    
    public let id: Int = 0
    public let termsURLString: String
    public let privacyURLString: String
    
    public let location: Location?
    public let newVersion: NewVersion?
    
    enum CodingKeys: String, CodingKey {
        case urls
        case location = "defaultLocation"
        case newVersion = "newVersion"
    }
    
    enum UrlsCodingKeys: String, CodingKey {
        case termsURLString = "termsOfUse"
        case privacyURLString = "privacyPolicy"
    }
    
    public init(termsURLString: String, privacyURLString: String, location: Location?, newVersion: NewVersion?) {
        self.termsURLString = termsURLString
        self.privacyURLString = privacyURLString
        self.location = location
        self.newVersion = newVersion
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        location = try container.decode(Location.self, forKey: .location)
        newVersion = try container.decode(NewVersion.self, forKey: .newVersion)
        
        let urls = try container.nestedContainer(keyedBy: UrlsCodingKeys.self, forKey: .urls)
        termsURLString = try urls.decode(String.self, forKey: UrlsCodingKeys.termsURLString)
        privacyURLString = try urls.decode(String.self, forKey: UrlsCodingKeys.privacyURLString)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(location, forKey: .location)
        try container.encode(newVersion, forKey: .newVersion)
        
        var urls = container.nestedContainer(keyedBy: UrlsCodingKeys.self, forKey: .urls)
        try urls.encode(termsURLString, forKey: .termsURLString)
        try urls.encode(privacyURLString, forKey: .privacyURLString)
    }
    
}

extension AppConfig {
    
    public var defaultLocation: CLLocationCoordinate2D? {
        guard let location = location else { return nil }
        
        return CLLocationCoordinate2D(
            latitude: CLLocationDegrees(location.latitude),
            longitude: CLLocationDegrees(location.longitude)
        )
    }
    
}
