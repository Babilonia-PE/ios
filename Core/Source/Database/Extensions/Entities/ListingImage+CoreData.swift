//
//  ListingImage+CoreData.swift
//  Babilonia
//
//  Created by Denis on 6/24/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import DBClient
import CoreData

extension ListingImage: CoreDataModelConvertible {
    
    public static var primaryKeyName: String? { return #keyPath(ManagedListingImage.id) }
    
    public var valueOfPrimaryKey: CVarArg? { return id }
    
    public static func managedObjectClass() -> NSManagedObject.Type { return ManagedListingImage.self }
    
    public static var entityName: String { return String(describing: self) }
    
    public func isPrimaryValueEqualTo(value: Any) -> Bool {
        if let value = value as? Int {
            return id == value
        }
        
        return false
    }
    
    public static func from(_ managedObject: NSManagedObject) -> Stored {
        guard let object = managedObject as? ManagedListingImage else {
            fatalError("can't cast given `NSManagedObject`: \(managedObject) to `\(ListingImage.self)`")
        }
        
        return instantiate(object)
    }
    
    public func upsertManagedObject(
        in context: NSManagedObjectContext,
        existedInstance: NSManagedObject?
    ) -> NSManagedObject {
        let object: ManagedListingImage = upsertingManagedObject(
            of: ListingImage.self, in: context, with: existedInstance
        )
        
        map(object)
        
        return object
    }
    
    // MARK: - Private methods
    
    private func map(_ object: ManagedListingImage) {
        object.id = Int64(id)
        
        guard let context = object.managedObjectContext else { return }
        let managedPhoto = photo
            .upsertManagedObject(in: context, existedInstance: object.isInserted ? nil : object.photo)
        guard let photo = managedPhoto as? ManagedRemoteImage else {
            fatalError("Cannot cast \(managedPhoto) to \(ManagedRemoteImage.self)")
        }
        object.photo = photo
        object.created_at = createdAt
    }
    
    private static func instantiate(_ object: ManagedListingImage) -> ListingImage {
        return ListingImage(
            id: Int(object.id),
            photo: RemoteImage.instantiate(object.photo),
            createdAt: object.created_at
        )
    }
}
