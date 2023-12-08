//
//  UrlListing+CoreDataProperties.swift
//  Core
//
//  Created by Rafael Miranda Salas on 7/12/23.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import CoreData
import DBClient

extension UrlListing: CoreDataModelConvertible {
    
    public static func managedObjectClass() -> NSManagedObject.Type {
        return ManagedListingUrl.self
    }
    
    public static func from(_ managedObject: NSManagedObject) -> Stored {
        guard let object = managedObject as? ManagedListingUrl else {
            fatalError("can't cast given `NSManagedObject`: \(managedObject) to `\(UrlListing.self)`")
        }
        
        return instantiate(object)
    }
    
    public func upsertManagedObject(in context: NSManagedObjectContext, existedInstance: NSManagedObject?) -> NSManagedObject {
        let object: ManagedListingUrl = upsertingManagedObject(of: UrlListing.self, in: context, with: existedInstance)
        
        map(object)
        
        return object
    }
    
    public static var entityName: String {
        return String(describing: self)
    }
    
    public func isPrimaryValueEqualTo(value: Any) -> Bool {
        if let value = value as? String {
            return share == value
        }
        
        return false
    }
    
    public static var primaryKeyName: String? {
        return #keyPath(ManagedListingUrl.share)
    }
    
    public var valueOfPrimaryKey: CVarArg? {
        return share
    }
    
    // MARK: - Private methods
    
    private func map(_ object: ManagedListingUrl) {
        object.main = main
        object.share = share
    }
    
    private static func instantiate(_ object: ManagedListingUrl) -> UrlListing {
        return UrlListing(main: object.main ?? "", share: object.share ?? "")
    }
    
}
//extension UrlListing {
//
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<UrlListing> {
//        return NSFetchRequest<UrlListing>(entityName: "UrlListing")
//    }
//
//    @NSManaged public var share: String?
//    @NSManaged public var main: String?
//    @NSManaged public var listings: NSSet?
//
//}
//
//// MARK: Generated accessors for listings
//extension UrlListing {
//
//    @objc(addListingsObject:)
//    @NSManaged public func addToListings(_ value: ManagedListing)
//
//    @objc(removeListingsObject:)
//    @NSManaged public func removeFromListings(_ value: ManagedListing)
//
//    @objc(addListings:)
//    @NSManaged public func addToListings(_ values: NSSet)
//
//    @objc(removeListings:)
//    @NSManaged public func removeFromListings(_ values: NSSet)
//
//}
