//
//  Contact+CoreDate.swift
//  Core
//
//  Created by Owson on 24/05/22.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import DBClient
import CoreData

extension Contact: CoreDataModelConvertible {
    
    public static var primaryKeyName: String? { return #keyPath(ManagedContact.contactName) }
    
    public var valueOfPrimaryKey: CVarArg? { return contactName }
    
    public static func managedObjectClass() -> NSManagedObject.Type { return ManagedContact.self }
    
    public static var entityName: String { return String(describing: self) }
    
    public func isPrimaryValueEqualTo(value: Any) -> Bool {
        if let value = value as? String {
            return contactName == value
        }

        return false
    }
    
    public static func from(_ managedObject: NSManagedObject) -> Stored {
        guard let object = managedObject as? ManagedContact else {
            fatalError("can't cast given `NSManagedObject`: \(managedObject) to `\(Contact.self)`")
        }
        
        return instantiate(object)
    }
    
    public func upsertManagedObject(
        in context: NSManagedObjectContext,
        existedInstance: NSManagedObject?
    ) -> NSManagedObject {
        let object: ManagedContact = upsertingManagedObject(
            of: Contact.self,
            in: context,
            with: existedInstance
        )
        
        map(object)
        
        return object
    }
    
    // MARK: - Private methods
    
    private func map(_ object: ManagedContact) {
        object.contactName = contactName
        object.contactEmail = contactEmail
        object.contactPhone = contactPhone
    }
    
    private static func instantiate(_ object: ManagedContact) -> Contact {
        return Contact(
            contactEmail: object.contactEmail,
            contactName: object.contactName,
            contactPhone: object.contactPhone
        )
    }
}
