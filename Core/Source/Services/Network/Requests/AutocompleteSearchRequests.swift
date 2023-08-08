//
//  AutocompleteSearch.swift
//  Core
//
//  Created by Emily L. on 7/15/21.
//  Copyright © 2021. All rights reserved.
//

import Foundation
import YALAPIClient
import Alamofire

struct AutoCompleteSearchRequest: APIRequest, DecoratableRequest {

    let method: APIRequestMethod = .get
    var path: String {
        "public/search_locations"
    }
    let authRequired = true
    private(set) var parameters: [String: Any]?

    init(address: String,
         perPage: Int = 25,
         page: Int = 1) {
        var params = [String: Any]()
        params["address"] = address
        params["per_page"] = perPage
        params["page"] = page
        parameters = params
    }

}
