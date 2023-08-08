//
//  Location+CoreData.swift
//  Babilonia
//
//  Created by Denis on 6/24/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import DBClient
import CoreData

extension Location: CoreDataModelConvertible {
    
    public static var primaryKeyName: String? { return #keyPath(ManagedLocation.id) }
    
    public var valueOfPrimaryKey: CVarArg? { return id }
    
    public static func managedObjectClass() -> NSManagedObject.Type { return ManagedLocation.self }
    
    public static var entityName: String { return String(describing: self) }
    
    public func isPrimaryValueEqualTo(value: Any) -> Bool {
        if let value = value as? String {
            return id == value
        }
        
        return false
    }
    
    public static func from(_ managedObject: NSManagedObject) -> Stored {
        guard let object = managedObject as? ManagedLocation else {
            fatalError("can't cast given `NSManagedObject`: \(managedObject) to `\(Location.self)`")
        }
        print("object location = \(object)")
        return instantiate(object)
    }
    
    public func upsertManagedObject(
        in context: NSManagedObjectContext,
        existedInstance: NSManagedObject?
    ) -> NSManagedObject {
        let object: ManagedLocation = upsertingManagedObject(of: Location.self, in: context, with: existedInstance)
        map(object)
        print("object map = \(object)")
        return object
    }
    
    // MARK: - Private methods
    
    private func map(_ object: ManagedLocation) {
        object.id = id
        object.address = address
        object.latitude = latitude
        object.longitude = longitude
        object.country = country
        object.department = department
        object.province = province
        object.district = district
        object.zipCode = zipCode
    }
    
    private static func instantiate(_ object: ManagedLocation) -> Location {
        return Location(
            id: object.id,
            address: object.address,
            latitude: object.latitude,
            longitude: object.longitude,
            country: object.country,
            department: object.department,
            province: object.province,
            district: object.district,
            zipCode: object.zipCode
        )
    }
}
