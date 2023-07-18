//
//  Facility+CoreData.swift
//  Babilonia
//
//  Created by Denis on 6/14/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import DBClient
import CoreData

private let propertyTypeSeparator = ","

extension Facility: CoreDataModelConvertible {
    
    public static var primaryKeyName: String? { return #keyPath(ManagedFacility.id) }
    
    public var valueOfPrimaryKey: CVarArg? { return id }
    
    public static func managedObjectClass() -> NSManagedObject.Type { return ManagedFacility.self }
    
    public static var entityName: String { return String(describing: self) }
    
    public func isPrimaryValueEqualTo(value: Any) -> Bool {
        if let value = value as? Int {
            return id == value
        }
        
        return false
    }
    
    public static func from(_ managedObject: NSManagedObject) -> Stored {
        guard let object = managedObject as? ManagedFacility else {
            fatalError("can't cast given `NSManagedObject`: \(managedObject) to `\(Facility.self)`")
        }
        
        return instantiate(object)
    }
    
    public func upsertManagedObject(
        in context: NSManagedObjectContext,
        existedInstance: NSManagedObject?
    ) -> NSManagedObject {
        let object: ManagedFacility = upsertingManagedObject(of: Facility.self, in: context, with: existedInstance)
        
        map(object)
        
        return object
    }
    
    // MARK: - Private methods
    
    private func map(_ object: ManagedFacility) {
        object.id = Int32(id)
        object.key = key
        object.title = title

        guard let context = object.managedObjectContext else { return }

        object.icon = icon?.upsertManagedObject(in: context, existedInstance: object.icon) as? ManagedRemoteImage
        object.propertyTypes = propertyTypes?.map { $0.rawValue }.joined(separator: propertyTypeSeparator)
    }
    
    private static func instantiate(_ object: ManagedFacility) -> Facility {
        return Facility(
            id: Int(object.id),
            key: object.key,
            title: object.title,
            icon: object.icon.flatMap(RemoteImage.instantiate),
            propertyTypes: object.propertyTypes?
                .components(separatedBy: propertyTypeSeparator)
                .compactMap { PropertyType(rawValue: $0) }
        )
    }
}
