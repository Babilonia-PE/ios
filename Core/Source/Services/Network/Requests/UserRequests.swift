//
//  ProfileRequests.swift
//  Core
//
//  Created by Anna Sahaidak on 7/5/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import YALAPIClient
import CoreLocation
import Alamofire

struct ProfileInfoRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .get
    let path = "me/profile"
    let authRequired: Bool = true
    
}

struct UpdateProfileRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .put
    let path = "me/profile"
    let authRequired: Bool = true
    var encoding: APIRequestEncoding? = JSONEncoding.default
    private(set) var parameters: [String: Any]?
    //var multipartFormData: ((MultipartFormDataType) -> Void)
    //var progressHandler: ProgressHandler?
    
    init(fullName: String? = nil,
         //lastName: String? = nil,
         email: String? = nil,
         password: String? = nil,
         photoId: Int? = nil,
         phoneNumber: String? = nil) {
        
        var params = [String: Any]()
        
        params["full_name"] = fullName
        params["email"] = email
        params["phone_number"] = phoneNumber
        if password != nil {
            params["change_password"] = true
            params["password"] = password
        } else {
            params["change_password"] = false
        }
        if let pId = photoId {
            params["photo[]"] = pId
        }
        
        parameters = params
        
//        multipartFormData = { dataType in
//            if let jpegData = jpegData {
//                dataType.append(
//                    jpegData,
//                    withName: "data[avatar]",
//                    fileName: "\(UUID().uuidString).jpg",
//                    mimeType: "image/jpeg"
//                )
//            }
//            if let fistNameData = firstName?.data(using: .utf8) {
//                dataType.append(fistNameData, withName: "data[first_name]")
//            }
//            if let lastNameData = lastName?.data(using: .utf8) {
//                dataType.append(lastNameData, withName: "data[last_name]")
//            }
//            if let emailData = email?.data(using: .utf8) {
//                dataType.append(emailData, withName: "data[email]")
//            }
//        }
//        self.progressHandler = progressHandler
    }
    
}

struct ProfileDeleteRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .delete
    let path = "me/profile"
    let authRequired: Bool = true
}

struct FavotitesListingsRequest: APIRequest, DecoratableRequest {

    let method: APIRequestMethod = .get
    let path = "me/favourite_listings"
    let authRequired = true
    private(set) var parameters: [String: Any]?

}

struct RecentSearchesRequest: APIRequest, DecoratableRequest {

    let method: APIRequestMethod = .get
    let path = "me/recent_searches"
    let authRequired = true
    private(set) var parameters: [String: Any]?

}
