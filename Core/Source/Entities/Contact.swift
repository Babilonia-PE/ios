//
//  Contact.swift
//  Core
//
//  Created by Emily L. on 9/11/21.
//  Copyright © 2021 Yalantis. All rights reserved.
//

import Foundation

public struct Contact: Codable {
    
    public var contactEmail: String?
    public var contactName: String?
    public var contactPhone: String?
    
    //55547 TODO: - Remove it.
    public init(
        contactEmail: String?,
        contactName: String?,
        contactPhone: String?) {
        self.contactEmail = contactEmail
        self.contactName = contactName
        self.contactPhone = contactPhone
    }
    
    enum CodingKeys: String, CodingKey {
        case contactEmail = "email"
        case contactName = "name"
        case contactPhone = "phone"
    }
}
