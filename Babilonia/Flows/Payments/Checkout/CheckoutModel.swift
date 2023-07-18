//
//  CheckoutModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 24.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Core
import Stripe
import RxSwift
import RxCocoa

enum CheckoutEvent: Event { }

final class CheckoutModel: EventNode {

    let requestState = PublishSubject<RequestState>()

    let paymentModel: ListingPaymentModel
    private let paymentService: PaymentService
    private let listingsService: ListingsService

    init(parent: EventNode,
         model: ListingPaymentModel,
         paymentService: PaymentService,
         listingsService: ListingsService) {
        self.paymentModel = model
        self.paymentService = paymentService
        self.listingsService = listingsService

        super.init(parent: parent)
    }

    func checkout(with cardParams: STPPaymentMethodCardParams,
                  authenticationContext: STPAuthenticationContext) {
        guard let listingID = paymentModel.listing?.id else { return }

        requestState.onNext(.started)
        paymentService.purchaseListing(with: "\(listingID)",
                                       productKey: paymentModel.productKey,
                                       publisherRole: paymentModel.role) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let paymentSecret):
                self.confirmPayment(cardParams: cardParams,
                                    clientSecret: paymentSecret.clientSecret,
                                    authenticationContext: authenticationContext)

            case .failure:
                self.requestState.onNext(.finished)
                let state: RequestState = .failedMessage(L10n.Errors.SomethingWentWrong.long)
                self.raise(event: CreateListingFlowEvent.published(listing: self.paymentModel.listing,
                                                                   state: state))
            }
        }
    }

    private func confirmPayment(cardParams: STPPaymentMethodCardParams,
                                clientSecret: String,
                                authenticationContext: STPAuthenticationContext) {
        let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
        paymentIntentParams.paymentMethodParams = paymentMethodParams

        let paymentHandler = STPPaymentHandler.shared()
        paymentHandler.confirmPayment(
            withParams: paymentIntentParams,
            authenticationContext: authenticationContext
        ) { [weak self] (status, _, _) in
            switch status {
            case .failed:
                self?.requestState.onNext(.failedMessage(L10n.Errors.Payment.declined))

            case .canceled:
                self?.requestState.onNext(.finished)
            case .succeeded:
                self?.getListingStatus()
            @unknown default:
                fatalError()
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
                self.requestState.onNext(.failed(error))
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
                self?.requestState.onNext(.failed(error))
            }
        }
    }

    private func togglePaymentStatusWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.getListingStatus()
        }
    }

}
