//
//  UserService.swift
//  Core
//
//  Created by Anna Sahaidak on 7/5/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import YALAPIClient
import DBClient

final public class UserService {
    
    private let userSession: UserSession
    private let client: NetworkClient
    private let storage: DBClient

    public var userID: Int {
        userSession.user.id
    }
    
    public init(userSession: UserSession, client: NetworkClient, storage: DBClient) {
        self.userSession = userSession
        self.client = client
        self.storage = storage
    }
    
    public func getProfile(completion: @escaping (Result<User>) -> Void) {
        let request = ProfileInfoRequest()
        client.execute(request: request, parser: DecodableParser<User>(keyPath: "data")) { [weak self] result in
            switch result {
            case .success(let user):
                self?.userSession.updateSession(with: user)
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func updateProfile(
        firstName: String? = nil,
        lastName: String? = nil,
        email: String? = nil,
        image: UIImage? = nil,
        progressHandler: ProgressHandler? = nil,
        completion: @escaping (Result<Bool>) -> Void
    ) {
        var imageData: Data?
        if let image = image {
            switch ImageCompressor.prepareForUpload(image) {
            case .success(let compressedData):
                imageData = compressedData.data
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        let request = UpdateProfileRequest(firstName: firstName,
                                           lastName: lastName,
                                           email: email,
                                           jpegData: imageData,
                                           progressHandler: progressHandler)
        client.execute(
            request: request,
            parser: DecodableParser<User>(keyPath: "data")
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                let updateResult = self.userSession.updateSession(with: user)
                completion(updateResult)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func fetchRecentSearches(completion: @escaping (Result<[RecentSearch]>) -> Void) {
        let request = RecentSearchesRequest()
        let decoder = JSONDecoder(dateFormatter: DateFormatters.timestamp)

        client.execute(
            request: request,
            parser: DecodableParser<[RecentSearch]>(keyPath: "data.records", decoder: decoder),
            completion: completion
        )
    }
    
}
