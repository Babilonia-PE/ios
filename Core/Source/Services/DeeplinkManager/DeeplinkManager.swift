//
//  DeeplinkManager.swift
//  Core
//
//  Created by Alya Filon  on 07.12.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation

public enum PathParameterName {
    case home
    case listings
    case privacyPolicy

    public var name: String {
        switch self {
        case .home: return ""
        case .listings: return "listings"
        case .privacyPolicy: return "privacy_policy"
        }
    }
}

public enum LinkScheme: String {
    case babilonia
    case external

    var host: String {
        switch self {
        case .babilonia: return "babilonia.io"
        case .external: return ""
        }
    }
}

public enum LinkAction {
    case home
    case listingDetails(id: String)
    case privacyPolicy
}

public typealias DeeplinkResult = (success: Bool, parameters: [String: String]?)

public protocol DeeplinkManagerDelegate: class {

    func handler(_ handler: DeeplinkManager,
                 didHandleLink linkType: LinkScheme,
                 action: LinkAction?)
    func handlerDidFailToHandleLink(_ handler: DeeplinkManager)

}

public final class DeeplinkManager {

    public weak var delegate: DeeplinkManagerDelegate?

    public init() {}

    public func handleLink(_ link: URL) -> Bool {
        if link.isBabiloniaAppLink {
            var linkAction: LinkAction = .home

            switch link.absoluteString {
            case let link where link.contains(PathParameterName.privacyPolicy.name):
                linkAction = .privacyPolicy
            case let link where link.contains(PathParameterName.listings.name):
                let parts = link.components(separatedBy: "/")
                if let id = parts.first(where: { Int($0) != nil }) {
                    linkAction = .listingDetails(id: id)
                }
            default:
                break
            }

            delegate?.handler(self, didHandleLink: .babilonia, action: linkAction)

        } else {
            delegate?.handler(self, didHandleLink: .external, action: nil)
        }

        return true
    }

}

public extension URL {

    var isBabiloniaAppScheme: Bool {
        guard
            let scheme = scheme,
            let host = host,
            scheme == LinkScheme.babilonia.rawValue,
            host == LinkScheme.babilonia.host
            else { return false }

        return true
    }

    var isBabiloniaAppLink: Bool {
        guard
            let host = host,
            host == Environment.default.deeplinkHost || host.contains("babilonia.io")
            else { return false }

        return true
    }

}
