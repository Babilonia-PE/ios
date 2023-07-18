//
//  ProfileRequests.swift
//  Core
//
//  Created by Anna Sahaidak on 7/5/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import YALAPIClient

struct ProfileInfoRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .get
    let path = "users/me/profile"
    let authRequired: Bool = true
    
}

struct UpdateProfileRequest: MultipartAPIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .put
    let path = "users/me/profile"
    let authRequired: Bool = true
    var multipartFormData: ((MultipartFormDataType) -> Void)
    var progressHandler: ProgressHandler?
    
    private(set) var parameters: [String: Any]?
    
    init(firstName: String? = nil,
         lastName: String? = nil,
         email: String? = nil,
         jpegData: Data? = nil,
         progressHandler: ProgressHandler? = nil) {
        multipartFormData = { dataType in
            if let jpegData = jpegData {
                dataType.append(
                    jpegData,
                    withName: "data[avatar]",
                    fileName: "\(UUID().uuidString).jpg",
                    mimeType: "image/jpeg"
                )
            }
            if let fistNameData = firstName?.data(using: .utf8) {
                dataType.append(fistNameData, withName: "data[first_name]")
            }
            if let lastNameData = lastName?.data(using: .utf8) {
                dataType.append(lastNameData, withName: "data[last_name]")
            }
            if let emailData = email?.data(using: .utf8) {
                dataType.append(emailData, withName: "data[email]")
            }
        }
        self.progressHandler = progressHandler
    }
    
}

struct FavotitesListingsRequest: APIRequest, DecoratableRequest {

    let method: APIRequestMethod = .get
    let path = "users/me/favourite_listings"
    let authRequired = true
    private(set) var parameters: [String: Any]?

}

struct RecentSearchesRequest: APIRequest, DecoratableRequest {

    let method: APIRequestMethod = .get
    let path = "users/me/recent_searches"
    let authRequired = true
    private(set) var parameters: [String: Any]?

}
