//
//  ListingDetailsViewModel.swift
//  Babilonia
//
//  Created by Denis on 7/11/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation.CLLocation

final class ListingDetailsViewModel {
    
    var photosUpdated: Driver<[ListingDetailsImage]> { return model.photosUpdated }
    var commonInfoUpdated: Driver<ListingDetailsCommonInfo> {
        return model.listingUpdated.map { [weak self] in
            ListingDetailsCommonInfo(
                listing: $0,
                currencyCode: self?.model.priceSettings.code ?? "",
                price: self?.model.priceSettings.price ?? 0
            )
        }
    }
    var addressInfoUpdated: Driver<ListingDetailsAddressInfo> {
        return model.listingUpdated.map { ListingDetailsAddressInfo(listing: $0) }
    }
    var descriptionUpdated: Driver<ListingDetailsDescriptionInfo> {
        return model.listingUpdated.map { ListingDetailsDescriptionInfo(listing: $0) }
    }
    var facilitiesUpdated: Driver<[ListingDetailsFacilityInfo]> {
        return model.listingUpdated.map { [ListingDetailsFacilityInfo](listing: $0, initType: .facilities) }
    }
    var advancedDetailsUpdated: Driver<[ListingDetailsFacilityInfo]> {
        return model.listingUpdated.map { [ListingDetailsFacilityInfo](listing: $0, initType: .advancedDetails) }
    }
    var paymentPlanViewModel: ListingPaymentPlanViewModel? {
        model.paymentPlanViewModel
    }
    var isUserOwnedListing: Bool {
        model.isUserOwnedListing
    }
    
    private let model: ListingDetailsModel
    
    init(model: ListingDetailsModel) {
        self.model = model
    }
    
    func showDescription() {
        model.showDescription()
    }
    
}

private extension ListingDetailsCommonInfo {
    
    init(listing: Listing?, currencyCode: String, price: Int) {
        let perSquareMeterString: String
        switch listing?.listingType {
        case .sale?:
            perSquareMeterString = L10n.ListingDetails.PricePerSquareMeter.text(
                currencyCode,
                price / (listing?.area ?? 1)
            )
        case .rent?:
            perSquareMeterString = L10n.ListingDetails.PricePerMonth.text
        case nil:
            perSquareMeterString = ""
        }
        let priceString = currencyCode + (NumberFormatter.integerFormatter.string(from: NSNumber(value: price)) ?? "0")
        var userName = ""
        if let contactName = listing?.contact?.contactName {
            userName = contactName
        } else {
            //userName = "\(listing?.user.firstName ?? "") \((listing?.user.lastName ?? "").prefix(1))."
            userName = listing?.user.fullName ?? ""
        }
        
        self = ListingDetailsCommonInfo(
            price: priceString,
            pricePerSquareMeter: perSquareMeterString,
            userImageURLString: listing?.user.avatar?.smallURLString,
            userName: userName,
            propertyType: listing?.propertyType,
            listingType: listing?.listingType,
            inlinePropertiesInfo: listing.flatMap { InlinePropertiesConfig.details($0).info }
                ?? InlinePropertiesInfo(strings: [], attributedStrings: [], color: .clear),
            areasInlinePropertiesInfo: listing.flatMap { InlinePropertiesConfig.areas($0).info }
                ?? InlinePropertiesInfo(strings: [], attributedStrings: [], color: .clear),
            isPetFriendly: listing?.petFriendly ?? false
        )
    }
    
}

private extension ListingDetailsAddressInfo {
    
    init(listing: Listing?) {
        let addressArray = (listing?.location?.address ?? "").split(separator: ",")
        var address = String(addressArray[0])
        if let district = listing?.location?.district {
            address += ", \(district)"
        }
        
        if let department = listing?.location?.department {
            address += ", \(department)"
        }
        
        self = ListingDetailsAddressInfo(
            title: address,
            coordinate: CLLocationCoordinate2D(
                latitude: CLLocationDegrees(listing?.location?.latitude ?? 0.0),
                longitude: CLLocationDegrees(listing?.location?.longitude ?? 0.0)
            ),
            propertyType: listing?.propertyType
        )
    }
    
}

private extension ListingDetailsDescriptionInfo {
    
    init(listing: Listing?) {
        let totalFloors = listing?.totalFloorsCount == 0 ? nil : listing?.totalFloorsCount
        let floorNumber = listing?.floorNumber == 0 ? nil : listing?.floorNumber
        self = ListingDetailsDescriptionInfo(
            yearOfConstruction: listing?.yearOfConstruction,
            floorNumber: floorNumber,
            totalFloors: totalFloors,
            descriptionText: listing?.listingDescription ?? ""
        )
    }
    
}

private extension Array where Element == ListingDetailsFacilityInfo {
    
    init(listing: Listing?, initType: ListingDetailsFacilityInfo.InitType) {
        switch initType {
        case .facilities:
            self = listing?.facilities?
                .sorted { $0.id < $1.id }
                .map {
                    ListingDetailsFacilityInfo(
                        title: $0.title,
                        imageURL: URL(string: $0.iconIos?.originalURLString ?? "")
                    )
                } ?? []
        case .advancedDetails:
            self = listing?.advancedDetails?
                .sorted { $0.id < $1.id }
                .map {
                    ListingDetailsFacilityInfo(
                        title: $0.title,
                        imageURL: URL(string: $0.iconIos?.originalURLString ?? "")
                    )
                } ?? []
        }
    }
    
}
