//
//  ManagedContact+CoreDataProperties.swift
//  
//
//  Created by Owson on 24/05/22.
//
//

import Foundation
import CoreData


extension ManagedContact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedContact> {
        return NSFetchRequest<ManagedContact>(entityName: "Contact")
    }

    @NSManaged public var contactName: String?
    @NSManaged public var contactEmail: String?
    @NSManaged public var contactPhone: String?

}
