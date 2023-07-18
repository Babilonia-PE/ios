//
//  AppConfig+CoreData.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/16/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import DBClient
import CoreData

extension AppConfig: CoreDataModelConvertible {
    
    public static var primaryKeyName: String? { return #keyPath(ManagedAppConfig.id) }
    
    public var valueOfPrimaryKey: CVarArg? { return id }
    
    public static func managedObjectClass() -> NSManagedObject.Type { return ManagedAppConfig.self }
    
    public static var entityName: String { return String(describing: self) }
    
    public func isPrimaryValueEqualTo(value: Any) -> Bool {
        if let value = value as? Int {
            return id == value
        }
        
        return false
    }
    
    public static func from(_ managedObject: NSManagedObject) -> Stored {
        guard let object = managedObject as? ManagedAppConfig else {
            fatalError("can't cast given `NSManagedObject`: \(managedObject) to `\(AppConfig.self)`")
        }
        
        return instantiate(object)
    }
    
    public func upsertManagedObject(
        in context: NSManagedObjectContext,
        existedInstance: NSManagedObject?
    ) -> NSManagedObject {
        let object: ManagedAppConfig = upsertingManagedObject(of: AppConfig.self, in: context, with: existedInstance)
        
        map(object)
        
        return object
    }
    
    // MARK: - Private methods
    
    private func map(_ object: ManagedAppConfig) {
        object.id = Int16(id)
        object.termsURLString = termsURLString
        object.privacyURLString = privacyURLString
        
        guard let context = object.managedObjectContext else { return }

        object.location = location?.upsertManagedObject(
            in: context,
            existedInstance: object.isInserted ? nil : object.location
        ) as? ManagedLocation
    }
    
    private static func instantiate(_ object: ManagedAppConfig) -> AppConfig {
        let location = object.location.flatMap(Location.from) as? Location
        
        return AppConfig(
            termsURLString: object.termsURLString,
            privacyURLString: object.privacyURLString,
            location: location
        )
    }
}
