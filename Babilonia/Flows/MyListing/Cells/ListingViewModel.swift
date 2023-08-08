//
//  ListingViewModel.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/1/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Core

typealias ListingStatisticsValue = (views: Int, likes: Int, contacts: Int)

final class ListingViewModel {
    
    var priceUpdated: Driver<String> { return price.asDriver() }
    var pricePerSquareMeterUpdated: Driver<String> { return pricePerSquareMeter.asDriver() }

    var listingID: Int {
        listing.id
    }
    
    var originalPrice: Int {
        return listing.price ?? 0
    }
    
    var coverImage: ListingImage? {
        return listing.primaryImage
    }
    
    var propertyType: PropertyType? {
        return listing.propertyType
    }
    
    var isMarkedFavorite: Bool {
        return listing.favourited ?? false
    }

    var address: String? { return listing.location?.address }
    
    var fullAddress: String? {
        let addressArray = (listing.location?.address ?? "").split(separator: ",")
        var address = addressArray.isEmpty ? "" : String(addressArray[0])
        if let district = listing.location?.district {
            address += ", \(district)"
        }
        
        if let department = listing.location?.department {
            address += ", \(department)"
        }
              
        return address
    }

    var inlinePropertiesInfo: InlinePropertiesInfo {
        return InlinePropertiesConfig.list(listing).info
    }

    var imagePath: String? {
        return listing.primaryImage?.photo.renderURLString
    }

    var createdAt: String {
        listing.createdAt.dateString()
    }
    
    var listingType: ListingType? {
        return listing.listingType
    }
    
    var propertyTypeSettings: (title: String?, icon: UIImage?) {
        switch listing.propertyType {
        case .apartment?:
            return (L10n.MyListings.PropertyType.Apartments.title, Asset.CreateListing.createListingPageCommon.image)
            
        case .house?:
            return (L10n.MyListings.PropertyType.House.title, Asset.MyListings.myListingsHouseIcon.image)
            
        case .commercial?:
            return (L10n.MyListings.PropertyType.Commercial.title, Asset.MyListings.myListingsCommercialIcon.image)
            
        case .office?:
            return (L10n.MyListings.PropertyType.Office.title, Asset.MyListings.myListingsOfficeIcon.image)
            
        case .land?:
            return (L10n.MyListings.PropertyType.Land.title, Asset.MyListings.myListingsLandIcon.image)

        case .room?:
            return (L10n.CreateListing.Common.PropertyType.Room.title, Asset.MyListings.myListingsRoomIcon.image)

        default:
            return (nil, nil)
        }
    }
    
    var listingTypeSettings: (title: String?, color: UIColor?) {
        switch listing.listingType {
        case .sale?:
            return (L10n.Common.For.text(L10n.MyListings.ListingType.Sale.title), Asset.Colors.hippieBlue.color)
            
        case .rent?:
            return (L10n.Common.For.text(L10n.MyListings.ListingType.Rent.title), Asset.Colors.orange.color)
            
        default:
            return (nil, nil)
        }
    }
    
    var listingStatusTitleSettings: (title: String, textColor: UIColor) {
        if listing.status == .draft {
            return (L10n.MyListings.Status.Draft.title, .black)
        }

        switch listing.state {
        case .notPublished:
            return (L10n.MyListings.Status.Hidden.title, .black)
        case .published:
            return (L10n.MyListings.Status.Visible.title, .white)
        default:
            return (L10n.MyListings.Status.Unpublished.title, .black)
        }
    }
    
    var listingStatusColor: UIColor {
        switch (listing.status, listing.isPurchased) {
        case (.visible, true):
            return Asset.Colors.mandy.color
            
        case (.visible, false):
            return Asset.Colors.whiteLilac.color
            
        case (.hidden, _):
            return Asset.Colors.whiteLilac.color
            
        case (.draft, _):
            return Asset.Colors.whiteLilac.color
        }
    }
    
    var originalArea: Int? {
        return listing.area
    }

    var displayArea: String? {
        guard
            let area = listing.area,
            area > 0,
            let areaString = NumberFormatter.integerFormatter.string(from: NSNumber(value: area))
            else { return nil }
        
        return L10n.MyListings.Area.abbreviation(areaString)
    }

    var statistics: ListingStatisticsValue {
        if listing.state == .notPublished || listing.status == .draft {
            return (views: 0, likes: 0, contacts: 0)
        } else {
            return (views: listing.viewsCount,
                    likes: listing.favouritesCount,
                    contacts: listing.contactViewsCount ?? 0)
        }
    }

    var paymentPlanViewModel: ListingPaymentPlanViewModel?
    let isUserOwnedListing: Bool
    
    private let price = BehaviorRelay(value: "")
    private let pricePerSquareMeter = BehaviorRelay(value: "")

    private let listing: Listing
    private let configsService: ConfigurationsService
    
    // MARK: - lifecycle
    
    deinit {
        configsService.removeObserver(self)
    }
    
    init(listing: Listing, configsService: ConfigurationsService, isUserOwnedListing: Bool) {
        self.listing = listing
        self.configsService = configsService
        self.isUserOwnedListing = isUserOwnedListing
        
        updatePrice()
        updatePricePerSquareMeter()
        configsService.addObserver(self)
        paymentPlanViewModel = ListingPaymentPlanViewModel(listing: listing,
                                                           isUserOwnedListing: isUserOwnedListing)
    }
    
    private func updatePrice() {
        let priceSettings = configsService.formatPrice(listing.price ?? 0)
        let priceString = NumberFormatter.integerFormatter.string(from: NSNumber(value: priceSettings.price)) ?? "0"
        price.accept(priceSettings.code + priceString)
    }
    
    private func updatePricePerSquareMeter() {
        let priceSettings = configsService.formatPrice(listing.price ?? 0)
        let result: String
        switch listing.listingType {
        case .sale?:
            result = L10n.ListingDetails.PricePerSquareMeter.text(
                priceSettings.code,
                priceSettings.price / max(originalArea ?? 1, 1)
            )
        case .rent?:
            result = L10n.ListingDetails.PricePerMonth.text
        case nil:
            result = ""
        }
        pricePerSquareMeter.accept(result)
    }
    
}

extension ListingViewModel: CurrencyObserver {
    
    func currencyChanged(_ currency: Currency) {
        updatePrice()
        updatePricePerSquareMeter()
    }
    
}

extension ListingViewModel: AnnotationViewModel {
    
    var annotationInlinePropertiesInfo: InlinePropertiesInfo {
        return InlinePropertiesConfig.annotation(listing).info
    }

}

extension ListingViewModel: ListingTypeDataProvider {}
