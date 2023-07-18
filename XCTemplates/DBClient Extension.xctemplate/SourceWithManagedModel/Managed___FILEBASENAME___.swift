//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import CoreData

@objc(Managed___VARIABLE_moduleName___)
final class Managed___VARIABLE_moduleName___: NSManagedObject {}

extension Managed___VARIABLE_moduleName___ {
    
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Managed___VARIABLE_moduleName___> {
        return NSFetchRequest<Managed___VARIABLE_moduleName___>(entityName: ___VARIABLE_moduleName___.entityName)
    }
    
    @NSManaged var id: String
}
