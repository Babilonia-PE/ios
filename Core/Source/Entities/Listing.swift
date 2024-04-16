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
    public var ids: [ListingId]?
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

    public var user: User?
    public var contacts: [Contact]?
    public var location: Location?
    public var images: [ListingImage]?
    public var facilities: [Facility]?
    public var advancedDetails: [Facility]?
    public var url: UrlListing?
    
    public var reason: String?
    public var priceFinal: Int?
    
    //public var userId: Int? = nil
    
    public var isEdit: Bool = false

    //55547 TODO: - Remove it.

    public init(area: Int?,
                bathroomsCount: Int?,
                bedroomsCount: Int?,
                contactViewsCount: Int?,
                favouritesCount: Int,
                favourited: Bool = false,
                id: ListingId,
                ids: [ListingId]?,
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
                user: User?,
                location: Location?,
                images: [ListingImage]?,
                facilities: [Facility]?,
                advancedDetails: [Facility]?,
                contacts: [Contact]?,                
                url: UrlListing? = nil
        ) {
        self.area = area
        self.bathroomsCount = bathroomsCount
        self.bedroomsCount = bedroomsCount
        self.contactViewsCount = contactViewsCount
        self.favouritesCount = favouritesCount
        self.favourited = favourited
        self.id = id
        self.ids = ids
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
        self.contacts = contacts
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
        case ids
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
        case user = "user"
        case contacts
        case location
        case images
        case facilities
        case createdAt
        case adPurchasedAt
        case adExpiresAt
        case adPlan = "ad_plan"
        case state
        case role = "publisherRole"
        case coveredArea = "builtArea"
        case parkingForVisits
        case totalFloorsCount
        case floorNumber
        case advancedDetails
        case url
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.area = try container.decodeIfPresent(Int.self, forKey: .area)
        self.bathroomsCount = try container.decodeIfPresent(Int.self, forKey: .bathroomsCount)
        self.bedroomsCount = try container.decodeIfPresent(Int.self, forKey: .bedroomsCount)
        self.contactViewsCount = try container.decodeIfPresent(Int.self, forKey: .contactViewsCount)
        self.favouritesCount = try container.decode(Int.self, forKey: .favouritesCount)
        self.favourited = try container.decodeIfPresent(Bool.self, forKey: .favourited)
        self.id = try container.decode(ListingId.self, forKey: .id)
        self.ids = try container.decodeIfPresent([ListingId].self, forKey: .ids)
        self.listingDescription = try container.decodeIfPresent(String.self, forKey: .listingDescription)
        if let listingTypeString = try container.decodeIfPresent(String.self, forKey: .listingType) {
            self.listingType = ListingType(rawValue: listingTypeString)
        }
        self.parkingSlotsCount = try container.decodeIfPresent(Int.self, forKey: .parkingSlotsCount)
        self.petFriendly = try container.decodeIfPresent(Bool.self, forKey: .petFriendly)
        self.price = try container.decodeIfPresent(Int.self, forKey: .price)
        self.primaryImageId = try container.decodeIfPresent(Int.self, forKey: .primaryImageId)
        if let propertyTypeString = try container.decodeIfPresent(String.self, forKey: .propertyType) {
            self.propertyType = PropertyType(rawValue: propertyTypeString)
        }
        self.status = try container.decode(ListingStatus.self, forKey: .status)
        self.viewsCount = try container.decode(Int.self, forKey: .viewsCount)
        self.yearOfConstruction = try container.decodeIfPresent(Int.self, forKey: .yearOfConstruction)
        self.user = try container.decodeIfPresent(User.self, forKey: .user)
        self.contacts = try container.decodeIfPresent([Contact].self, forKey: .contacts)
        self.location = try container.decodeIfPresent(Location.self, forKey: .location)
        self.images = try container.decodeIfPresent([ListingImage].self, forKey: .images)
        self.facilities = try container.decodeIfPresent([Facility].self, forKey: .facilities)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.adPurchasedAt = try container.decodeIfPresent(Date.self, forKey: .adPurchasedAt)
        self.adExpiresAt = try container.decodeIfPresent(Date.self, forKey: .adExpiresAt)
        self.adPlan = try container.decodeIfPresent(PlanType.self, forKey: .adPlan)
        self.state = try container.decode(ListingState.self, forKey: .state)
        self.role = try container.decodeIfPresent(ListingRole.self, forKey: .role)
        self.coveredArea = try container.decodeIfPresent(Int.self, forKey: .coveredArea)
        self.parkingForVisits = try container.decodeIfPresent(Bool.self, forKey: .parkingForVisits)
        self.totalFloorsCount = try container.decodeIfPresent(Int.self, forKey: .totalFloorsCount)
        self.floorNumber = try container.decodeIfPresent(Int.self, forKey: .floorNumber)
        self.advancedDetails = try container.decodeIfPresent([Facility].self, forKey: .advancedDetails)
        self.url = try container.decodeIfPresent(UrlListing.self, forKey: .url)
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
