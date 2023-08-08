//
//  CurrencyRequests.swift
//  Core
//
//  Created by Anna Sahaidak on 7/24/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import YALAPIClient

struct CurrencyRateRequest: APIRequest, DecoratableRequest {

    let method: APIRequestMethod = .get
    var path = "public/currency_rate"
    let authRequired: Bool = false
    private(set) var parameters: [String: Any]?
    
    init(fromCurrency: String, toCurrency: String) {
        parameters = ["data_from": fromCurrency, "data_to": toCurrency]
    }
    
}
