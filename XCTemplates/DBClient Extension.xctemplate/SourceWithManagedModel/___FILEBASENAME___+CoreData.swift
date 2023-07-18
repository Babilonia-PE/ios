//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import DBClient
import CoreData

extension ___VARIABLE_moduleName___: CoreDataModelConvertible {
    
    public static var primaryKeyName: String? { return #keyPath(Managed___VARIABLE_moduleName___.id) }
    
    public var valueOfPrimaryKey: CVarArg? { return id }
    
    public static func managedObjectClass() -> NSManagedObject.Type { return Managed___VARIABLE_moduleName___.self }
    
    public static var entityName: String { return String(describing: self) }
    
    public func isPrimaryValueEqualTo(value: Any) -> Bool {
        if let value = value as? ___VARIABLE_moduleName___Id {
            return id == value
        }
        
        return false
    }
    
    public static func from(_ managedObject: NSManagedObject) -> Stored {
        guard let object = managedObject as? Managed___VARIABLE_moduleName___ else {
            fatalError("can't cast given `NSManagedObject`: \(managedObject) to `\(___VARIABLE_moduleName___.self)`")
        }
        
        return instantiate(object)
    }
    
    public func upsertManagedObject(
        in context: NSManagedObjectContext,
        existedInstance: NSManagedObject?
    ) -> NSManagedObject {
        let object: Managed___VARIABLE_moduleName___ = upsertingManagedObject(of: ___VARIABLE_moduleName___.self, in: context, with: existedInstance)
        
        map(object)
        
        return object
    }
    
    // MARK: - Private methods
    
    private func map(_ object: Managed___VARIABLE_moduleName___) {
        <#T##object.id = id#>
        <#T##object.name = name ...#>
    }
    
    private static func instantiate(_ object: Managed___VARIABLE_moduleName___) -> ___VARIABLE_moduleName___ {
        return ___VARIABLE_moduleName___(
            <#T##id: object.id#>,
            <#T##name: object.name ...#>
        )
    }
}
