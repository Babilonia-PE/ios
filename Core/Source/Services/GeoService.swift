//
//  GeoService.swift
//  Core
//
//  Created by Emily L. on 9/14/21.
//  Copyright © 2021 Yalantis. All rights reserved.
//

import Foundation
import YALAPIClient

final public class GeoService: NSObject {

    private let client: NetworkClient
    private let newClient: NetworkClient

    public init(client: NetworkClient, newClient: NetworkClient) {
        self.client = client
        self.newClient = newClient
    }

    public func getDepartments(completion: @escaping (Result<[String]>) -> Void) {
        let request = DepartmentRequest()
        let parser = DecodableParser<[String]>(keyPath: "data.ubigeo")

        newClient.execute(request: request, parser: parser, completion: completion)
    }
    
    public func getProvinces(department: String, completion: @escaping (Result<[String]>) -> Void) {
        let request = ProvinceRequest(department: department)
        let parser = DecodableParser<[String]>(keyPath: "data.ubigeo")

        newClient.execute(request: request, parser: parser, completion: completion)
    }
    
    public func getDistricts(department: String, province: String, completion: @escaping (Result<[String]>) -> Void) {
        let request = DistrictRequest(department: department, province: province)
        let parser = DecodableParser<[String]>(keyPath: "data.ubigeo")

        newClient.execute(request: request, parser: parser, completion: completion)
    }
}
