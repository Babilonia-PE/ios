//
//  ImagesService.swift
//  Core
//
//  Created by Denis on 7/5/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import YALAPIClient

final public class ImagesService {
    
    private let client: NetworkClient
    private let newClient: NetworkClient
    
    public init(client: NetworkClient, newClient: NetworkClient) {
        self.client = client
        self.newClient = newClient
    }
    
    @discardableResult
    public func uploadImage(_ image: UIImage,
                            type: String = "listing",
                            completion: @escaping (Result<[ListingImage]>) -> Void) -> Cancelable? {
        switch ImageCompressor.prepareForUpload(image) {
        case .success(let compressedData):
            let request = UploadImageRequest(jpegData: compressedData.data, type: type)
            
            return newClient.execute(
                request: request,
                parser: DecodableParser<[ListingImage]>(keyPath: "data.ids"), completion: completion
            )
        case .failure(let error):
            completion(.failure(error))
            return nil
        }
    }
    
    public func deleteImage(_ imageID: Int, completion: @escaping (Result<Bool>) -> Void) {
        let request = DeleteImageRequest(imageID: imageID)
        
        newClient.execute(request: request, parser: EmptyParser(), completion: completion)
    }
    
}
