//
//  CoreDataConvertibleHelper.swift
//  Core
//
//  Created by Denis on 5/28/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import CoreData
import DBClient

extension CoreDataModelConvertible {
    
    func upsertingManagedObject<T: NSManagedObject, V: CoreDataModelConvertible>(
        of type: V.Type,
        in context: NSManagedObjectContext,
        with existedInstance: NSManagedObject?
    ) -> T {
        let object: T
        if let existedInstance = existedInstance {
            if let existedInstance = existedInstance as? T {
                object = existedInstance
            } else {
                fatalError("Can't cast given `NSManagedObject`: \(existedInstance) to `\(V.self)`")
            }
        } else {
            let managedObject = NSEntityDescription.insertNewObject(forEntityName: V.entityName, into: context)
            if let managedObject = managedObject as? T {
                object = managedObject
            } else {
                fatalError("Inserted object type is not `\(T.self)`")
            }
        }
        return object
    }
    
}
