//
//  AutoCompleteSearchService.swift
//  Core
//
//  Created by Emily L. on 7/15/21.
//  Copyright © 2021. All rights reserved.
//

import YALAPIClient

final public class AutoCompleteSearchService {
    private let userSession: UserSession
    private let client: NetworkClient
    private let newClient: NetworkClient
    
    public init(userSession: UserSession, client: NetworkClient, newClient: NetworkClient) {
        self.userSession = userSession
        self.client = client
        self.newClient = newClient
    }
    
    public func fetchSearchLocations(
        address: String,
        perPage: Int = 25,
        page: Int = 1,
        completion: @escaping (Result<[AutoCompleteSearchLocation]>) -> Void
    ) {
        let request = AutoCompleteSearchRequest(address: address,
                                                perPage: perPage,
                                                page: page)
        
        let decoder = JSONDecoder(dateFormatter: DateFormatters.timestamp)

        newClient.execute(
            request: request,
            parser: DecodableParser<[AutoCompleteSearchLocation]>(keyPath: "data.records", decoder: decoder),
            completion: completion
        )
    }
    
}
