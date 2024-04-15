//
//  User+CoreData.swift
//  Babilonia
//
//  Created by Denis on 5/28/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import DBClient
import CoreData

extension User: CoreDataModelConvertible {
    
    public static var primaryKeyName: String? { return #keyPath(ManagedUser.id) }
    
    public var valueOfPrimaryKey: CVarArg? { return id }
    
    public static func managedObjectClass() -> NSManagedObject.Type { return ManagedUser.self }
    
    public static var entityName: String { return String(describing: self) }
    
    public func isPrimaryValueEqualTo(value: Any) -> Bool {
        if let value = value as? UserId {
            return id == value
        }
        
        return false
    }
    
    public static func from(_ managedObject: NSManagedObject) -> Stored {
        guard let object = managedObject as? ManagedUser else {
            fatalError("can't cast given `NSManagedObject`: \(managedObject) to `\(User.self)`")
        }
        
        return instantiate(object)
    }
    
    public func upsertManagedObject(
        in context: NSManagedObjectContext,
        existedInstance: NSManagedObject?
    ) -> NSManagedObject {
        let object: ManagedUser = upsertingManagedObject(of: User.self, in: context, with: existedInstance)
        
        map(object)
        
        return object
    }
    
    // MARK: - Private methods
    
    private func map(_ object: ManagedUser) {
        object.id = Int64(id)
        object.email = email
        object.fullName = fullName
        //object.lastName = lastName
        object.phoneNumber = phoneNumber ?? ""
        
        guard let context = object.managedObjectContext else { return }
        
        object.avatar = avatar?.upsertManagedObject(in: context, existedInstance: object.avatar) as? ManagedRemoteImage
    }
    
    private static func instantiate(_ object: ManagedUser) -> User {
        return User(
            id: UserId(object.id),
            email: object.email,
            fullName: object.fullName,
            //lastName: object.lastName,
            prefix: object.prefix,
            phoneNumber: object.phoneNumber,
            avatar: object.avatar.flatMap(RemoteImage.instantiate)
        )
    }
}
