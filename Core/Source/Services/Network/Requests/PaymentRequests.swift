//
//  PaymentRequests.swift
//  Core
//
//  Created by Alya Filon  on 02.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import YALAPIClient
import Alamofire

struct PaymentPlanRequest: APIRequest, DecoratableRequest {

    let path: String = "ad_plans"
    let authRequired: Bool = true
    var encoding: APIRequestEncoding? = JSONEncoding.default

}

struct PurchaseListingRequest: APIRequest, DecoratableRequest {

    var path: String {
        "users/me/listings/\(listingID)/stripe_payment_intents"
    }
    let authRequired: Bool = true
    var method: APIRequestMethod = .post
    var encoding: APIRequestEncoding? = JSONEncoding.default
    var parameters: [String: Any]? {
        let data: [String: Any] = ["product_key": productKey,
                                   "publisher_role": publisherRole]

        return ["data": data]
    }

    private let listingID: String
    private let productKey: String
    private let publisherRole: String

    init(listingID: String, productKey: String, publisherRole: String) {
        self.listingID = listingID
        self.productKey = productKey
        self.publisherRole = publisherRole
    }

}

struct ListingPublishingStatusRequest: APIRequest, DecoratableRequest {

    var path: String {
        "users/me/listings/\(listingID)/publishing_status"
    }
    let authRequired: Bool = true
    var encoding: APIRequestEncoding? = JSONEncoding.default

    private let listingID: String

    init(listingID: String) {
        self.listingID = listingID
    }

}
