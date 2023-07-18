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
    var path = "currency_rate"
    let authRequired: Bool = true
    private(set) var parameters: [String: Any]?
    
    init(fromCurrency: String, toCurrency: String) {
        parameters = ["data[from]": fromCurrency, "data[to]": toCurrency]
    }
    
}
