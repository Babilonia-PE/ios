//
//  UserActions.swift
//  Core
//
//  Created by Alya Filon  on 23.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import YALAPIClient
import Alamofire

public enum UserActionType: String {
    case favourite
    case contactView
}

struct TrackUserActionRequest: APIRequest, DecoratableRequest {

    let method: APIRequestMethod = .post
    var path: String {
        var key: String

        switch self.key {
        case .contactView:
            key = "contact_view"
        default:
            key = self.key.rawValue
        }

        return "listings/\(listingID)/user_actions/\(key)"
    }
    let authRequired: Bool = true
    var encoding: APIRequestEncoding? = JSONEncoding.default

    private let listingID: String
    private let key: UserActionType

    init(listingID: String, key: UserActionType) {
        self.listingID = listingID
        self.key = key
    }

}

struct DeleteUserActionRequest: APIRequest, DecoratableRequest {

    let method: APIRequestMethod = .delete
    var path: String {
        var key: String

        switch self.key {
        case .contactView:
            key = "contact_view"
        default:
            key = self.key.rawValue
        }

        return "listings/\(listingID)/user_actions/\(key)"
    }
    let authRequired: Bool = true
    var encoding: APIRequestEncoding? = JSONEncoding.default

    private let listingID: String
    private let key: UserActionType

    init(listingID: String, key: UserActionType) {
        self.listingID = listingID
        self.key = key
    }

}
