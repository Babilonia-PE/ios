//
//  Listing+CoreData.swift
//  Babilonia
//
//  Created by Denis on 6/24/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import DBClient
import CoreData

extension Listing: CoreDataModelConvertible {
    
    public static var primaryKeyName: String? { return #keyPath(ManagedListing.id) }
    
    public var valueOfPrimaryKey: CVarArg? { return id }
    
    public static func managedObjectClass() -> NSManagedObject.Type { return ManagedListing.self }
    
    public static var entityName: String { return String(describing: self) }
    
    public func isPrimaryValueEqualTo(value: Any) -> Bool {
        if let value = value as? ListingId {
            return id == value
        }
        
        return false
    }
    
    public static func from(_ managedObject: NSManagedObject) -> Stored {
        guard let object = managedObject as? ManagedListing else {
            fatalError("can't cast given `NSManagedObject`: \(managedObject) to `\(Listing.self)`")
        }
        
        return instantiate(object)
    }
    
    public func upsertManagedObject(
        in context: NSManagedObjectContext,
        existedInstance: NSManagedObject?
    ) -> NSManagedObject {
        let object: ManagedListing = upsertingManagedObject(of: Listing.self, in: context, with: existedInstance)
        
        map(object)
        
        return object
    }
    
    // MARK: - Private methods
    
    private func map(_ object: ManagedListing) {
        object.area = area.flatMap(Int64.init)
        object.bathroomsCount = bathroomsCount.flatMap(Int16.init)
        object.bedroomsCount = bedroomsCount.flatMap(Int16.init)
        object.contactViewsCount = Int64(contactViewsCount ?? 0)
        object.favouritesCount = Int64(favouritesCount)
        object.favourited = favourited ?? false
        object.id = Int64(id)
        object.listingDescription = listingDescription ?? ""
        object.listingType = listingType?.rawValue
        object.parkingSlotsCount = parkingSlotsCount.flatMap(Int16.init)
        object.petFriendly = petFriendly
        object.price = price.flatMap(Int64.init)
        object.primaryImageId = primaryImageId.flatMap(Int64.init)
        object.propertyType = propertyType?.rawValue
        object.status = status.rawValue
        object.state = state.rawValue
        object.coveredArea = coveredArea.flatMap(Int64.init)
        object.parkingForVisits = parkingForVisits
        object.totalFloorsCount = totalFloorsCount.flatMap(Int16.init)
        object.floorNumber = floorNumber.flatMap(Int16.init)
        object.viewsCount = Int64(viewsCount)
        object.yearOfConstruction = yearOfConstruction.flatMap(Int16.init)
        
        guard let context = object.managedObjectContext else { return }
        
        let managedUser = user.upsertManagedObject(in: context, existedInstance: object.user)
        guard let user = managedUser as? ManagedUser else {
            fatalError("Cannot cast \(managedUser) to \(managedUser.self)")
        }
        object.createdAt = createdAt
        object.adPurchasedAt = adPurchasedAt
        object.adPlan = adPlan?.rawValue
        object.role = role?.rawValue
        object.adExpiresAt = adExpiresAt
        object.user = user
        
        object.location = location?.upsertManagedObject(
            in: context,
            existedInstance: object.isInserted ? nil : object.location
        ) as? ManagedLocation
        
        object.images?.forEach { context.delete($0) }
        object.images = (images?.compactMap {
            return $0.upsertManagedObject(in: context, existedInstance: nil) as? ManagedListingImage
        }).flatMap(Set.init)

        object.facilities = (facilities.flatMap { upsertFacilities($0, in: context) }).flatMap(Set.init)
        object.advancedDetails = (advancedDetails.flatMap { upsertFacilities($0, in: context) }).flatMap(Set.init)
        
        object.contact = contacts?.first?.upsertManagedObject(in: context, existedInstance: object.contact) as? ManagedContact
//        guard let contact = managedContact as? ManagedContact else {
//            fatalError("Cannot cast \(String(describing: managedContact)) to \(String(describing: managedContact.self))")
//        }
//        object.contact = contact
    }

    private func upsertFacilities(_ facilities: [Facility],
                                  in context: NSManagedObjectContext) -> [ManagedFacility] {
        return facilities.map { (facility: Facility) -> ManagedFacility in
            let fetchRequest: NSFetchRequest<ManagedFacility> = ManagedFacility.makeFetchRequest()
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(ManagedFacility.id)) == %d", facility.id)
            let result = try? context.fetch(fetchRequest)

            guard let upsertedFacility = facility.upsertManagedObject(
                in: context,
                existedInstance: result?.first
            ) as? ManagedFacility else {
                fatalError("Inserted object type is not `\(ManagedFacility.self)`")
            }

            return upsertedFacility
        }
    }

    private static func instantiate(_ object: ManagedListing) -> Listing {
        guard let user = User.from(object.user) as? User else { fatalError() }
        let contact: Contact? = (object.contact != nil) ? Contact.from(object.contact!) as? Contact : nil
        var contacts: [Contact] = []
        if let contact = contact {
            contacts = [contact]
        }
        let location = object.location.flatMap(Location.from) as? Location
        let images = object.images?.map { (image: ManagedListingImage) -> ListingImage in
            guard let result = ListingImage.from(image) as? ListingImage else { fatalError() }
            return result
        }
        let facilities = object.facilities?.map { (facility: ManagedFacility) -> Facility in
            guard let result = Facility.from(facility) as? Facility else { fatalError() }
            return result
        }
        let advancedDetails = object.advancedDetails?.map { (facility: ManagedFacility) -> Facility in
            guard let result = Facility.from(facility) as? Facility else { fatalError() }
            return result
        }
        
        guard let status = ListingStatus(rawValue: object.status) else { fatalError() }
        let state = ListingState(rawValue: object.state) ?? .notPublished

        return Listing(
            area: object.area.flatMap(Int.init),
            bathroomsCount: object.bathroomsCount.flatMap(Int.init),
            bedroomsCount: object.bedroomsCount.flatMap(Int.init),
            contactViewsCount: Int(object.contactViewsCount),
            favouritesCount: Int(object.favouritesCount),
            favourited: object.favourited,
            id: ListingId(object.id),
            listingDescription: object.listingDescription,
            listingType: object.listingType.flatMap(ListingType.init),
            parkingSlotsCount: object.parkingSlotsCount.flatMap(Int.init),
            petFriendly: object.petFriendly,
            price: object.price.flatMap(Int.init),
            primaryImageId: object.primaryImageId.flatMap(Int.init),
            propertyType: object.propertyType.flatMap(PropertyType.init),
            status: status,
            viewsCount: Int(object.viewsCount),
            yearOfConstruction: object.yearOfConstruction.flatMap(Int.init),
            createdAt: object.createdAt,
            adPurchasedAt: object.adPurchasedAt,
            adExpiresAt: object.adExpiresAt,
            adPlan: object.adPlan.flatMap(PlanType.init),
            state: state,
            role: object.role.flatMap(ListingRole.init),
            coveredArea: object.coveredArea.flatMap(Int.init),
            parkingForVisits: object.parkingForVisits,
            totalFloorsCount: object.totalFloorsCount.flatMap(Int.init),
            floorNumber: object.floorNumber.flatMap(Int.init),
            user: user,
            location: location,
            images: images,
            facilities: facilities,
            advancedDetails: advancedDetails,
            contacts: contacts
        )
    }
}
