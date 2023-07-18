//
//  ListingPaymentModels.swift
//  Babilonia
//
//  Created by Alya Filon  on 29.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import Core

typealias ListingPaymentValue = (listing: Listing?, role: String)

enum PaymentProfileType: Int, CaseIterable {
    case owner
    case realtor
    case constructionCompany

    var icon: UIImage {
        switch self {
        case .owner: return Asset.Payments.profileOwnerIcon.image
        case .realtor: return Asset.Payments.profileRealtorDisabledIcon.image
        case .constructionCompany: return Asset.Payments.profileCompanyDisabledIcon.image
        }
    }

    var title: String {
        switch self {
        case .owner: return L10n.Payments.Profile.owner
        case .realtor: return L10n.Payments.Profile.realtor
        case .constructionCompany: return L10n.Payments.Profile.company
        }
    }

    var key: String {
        switch self {
        case .owner: return "owner"
        case .realtor: return "realtor"
        case .constructionCompany: return "construction_company"
        }
    }

    var titleColor: UIColor {
        switch self {
        case .owner: return Asset.Colors.almostBlack.color
        case .realtor, .constructionCompany: return Asset.Colors.bluishGrey.color
        }
    }
}

struct PaymentPeriodContentModel {

    var key: String {
        paymentProduct.key
    }

    var period: String {
        L10n.Payments.Period.days(paymentProduct.duration)
    }

    var periodDescription: String? {
        paymentProduct.comment.isEmpty == true ? nil : paymentProduct.comment
    }

    var price: String {
        let converteredPrice = "\(paymentProduct.price)".priceSufixConverted()

        return "S/ " + converteredPrice
    }

    let planKey: PaymentPlanKey
    private let paymentProduct: PaymentProduct

    init(paymentProduct: PaymentProduct, planKey: PaymentPlanKey) {
        self.paymentProduct = paymentProduct
        self.planKey = planKey
    }

}

struct ListingPaymentModel {

    let listing: Listing?
    let role: String

    var productKey: String {
        period.key
    }

    var price: String {
        period.price
    }

    var days: String {
        "/ " + period.period
    }

    var icon: UIImage? {
        switch period.planKey {
        case .standard: return nil
        case .plus: return Asset.Payments.plusIcon.image
        case .premium: return Asset.Payments.premiumIcon.image
        }
    }

    var color: UIColor {
        switch period.planKey {
        case .standard: return Asset.Colors.hippieBlue.color
        case .plus: return Asset.Colors.orange.color
        case .premium: return Asset.Colors.biscay.color
        }
    }

    var title: String {
        switch period.planKey {
        case .standard: return L10n.Payments.PlanTitle.standard
        case .plus: return L10n.Payments.PlanTitle.plus
        case .premium: return L10n.Payments.PlanTitle.premium
        }
    }

    private let period: PaymentPeriodContentModel

    init(listing: Listing?,
         role: String,
         period: PaymentPeriodContentModel) {
        self.listing = listing
        self.role = role
        self.period = period
    }

}

struct ListingPaymentPlanViewModel {

    var purchaseDate: String {
        listing.adPurchasedAt?.dateString() ?? ""
    }

    var daysLeft: String {
        if let adPurchasedAt = listing.adPurchasedAt,
           let adExpiresAt = listing.adExpiresAt {
            return adPurchasedAt.daysLeft(endDate: adExpiresAt)
        } else {
            return ""
        }
    }

    var color: UIColor {
        switch listing.adPlan {
        case .standard: return Asset.Colors.hippieBlue.color
        case .plus: return Asset.Colors.orange.color
        case .premium: return Asset.Colors.biscay.color
        default: return Asset.Colors.biscay.color
        }
    }

    var backgroundColor: UIColor {
        switch listing.adPlan {
        case .standard: return Asset.Colors.hippieBlue.color.withAlphaComponent(0.15)
        case .plus: return Asset.Colors.bleachWhite.color
        case .premium: return Asset.Colors.premiumPlanBackground.color
        default: return .white
        }
    }

    var icon: UIImage? {
        switch listing.adPlan {
        case .plus: return Asset.Payments.plusIcon.image
        case .premium: return Asset.Payments.premiumIcon.image
        default: return nil
        }
    }

    var title: String {
        switch listing.adPlan {
        case .standard: return L10n.Payments.ListingPlan.standard
        case .plus: return L10n.Payments.ListingPlan.plus
        case .premium: return L10n.Payments.ListingPlan.premium
        default: return ""
        }
    }

    var isStandardPlan: Bool {
        (listing.adPlan ?? .standard) == .standard
    }

    var isListingPublished: Bool {
        listing.state == .published
    }

    var isListingExpired: Bool {
        listing.state == .expired
    }

    var isPlanPurchased: Bool {
        listing.isPurchased
    }

    let isUserOwnedListing: Bool

    private let listing: Listing

    init(listing: Listing, isUserOwnedListing: Bool) {
        self.listing = listing
        self.isUserOwnedListing = isUserOwnedListing
    }
}
