//
//  PaymentsProfileModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 27.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Core

enum PaymentsProfileEvent: Event {
    case profileSelected(value: ListingPaymentValue)
}

final class PaymentsProfileModel: EventNode {

    var siteURL: String {
        Environment.default.webSiteURL
    }

    private let listing: Listing?

    init(parent: EventNode, listing: Listing?) {
        self.listing = listing

        super.init(parent: parent)
    }

    func selectProfile(_ profile: PaymentProfileType) {
        raise(event: PaymentsProfileEvent.profileSelected(value: (listing: listing,
                                                                  role: profile.key)))
    }

}
