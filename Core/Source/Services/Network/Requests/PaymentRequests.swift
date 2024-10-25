//
//  PaymentRequests.swift
//  Core
//
//  Created by Alya Filon  on 02.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import YALAPIClient
import Alamofire

struct DepartmentRequest: APIRequest, DecoratableRequest {

    let path: String = "public/ubigeos?type=department"
    let authRequired: Bool = true
}

struct ProvinceRequest: APIRequest, DecoratableRequest {

    let path: String
    let authRequired: Bool = true
    init(department: String) {
        let text = "public/ubigeos?type=province&department=\(department)"
        path = text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
}

struct DistrictRequest: APIRequest, DecoratableRequest {

    let path: String
    let authRequired: Bool = true
    init(department: String, province: String) {
        let text = "public/ubigeos?type=district&department=\(department)&province=\(province)"
        path = text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
}

struct PaymentPlanRequest: APIRequest, DecoratableRequest {

    let path: String = "public/ad_plans"
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

struct PaymentIntentRequest: APIRequest, DecoratableRequest {

    var path: String {
        "me/payment/intent"
    }
    let authRequired: Bool = true
    var method: APIRequestMethod = .post
    var encoding: APIRequestEncoding? = JSONEncoding.default
    var parameters: [String: Any]? {
        let data: [String: Any] = ["request": "listing",
                                   "product_key": productKey,
                                   "listing_id": listingID
        ]

        return data
    }

    private let listingID: String
    private let productKey: String
    private let clientId: String
    private let publisherRole: String
    
    init(listingID: String, productKey: String, clientId: String, publisherRole: String) {
        self.listingID = listingID
        self.productKey = productKey
        self.clientId = clientId
        self.publisherRole = publisherRole
    }

}

struct OrderNewRequest: APIRequest, DecoratableRequest {

    var path: String {
        "me/order"
    }
    let authRequired: Bool = true
    var method: APIRequestMethod = .post
    var encoding: APIRequestEncoding? = JSONEncoding.default
    var parameters: [String: Any]? {
        let data: [String: Any] = ["request": "listing",
                                   "payment_method": "payu",
                                   "payment_id": paymentId,
                                   "product_key": productKey,
                                   "listing_id": listingID,
                                   "client_id": clientId]

        return data
    }
    
    private let listingID: String
    private let productKey: String
    private let clientId: String
    private let paymentId: String

    init(listingID: String, productKey: String, clientId: String, paymentId: String) {
        self.listingID = listingID
        self.productKey = productKey
        self.clientId = clientId
        self.paymentId = paymentId
    }

}

struct PaymentProcessRequest: APIRequest, DecoratableRequest {

    var path: String {
        "me/payment/process"
    }
    let authRequired: Bool = true
    var method: APIRequestMethod = .post
    var encoding: APIRequestEncoding? = JSONEncoding.default
    var parameters: [String: Any]? {
        let data: [String: Any] = ["deviceSession_id": deviceSessionId,
                                   "payment_type": "card",
                                   "card_number": cardNumber,
                                   "order_id": orderId,
                                   "document_type": "ticket",
                                   "card_cvv": cardCvv,
                                   "card_expiration": cardExpiration,
                                   "card_name": cardName]

        return data
    }
    private let deviceSessionId: String
    private let cardNumber: String
    private let orderId: Int
    private let cardCvv: String
    private let cardExpiration: String
    private let cardName: String

    init(deviceSessionId: String, cardNumber: String, orderId: Int, cardCvv: String, cardExpiration: String, cardName: String) {
        self.deviceSessionId = deviceSessionId
        self.cardNumber = cardNumber
        self.orderId = orderId
        self.cardCvv = cardCvv
        self.cardExpiration = cardExpiration
        self.cardName = cardName
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
