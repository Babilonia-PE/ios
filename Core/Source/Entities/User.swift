//
//  User.swift
//  Core
//
//  Created by Denis on 5/28/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

public typealias UserId = Int

public struct User: Codable {
    
    public let id: UserId
    public var email: String?
    public var firstName: String?
    public var lastName: String?
    public let phoneNumber: String
    public let avatar: RemoteImage?
    public var company: Сompany?
    
    //55547 TODO: - Remove it.
    public init(
        id: UserId,
        email: String?,
        firstName: String?,
        lastName: String?,
        phoneNumber: String,
        avatar: RemoteImage?) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.avatar = avatar
    }
    
}

extension User {
    
    public var fullName: String {
        return [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }
    
}

public struct Сompany: Codable {
    
    public var title: String?
    public var commercialName: String?
    public var companyId: String?
    public var commercialAddress: String?
}
