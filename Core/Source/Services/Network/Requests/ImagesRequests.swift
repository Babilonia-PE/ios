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
    var path = "me/images"
    let authRequired: Bool = true
    var multipartFormData: ((MultipartFormDataType) -> Void)
    var progressHandler: ProgressHandler?
    
    init(jpegData: Data,
         type: String) {
        multipartFormData = { dataType in
            dataType.append(
                jpegData,
                withName: "photo[]",
                fileName: "\(UUID().uuidString).jpg",
                mimeType: "image/jpeg"
            )
            if let sourceData = "ios".data(using: .utf8) {
                dataType.append(sourceData, withName: "source")
            }
            if let typeData = type.data(using: .utf8) {
                dataType.append(typeData, withName: "type")
            }
        }
    }
    
}

struct DeleteImageRequest: APIRequest, DecoratableRequest {
    
    let method: APIRequestMethod = .delete
    let path: String
    let authRequired: Bool = true
    
    init(imageID: Int) {
        path = "me/images/\(imageID)"
    }
    
}
