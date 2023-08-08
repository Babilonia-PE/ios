//
//  CheckoutModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 24.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Core
//import Stripe
import RxSwift
import RxCocoa

enum CheckoutEvent: Event { }

final class CheckoutModel: EventNode {

    let requestState = PublishSubject<RequestState>()

    let paymentModel: ListingPaymentModel
    private let paymentService: PaymentService
    private let listingsService: ListingsService
    private let userService: UserService
    
    init(parent: EventNode,
         model: ListingPaymentModel,
         paymentService: PaymentService,
         listingsService: ListingsService,
         userService: UserService) {
        self.paymentModel = model
        self.paymentService = paymentService
        self.listingsService = listingsService
        self.userService = userService

        super.init(parent: parent)
    }
    
    func checkoutPayu(cardNumber: String,
                      cardCvv: String,
                      cardExpiration: String,
                      cardName: String) {
        guard let listingID = paymentModel.listing?.id else { return }
        
        requestState.onNext(.started)
        paymentService.paymentIntent(with: "\(listingID)",
                                     productKey: paymentModel.productKey,
                                     clientId: "\(userService.userID)",
                                     publisherRole: paymentModel.role,
                                     completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let paymentIntent):
                self.paymentProcess(cardNumber: cardNumber,
                               cardCvv: cardCvv,
                               cardExpiration: cardExpiration,
                               cardName: cardName,
                               paymentIntent: paymentIntent)
            case .failure(let error):
                if self.isUnauthenticated(error) {
                    self.raise(event: MainFlowEvent.logout)
                } else {
                    self.requestState.onNext(.finished)
                    let state: RequestState = .failed(error)
                    self.raise(event: CreateListingFlowEvent.published(listing: self.paymentModel.listing, state: state))
                }
            }
        })
    }
    
    private func paymentProcess(cardNumber: String,
                                cardCvv: String,
                                cardExpiration: String,
                                cardName: String,
                                paymentIntent: PaymentIntent) {
        paymentService.paymentProcess(with: paymentIntent.deviceSessionId,
                                      cardNumber: cardNumber,
                                 orderId: paymentIntent.orderId,
                                 cardCvv: cardCvv,
                                 cardExpiration: cardExpiration,
                                 cardName: cardName) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                if response.status == "ok" {
                    self.procceedPaymentListing { [weak self] listing in
                        let state: RequestState = .success(L10n.Payments.Alert.listingPublishedSuccess)
                        self?.raise(event: CreateListingFlowEvent.published(listing: listing,
                                                                            state: state))
                    }
                } else {
                    self.requestState.onNext(.finished)
                    let state: RequestState = .failedMessage(L10n.Errors.SomethingWentWrong.long)
                    self.raise(event: CreateListingFlowEvent.published(listing: self.paymentModel.listing,
                                                                       state: state))
                }
          //      self.getListingStatus()
            case .failure(let error):
                self.requestState.onNext(.finished)
                let state: RequestState = .failed(error)
                self.raise(event: CreateListingFlowEvent.published(listing: self.paymentModel.listing, state: state))
            }
        }
    }
    
    private func getListingStatus() {
        guard let listingID = paymentModel.listing?.id else { return }

        paymentService.listingPublishingStatus(with: "\(listingID)") { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let paymentStatus):
                switch paymentStatus.status {
                case .paymentFailed:
                    self.requestState.onNext(.finished)
                    let state: RequestState = .failedMessage(L10n.Errors.SomethingWentWrong.long)
                    self.raise(event: CreateListingFlowEvent.published(listing: self.paymentModel.listing,
                                                                       state: state))
                case .succeeded:
                    self.procceedPaymentListing { [weak self] listing in
                        let state: RequestState = .success(L10n.Payments.Alert.listingPublishedSuccess)
                        self?.raise(event: CreateListingFlowEvent.published(listing: listing,
                                                                           state: state))
                    }

                default:
                    self.togglePaymentStatusWithDelay()
                }
            case .failure(let error):
                if self.isUnauthenticated(error) {
                    self.raise(event: MainFlowEvent.logout)
                } else {
                    self.requestState.onNext(.failed(error))
                }
            }
        }
    }

    private func procceedPaymentListing(successCompletion: @escaping ((Listing?) -> Void)) {
        guard let listingID = paymentModel.listing?.id else { return }

        listingsService.getListingDetails(for: "\(listingID)") { [weak self] result in
            switch result {
            case .success(let listing):
                self?.requestState.onNext(.finished)
                successCompletion(listing)

            case .failure(let error):
                if self?.isUnauthenticated(error) == true {
                    self?.raise(event: MainFlowEvent.logout)
                } else {
                    self?.requestState.onNext(.failed(error))
                }
            }
        }
    }

    private func togglePaymentStatusWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.getListingStatus()
        }
    }

    private func isUnauthenticated(_ error: Error?) -> Bool {
        guard let serverError = error as? CompositeServerError,
              let code = serverError.errors.first?.code else { return false }
        
        return code == .unauthenticated
    }
}
