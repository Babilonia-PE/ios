//
//  Listing.swift
//  Core
//
//  Created by Denis on 6/24/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

public enum ListingType: String, CaseIterable, Codable {
    case sale, rent
}

public enum PropertyType: String, CaseIterable, Codable {
    case apartment,
         house,
         commercial,
         office,
         land,
         room,
         localIndustrial = "local_industrial",
         landAgricultural = "land_agricultural",
         landIndustrial = "land_industrial",
         landCommercial = "land_commercial",
         cottage,
         beachHouse = "beach_house",
         building,
         hotel,
         deposit,
         parking,
         airs
    
}

public enum ListingStatus: String, Codable {
    case draft, hidden, visible
}

public enum ListingState: String, Codable {
    case published, notPublished = "not_published", expired, unpublished
}

public enum ListingRole: String, Codable {
    case realtor, owner
}

public enum PlanType: String, Codable {
    case standard, plus, premium
}

public typealias ListingId = Int

public struct Listing: Codable {
    
    public var area: Int?
    public var bathroomsCount: Int?
    public var bedroomsCount: Int?
    public var contactViewsCount: Int?
    public var favouritesCount: Int
    public var favourited: Bool?
    public var id: ListingId
    public var listingDescription: String?
    public var listingType: ListingType?
    public var parkingSlotsCount: Int?
    public var petFriendly: Bool?
    public var price: Int?
    public var primaryImageId: Int?
    public var propertyType: PropertyType?
    public var status: ListingStatus
    public var role: ListingRole?
    public var viewsCount: Int
    public var yearOfConstruction: Int?
    public var createdAt: Date
    public var adPurchasedAt: Date?
    public var adExpiresAt: Date?
    public var adPlan: PlanType?
    public var state: ListingState
    public var coveredArea: Int?
    public var parkingForVisits: Bool?
    public var totalFloorsCount: Int?
    public var floorNumber: Int?

    public var user: User
    public var contact: Contact?
    public var location: Location?
    public var images: [ListingImage]?
    public var facilities: [Facility]?
    public var advancedDetails: [Facility]?
    public var url: Url?
    
    public var isEdit: Bool = false

    //55547 TODO: - Remove it.

    public init(area: Int?,
                bathroomsCount: Int?,
                bedroomsCount: Int?,
                contactViewsCount: Int?,
                favouritesCount: Int,
                favourited: Bool = false, id: ListingId,
                listingDescription: String?,
                listingType: ListingType?,
                parkingSlotsCount: Int?,
                petFriendly: Bool?, price: Int?,
                primaryImageId: Int?,
                propertyType: PropertyType?,
                status: ListingStatus,
                viewsCount: Int,
                yearOfConstruction: Int?,
                createdAt: Date,
                adPurchasedAt: Date?,
                adExpiresAt: Date?,
                adPlan: PlanType?,
                state: ListingState,
                role: ListingRole?,
                coveredArea: Int?,
                parkingForVisits: Bool?,
                totalFloorsCount: Int?,
                floorNumber: Int?,
                user: User,
                location: Location?,
                images: [ListingImage]?,
                facilities: [Facility]?,
                advancedDetails: [Facility]?,
                contact: Contact? = nil,
                url: Url? = nil
        ) {
        self.area = area
        self.bathroomsCount = bathroomsCount
        self.bedroomsCount = bedroomsCount
        self.contactViewsCount = contactViewsCount
        self.favouritesCount = favouritesCount
        self.favourited = favourited
        self.id = id
        self.listingDescription = listingDescription
        self.listingType = listingType
        self.parkingSlotsCount = parkingSlotsCount
        self.petFriendly = petFriendly
        self.primaryImageId = primaryImageId
        self.propertyType = propertyType
        self.status = status
        self.viewsCount = viewsCount
        self.yearOfConstruction = yearOfConstruction
        self.createdAt = createdAt
        self.adPurchasedAt = adPurchasedAt
        self.adExpiresAt = adExpiresAt
        self.adPlan = adPlan
        self.state = state
        self.role = role
        self.coveredArea = coveredArea
        self.parkingForVisits = parkingForVisits
        self.totalFloorsCount = totalFloorsCount
        self.floorNumber = floorNumber
        self.user = user
        self.location = location
        self.images = images
        self.facilities = facilities
        self.advancedDetails = advancedDetails
        self.price = price
        self.contact = contact
        self.url = url
    }
    
    enum CodingKeys: String, CodingKey {
        case area
        case bathroomsCount
        case bedroomsCount
        case contactViewsCount = "contactsCount"
        case favouritesCount
        case favourited
        case id
        case listingDescription = "description"
        case listingType
        case parkingSlotsCount
        case petFriendly
        case price
        case primaryImageId
        case propertyType
        case status
        case viewsCount
        case yearOfConstruction
        case user
        case contact
        case location
        case images
        case facilities
        case createdAt
        case adPurchasedAt
        case adExpiresAt
        case adPlan
        case state
        case role = "publisherRole"
        case coveredArea = "builtArea"
        case parkingForVisits
        case totalFloorsCount
        case floorNumber
        case advancedDetails
        case url
    }
    
}

public extension Listing {
    
    var primaryImage: ListingImage? {
        images?.first(where: { $0.id == primaryImageId }) ?? images?.first
    }
    
    var isPurchased: Bool {
        state == .published || state == .unpublished
    }
    
}
