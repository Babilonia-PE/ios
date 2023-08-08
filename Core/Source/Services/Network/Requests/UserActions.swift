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
    case phoneView
    case whatsappView
    case viewsView
}

struct TrackUserActionRequest: APIRequest, DecoratableRequest {

    let method: APIRequestMethod = .post
    var path: String {
        return "me/user_actions"
    }
    let authRequired: Bool = true
    var encoding: APIRequestEncoding? = JSONEncoding.default
    
    private(set) var parameters: [String: Any]?

    init(
        listingID: String,
        key: UserActionType,
        ipAddress: String,
        userAgent: String,
        signProvider: String
    ) {
        var params = [String: Any]()
        params["listing_id"] = listingID
        params["step"] = 1
        params["ipa"] = ipAddress
        params["ua"] = userAgent
        params["sip"] = signProvider
        
        switch key {
        case .phoneView:
            params["key"] = "phone_view"
        case .whatsappView:
            params["key"] = "whatsapp_view"
        case .favourite:
            params["key"] = "favourite"
        case .viewsView:
            params["key"] = "views_view"
        default:
            break
        }
        
        parameters = params
    }

}

struct DeleteUserActionRequest: APIRequest, DecoratableRequest {

    let method: APIRequestMethod = .delete
    var path: String {
        return "me/user_actions"
    }
    let authRequired: Bool = true
    var encoding: APIRequestEncoding? = JSONEncoding.default
    
    private(set) var parameters: [String: Any]?

    init(
        listingID: String,
        key: UserActionType,
        ipAddress: String,
        userAgent: String,
        signProvider: String
    ) {
        var params = [String: Any]()
        params["listing_id"] = listingID
        params["ipa"] = ipAddress
        params["ua"] = userAgent
        params["sip"] = signProvider
        
        switch key {
        case .phoneView:
            params["key"] = "phone_view"
        case .whatsappView:
            params["key"] = "whatsapp_view"
        case .favourite:
            params["key"] = "favourite"
        case .viewsView:
            params["key"] = "views_view"
        default:
            break
        }
        
        parameters = params
    }

}
