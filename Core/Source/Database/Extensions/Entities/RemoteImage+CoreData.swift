//
//  RemoteImage+CoreData.swift
//  Babilonia
//
//  Created by Denis on 5/31/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import DBClient
import CoreData

extension RemoteImage: CoreDataModelConvertible {
    
    public static var primaryKeyName: String? { return #keyPath(ManagedRemoteImage.originalURLString) }
    
    public var valueOfPrimaryKey: CVarArg? { return originalURLString }
    
    public static func managedObjectClass() -> NSManagedObject.Type { return ManagedRemoteImage.self }
    
    public static var entityName: String { return String(describing: self) }
    
    public func isPrimaryValueEqualTo(value: Any) -> Bool {
        if let value = value as? String {
            return originalURLString == value
        }
        
        return false
    }
    
    public static func from(_ managedObject: NSManagedObject) -> Stored {
        guard let object = managedObject as? ManagedRemoteImage else {
            fatalError("can't cast given `NSManagedObject`: \(managedObject) to `\(RemoteImage.self)`")
        }
        
        return instantiate(object)
    }
    
    public func upsertManagedObject(
        in context: NSManagedObjectContext,
        existedInstance: NSManagedObject?
    ) -> NSManagedObject {
        let object: ManagedRemoteImage = upsertingManagedObject(
            of: RemoteImage.self,
            in: context,
            with: existedInstance
        )
        
        map(object)
        
        return object
    }
    
    // MARK: - Private methods
    
    private func map(_ object: ManagedRemoteImage) {
        object.originalURLString = originalURLString
        object.smallURLString = smallURLString
        object.mediumURLString = mediumURLString
        object.largeURLString = largeURLString
    }
    
    static func instantiate(_ object: ManagedRemoteImage) -> RemoteImage {
        return RemoteImage(
            originalURLString: object.originalURLString,
            smallURLString: object.smallURLString,
            mediumURLString: object.mediumURLString,
            largeURLString: object.largeURLString
        )
    }
}
