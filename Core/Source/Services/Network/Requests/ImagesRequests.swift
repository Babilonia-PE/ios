//
//  ImagesRequests.swift
//  Core
//
//  Created by Denis on 7/5/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import YALAPIClient

struct UploadImageRequest: MultipartAPIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .post
    var path = "users/me/images"
    let authRequired: Bool = true
    var multipartFormData: ((MultipartFormDataType) -> Void)
    var progressHandler: ProgressHandler?
    
    init(jpegData: Data) {
        multipartFormData = { dataType in
            dataType.append(
                jpegData,
                withName: "data[photo]",
                fileName: "\(UUID().uuidString).jpg",
                mimeType: "image/jpeg"
            )
        }
    }
    
}

struct DeleteImageRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .delete
    let path: String
    let authRequired: Bool = true
    
    init(imageID: Int) {
        path = "users/me/images/\(imageID)"
    }
    
}
