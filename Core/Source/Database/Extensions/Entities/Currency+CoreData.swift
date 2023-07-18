//
//  Currency+CoreData.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/24/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import DBClient
import CoreData

extension Currency: CoreDataModelConvertible {
    
    public static var primaryKeyName: String? { return #keyPath(ManagedCurrency.code) }
    
    public var valueOfPrimaryKey: CVarArg? { return code }
    
    public static func managedObjectClass() -> NSManagedObject.Type { return ManagedCurrency.self }
    
    public static var entityName: String { return String(describing: self) }
    
    public func isPrimaryValueEqualTo(value: Any) -> Bool {
        if let value = value as? String {
            return code == value
        }
        
        return false
    }
    
    public static func from(_ managedObject: NSManagedObject) -> Stored {
        guard let object = managedObject as? ManagedCurrency else {
            fatalError("can't cast given `NSManagedObject`: \(managedObject) to `\(Currency.self)`")
        }
        
        return instantiate(object)
    }
    
    public func upsertManagedObject(
        in context: NSManagedObjectContext,
        existedInstance: NSManagedObject?
    ) -> NSManagedObject {
        let object: ManagedCurrency = upsertingManagedObject(of: Currency.self, in: context, with: existedInstance)
        
        map(object)
        
        return object
    }
    
    // MARK: - Private methods
    
    private func map(_ object: ManagedCurrency) {
        object.title = title
        object.symbol = symbol
        object.code = code
        object.rate = rate
    }
    
    private static func instantiate(_ object: ManagedCurrency) -> Currency {
        return Currency(
            title: object.title,
            symbol: object.symbol,
            code: object.code,
            rate: object.rate
        )
    }
}
