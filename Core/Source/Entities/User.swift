//
//  User.swift
//  Core
//
//  Created by Denis on 5/28/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

public typealias UserId = Int

public extension UserId {
    static let guest = 0
}

public struct User: Codable {
    
    public let id: UserId
    public var email: String?
    public var fullName: String?
    //public var lastName: String?
    public var phoneNumber: String?
    public let avatar: RemoteImage?
    public var company: Сompany?
    
    //55547 TODO: - Remove it.
    public init(
        id: UserId,
        email: String?,
        fullName: String?,
        //lastName: String?,
        phoneNumber: String?,
        avatar: RemoteImage?) {
        self.id = id
        self.email = email
        self.fullName = fullName
        //self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.avatar = avatar
    }
    
}

//extension User {
//
//    public var fullName: String {
//        //return [firstName, lastName].compactMap { $0 }.joined(separator: " ")
//        return self.firstName ?? ""
//    }
//
//}

public struct Сompany: Codable {
    
    public var title: String?
    public var commercialName: String?
    public var companyId: String?
    public var commercialAddress: String?
}
