// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable superfluous_disable_command implicit_return
// swiftlint:disable sorted_imports
import CoreData
import Foundation

// swiftlint:disable attributes file_length vertical_whitespace_closing_braces
// swiftlint:disable identifier_name line_length type_body_length

// MARK: - AppConfig

internal class ManagedAppConfig: NSManagedObject {
  internal class var entityName: String {
    return "AppConfig"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<ManagedAppConfig> {
    return NSFetchRequest<ManagedAppConfig>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<ManagedAppConfig> {
    return NSFetchRequest<ManagedAppConfig>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var id: Int16
  @NSManaged internal var privacyURLString: String
  @NSManaged internal var termsURLString: String
  @NSManaged internal var location: ManagedLocation?
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// MARK: - Currency

internal class ManagedCurrency: NSManagedObject {
  internal class var entityName: String {
    return "Currency"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<ManagedCurrency> {
    return NSFetchRequest<ManagedCurrency>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<ManagedCurrency> {
    return NSFetchRequest<ManagedCurrency>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var code: String
  @NSManaged internal var rate: Double
  @NSManaged internal var symbol: String
  @NSManaged internal var title: String
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// MARK: - Facility

internal class ManagedFacility: NSManagedObject {
  internal class var entityName: String {
    return "Facility"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<ManagedFacility> {
    return NSFetchRequest<ManagedFacility>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<ManagedFacility> {
    return NSFetchRequest<ManagedFacility>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var id: Int32
  @NSManaged internal var key: String
  @NSManaged internal var propertyTypes: String?
  @NSManaged internal var title: String
  @NSManaged internal var details: Set<ManagedListing>?
  @NSManaged internal var icon: ManagedRemoteImage?
  @NSManaged internal var listings: Set<ManagedListing>?
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// MARK: Relationship Details

extension ManagedFacility {
  @objc(addDetailsObject:)
  @NSManaged public func addToDetails(_ value: ManagedListing)

  @objc(removeDetailsObject:)
  @NSManaged public func removeFromDetails(_ value: ManagedListing)

  @objc(addDetails:)
  @NSManaged public func addToDetails(_ values: Set<ManagedListing>)

  @objc(removeDetails:)
  @NSManaged public func removeFromDetails(_ values: Set<ManagedListing>)
}

// MARK: Relationship Listings

extension ManagedFacility {
  @objc(addListingsObject:)
  @NSManaged public func addToListings(_ value: ManagedListing)

  @objc(removeListingsObject:)
  @NSManaged public func removeFromListings(_ value: ManagedListing)

  @objc(addListings:)
  @NSManaged public func addToListings(_ values: Set<ManagedListing>)

  @objc(removeListings:)
  @NSManaged public func removeFromListings(_ values: Set<ManagedListing>)
}

// MARK: - Listing

internal class ManagedListing: NSManagedObject {
  internal class var entityName: String {
    return "Listing"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<ManagedListing> {
    return NSFetchRequest<ManagedListing>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<ManagedListing> {
    return NSFetchRequest<ManagedListing>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var adExpiresAt: Date?
  @NSManaged internal var adPlan: String?
  @NSManaged internal var adPurchasedAt: Date?
  internal var area: Int64? {
    get {
      let key = "area"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      return primitiveValue(forKey: key) as? Int64
    }
    set {
      let key = "area"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue, forKey: key)
    }
  }
  internal var bathroomsCount: Int16? {
    get {
      let key = "bathroomsCount"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      return primitiveValue(forKey: key) as? Int16
    }
    set {
      let key = "bathroomsCount"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue, forKey: key)
    }
  }
  internal var bedroomsCount: Int16? {
    get {
      let key = "bedroomsCount"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      return primitiveValue(forKey: key) as? Int16
    }
    set {
      let key = "bedroomsCount"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue, forKey: key)
    }
  }
  @NSManaged internal var contactViewsCount: Int64
  internal var coveredArea: Int64? {
    get {
      let key = "coveredArea"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      return primitiveValue(forKey: key) as? Int64
    }
    set {
      let key = "coveredArea"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue, forKey: key)
    }
  }
  @NSManaged internal var createdAt: Date
  @NSManaged internal var favourited: Bool
  @NSManaged internal var favouritesCount: Int64
  internal var floorNumber: Int16? {
    get {
      let key = "floorNumber"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      return primitiveValue(forKey: key) as? Int16
    }
    set {
      let key = "floorNumber"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue, forKey: key)
    }
  }
  @NSManaged internal var id: Int64
  @NSManaged internal var listingDescription: String
  @NSManaged internal var listingType: String?
  internal var parkingForVisits: Bool? {
    get {
      let key = "parkingForVisits"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      return primitiveValue(forKey: key) as? Bool
    }
    set {
      let key = "parkingForVisits"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue, forKey: key)
    }
  }
  internal var parkingSlotsCount: Int16? {
    get {
      let key = "parkingSlotsCount"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      return primitiveValue(forKey: key) as? Int16
    }
    set {
      let key = "parkingSlotsCount"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue, forKey: key)
    }
  }
  internal var petFriendly: Bool? {
    get {
      let key = "petFriendly"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      return primitiveValue(forKey: key) as? Bool
    }
    set {
      let key = "petFriendly"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue, forKey: key)
    }
  }
  internal var price: Int64? {
    get {
      let key = "price"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      return primitiveValue(forKey: key) as? Int64
    }
    set {
      let key = "price"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue, forKey: key)
    }
  }
  internal var primaryImageId: Int64? {
    get {
      let key = "primaryImageId"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      return primitiveValue(forKey: key) as? Int64
    }
    set {
      let key = "primaryImageId"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue, forKey: key)
    }
  }
  @NSManaged internal var propertyType: String?
  @NSManaged internal var state: String
  @NSManaged internal var status: String
  internal var totalFloorsCount: Int16? {
    get {
      let key = "totalFloorsCount"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      return primitiveValue(forKey: key) as? Int16
    }
    set {
      let key = "totalFloorsCount"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue, forKey: key)
    }
  }
  @NSManaged internal var updatedAt: String?
  @NSManaged internal var viewsCount: Int64
  internal var yearOfConstruction: Int16? {
    get {
      let key = "yearOfConstruction"
      willAccessValue(forKey: key)
      defer { didAccessValue(forKey: key) }

      return primitiveValue(forKey: key) as? Int16
    }
    set {
      let key = "yearOfConstruction"
      willChangeValue(forKey: key)
      defer { didChangeValue(forKey: key) }

      setPrimitiveValue(newValue, forKey: key)
    }
  }
  @NSManaged internal var advancedDetails: Set<ManagedFacility>?
  @NSManaged internal var facilities: Set<ManagedFacility>?
  @NSManaged internal var images: Set<ManagedListingImage>?
  @NSManaged internal var location: ManagedLocation?
  @NSManaged internal var user: ManagedUser
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// MARK: Relationship AdvancedDetails

extension ManagedListing {
  @objc(addAdvancedDetailsObject:)
  @NSManaged public func addToAdvancedDetails(_ value: ManagedFacility)

  @objc(removeAdvancedDetailsObject:)
  @NSManaged public func removeFromAdvancedDetails(_ value: ManagedFacility)

  @objc(addAdvancedDetails:)
  @NSManaged public func addToAdvancedDetails(_ values: Set<ManagedFacility>)

  @objc(removeAdvancedDetails:)
  @NSManaged public func removeFromAdvancedDetails(_ values: Set<ManagedFacility>)
}

// MARK: Relationship Facilities

extension ManagedListing {
  @objc(addFacilitiesObject:)
  @NSManaged public func addToFacilities(_ value: ManagedFacility)

  @objc(removeFacilitiesObject:)
  @NSManaged public func removeFromFacilities(_ value: ManagedFacility)

  @objc(addFacilities:)
  @NSManaged public func addToFacilities(_ values: Set<ManagedFacility>)

  @objc(removeFacilities:)
  @NSManaged public func removeFromFacilities(_ values: Set<ManagedFacility>)
}

// MARK: Relationship Images

extension ManagedListing {
  @objc(addImagesObject:)
  @NSManaged public func addToImages(_ value: ManagedListingImage)

  @objc(removeImagesObject:)
  @NSManaged public func removeFromImages(_ value: ManagedListingImage)

  @objc(addImages:)
  @NSManaged public func addToImages(_ values: Set<ManagedListingImage>)

  @objc(removeImages:)
  @NSManaged public func removeFromImages(_ values: Set<ManagedListingImage>)
}

// MARK: - ListingImage

internal class ManagedListingImage: NSManagedObject {
  internal class var entityName: String {
    return "ListingImage"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<ManagedListingImage> {
    return NSFetchRequest<ManagedListingImage>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<ManagedListingImage> {
    return NSFetchRequest<ManagedListingImage>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var created_at: String
  @NSManaged internal var id: Int64
  @NSManaged internal var listing: ManagedListing?
  @NSManaged internal var photo: ManagedRemoteImage
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// MARK: - Location

internal class ManagedLocation: NSManagedObject {
  internal class var entityName: String {
    return "Location"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<ManagedLocation> {
    return NSFetchRequest<ManagedLocation>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<ManagedLocation> {
    return NSFetchRequest<ManagedLocation>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var address: String?
  @NSManaged internal var id: String
  @NSManaged internal var latitude: Float
  @NSManaged internal var longitude: Float
  @NSManaged internal var config: ManagedAppConfig?
  @NSManaged internal var listing: ManagedListing?
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// MARK: - RemoteImage

internal class ManagedRemoteImage: NSManagedObject {
  internal class var entityName: String {
    return "RemoteImage"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<ManagedRemoteImage> {
    return NSFetchRequest<ManagedRemoteImage>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<ManagedRemoteImage> {
    return NSFetchRequest<ManagedRemoteImage>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var largeURLString: String?
  @NSManaged internal var mediumURLString: String?
  @NSManaged internal var originalURLString: String
  @NSManaged internal var smallURLString: String?
  @NSManaged internal var facility: ManagedFacility?
  @NSManaged internal var listingImage: ManagedListingImage?
  @NSManaged internal var user: ManagedUser?
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// MARK: - User

internal class ManagedUser: NSManagedObject {
  internal class var entityName: String {
    return "User"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<ManagedUser> {
    return NSFetchRequest<ManagedUser>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<ManagedUser> {
    return NSFetchRequest<ManagedUser>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var email: String?
  @NSManaged internal var firstName: String?
  @NSManaged internal var id: Int64
  @NSManaged internal var lastName: String?
  @NSManaged internal var phoneNumber: String
  @NSManaged internal var avatar: ManagedRemoteImage?
  @NSManaged internal var listings: Set<ManagedListing>?
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// MARK: Relationship Listings

extension ManagedUser {
  @objc(addListingsObject:)
  @NSManaged public func addToListings(_ value: ManagedListing)

  @objc(removeListingsObject:)
  @NSManaged public func removeFromListings(_ value: ManagedListing)

  @objc(addListings:)
  @NSManaged public func addToListings(_ values: Set<ManagedListing>)

  @objc(removeListings:)
  @NSManaged public func removeFromListings(_ values: Set<ManagedListing>)
}

// swiftlint:enable identifier_name line_length type_body_length
