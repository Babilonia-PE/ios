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
    private let clientPayment: NetworkClient
    
    public init(client: NetworkClient, clientPayment: NetworkClient) {
        self.client = client
        self.clientPayment = clientPayment
    }

    public func getPaymentPlan(completion: @escaping (Result<[PaymentPlan]>) -> Void) {
        let request = PaymentPlanRequest()
        let parser = DecodableParser<[PaymentPlan]>(keyPath: "data.records")

        clientPayment.execute(request: request, parser: parser, completion: completion)
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
    
    public func paymentIntent(with listingID: String,
                              productKey: String,
                              clientId: String,
                              publisherRole: String,
                              completion: @escaping (Result<PaymentIntent>) -> Void) {
        let request = PaymentIntentRequest(listingID: listingID,
                                           productKey: productKey,
                                           clientId: clientId,
                                           publisherRole: publisherRole)
        let parser = DecodableParser<PaymentIntent>(keyPath: "data")
        
        clientPayment.execute(request: request, parser: parser, completion: completion)
    }
    
    public func paymentProcess(with deviceSessionId: String,
                               cardNumber: String,
                               orderId: Int,
                               cardCvv: String,
                               cardExpiration: String,
                               cardName: String,
                               completion: @escaping (Result<GeneralRespose>) -> Void) {
        let request = PaymentProcessRequest(deviceSessionId: deviceSessionId,
                                       cardNumber: cardNumber,
                                       orderId: orderId,
                                       cardCvv: cardCvv,
                                       cardExpiration: cardExpiration,
                                       cardName: cardName)
        let parser = DecodableParser<GeneralRespose>(keyPath: "data")
        clientPayment.execute(request: request, parser: parser, completion: completion)
    }
    
    public func listingPublishingStatus(with listingID: String,
                                        completion: @escaping (Result<PublishingStatus>) -> Void) {
        let request = ListingPublishingStatusRequest(listingID: listingID)
        let parser = DecodableParser<PublishingStatus>(keyPath: "data")

        client.execute(request: request, parser: parser, completion: completion)
    }

}
