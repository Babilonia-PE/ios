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
    private let newClient: NetworkClient

    public var userID: Int {
        userSession.user.id
    }
    
    public var userIsLoggedIn: Bool {
        userSession.state == .opened
    }

    public init(userSession: UserSession, client: NetworkClient, storage: DBClient, newClient: NetworkClient) {
        self.userSession = userSession
        self.client = client
        self.storage = storage
        self.newClient = newClient
    }
    
    public func getProfile(completion: @escaping (Result<User>) -> Void) {
        let request = ProfileInfoRequest()
        newClient.execute(request: request, parser: DecodableParser<User>(keyPath: "data")) { [weak self] result in
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
        fullName: String? = nil,
        //lastName: String? = nil,
        email: String? = nil,
        //image: UIImage? = nil,
        //progressHandler: ProgressHandler? = nil,
        photoId: Int? = nil,
        phoneNumber: String? = nil,
        completion: @escaping (Result<Bool>) -> Void
    ) {
//        var imageData: Data?
//        if let image = image {
//            switch ImageCompressor.prepareForUpload(image) {
//            case .success(let compressedData):
//                imageData = compressedData.data
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
        
        let request = UpdateProfileRequest(fullName: fullName,
                                           //lastName: lastName,
                                           email: email,
                                           photoId: photoId,
                                           phoneNumber: phoneNumber)
        newClient.execute(
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
    
    public func deleteAccount(completion: @escaping (Result<Bool>) -> Void) {
        let request = ProfileDeleteRequest()
        newClient.execute(request: request, parser: DecodableParser<UserDelete>(keyPath: "data")) { [weak self] result in
            switch result {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func fetchRecentSearches(completion: @escaping (Result<[RecentSearch]>) -> Void) {
        let request = RecentSearchesRequest()
        let decoder = JSONDecoder(dateFormatter: DateFormatters.timestamp)

        newClient.execute(
            request: request,
            parser: DecodableParser<[RecentSearch]>(keyPath: "data.records", decoder: decoder),
            completion: completion
        )
    }
    
    public func getPhonePrefixes(
        completion: @escaping (Result<PhonePrefixResponse>) -> Void
    ) {
        let request = PhonePrefixesRequest()
        let decoder = JSONDecoder(dateFormatter: DateFormatters.timestamp)
        newClient.execute(
            request: request,
            parser: DecodableParser<PhonePrefixResponse>(keyPath: "data", decoder: decoder),
            completion: completion
        )
    }
    
}
