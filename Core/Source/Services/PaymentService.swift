//
//  PaymentService.swift
//  Core
//
//  Created by Alya Filon  on 02.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation
import YALAPIClient

final public class PaymentService: NSObject {

    private let client: NetworkClient

    public init(client: NetworkClient) {
        self.client = client
    }

    public func getPaymentPlan(completion: @escaping (Result<[PaymentPlan]>) -> Void) {
        let request = PaymentPlanRequest()
        let parser = DecodableParser<[PaymentPlan]>(keyPath: "data.records")

        client.execute(request: request, parser: parser, completion: completion)
    }

    public func purchaseListing(with listingID: String,
                                productKey: String,
                                publisherRole: String,
                                completion: @escaping (Result<PaymentClientSecret>) -> Void) {
        let request = PurchaseListingRequest(listingID: listingID,
                                             productKey: productKey,
                                             publisherRole: publisherRole)
        let parser = DecodableParser<PaymentClientSecret>(keyPath: "data")

        client.execute(request: request, parser: parser, completion: completion)
    }

    public func listingPublishingStatus(with listingID: String,
                                        completion: @escaping (Result<PublishingStatus>) -> Void) {
        let request = ListingPublishingStatusRequest(listingID: listingID)
        let parser = DecodableParser<PublishingStatus>(keyPath: "data")

        client.execute(request: request, parser: parser, completion: completion)
    }

}
