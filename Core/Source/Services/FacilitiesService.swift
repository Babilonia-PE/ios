//
//  FacilitiesService.swift
//  Core
//
//  Created by Denis on 6/14/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import YALAPIClient
import DBClient

final public class FacilitiesService {
    
    private let client: NetworkClient
    private let storage: DBClient
    
    // MARK: - lifecycle
    
    public init(client: NetworkClient, storage: DBClient) {
        self.client = client
        self.storage = storage
    }
    
    public func getObserver(for propertyType: PropertyType) -> RequestObservable<Facility> {
        let request = FetchRequest<Facility>(
            predicate: NSPredicate(
                format: "\(#keyPath(ManagedFacility.propertyTypes)) CONTAINS[cd] %@", propertyType.rawValue
            )
        )
        return storage.observable(for: request)
    }
    
    public func fetchFacilities(for propertyType: PropertyType,
                                type: FacilitiesType = .facility,
                                completion: @escaping (Result<Bool>) -> Void) {
        let request = FetchFacilitiesRequest(propertyType: propertyType, type: type)
        client.execute(
            request: request,
            parser: DecodableParser<[Facility]>(keyPath: "data.records")
        ) { result in
            switch result {
            case .success(let facilities):
                self.processFacilities(facilities, type: propertyType, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func getFacilities(for propertyType: PropertyType,
                              type: FacilitiesType = .facility,
                              completion: @escaping (Result<[Facility]>) -> Void) {
        let request = FetchFacilitiesRequest(propertyType: propertyType, type: type)
        let parser = DecodableParser<[Facility]>(keyPath: "data.records")

        client.execute(request: request, parser: parser, completion: { result in
            switch result {
            case .success(let facilities):
                completion(.success(facilities))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    // MARK: - private
    
    private func processFacilities(
        _ facilities: [Facility],
        type: PropertyType,
        completion: @escaping (Result<Bool>) -> Void
    ) {
        let toUpdateRequest = FetchRequest<Facility>(
            predicate: NSPredicate(
                format: "\(#keyPath(ManagedFacility.id)) IN %@", facilities.map { $0.id }
            )
        )
        
        var facilitiesToUpdate: [Facility]!
        var facilitiesToInsert: [Facility]!
        
        switch storage.execute(toUpdateRequest) {
        case .success(let resultingFacilities):
            facilitiesToUpdate = resultingFacilities.filter { !($0.propertyTypes ?? []).contains(type) }
            facilitiesToInsert = facilities.filter { !resultingFacilities.map { $0.id }.contains($0.id) }
        case .failure(let error):
            completion(.failure(error))
            return
        }
        
        let toRemoveRequest = FetchRequest<Facility>(
            predicate: NSPredicate(
                format: "NOT (\(#keyPath(ManagedFacility.id)) IN %@)", facilities.map { $0.id }
            )
        )
        
        var facilitiesToRemove: [Facility]!
        
        switch storage.execute(toRemoveRequest) {
        case .success(let resultingFacilities):
            facilitiesToRemove = resultingFacilities.filter { ($0.propertyTypes ?? []).contains(type) }
        case .failure(let error):
            completion(.failure(error))
            return
        }
        
        facilitiesToUpdate
            .enumerated()
            .forEach {
                if facilitiesToUpdate[$0.offset].propertyTypes != nil {
                    facilitiesToUpdate[$0.offset].propertyTypes?.append(type)
                } else {
                    facilitiesToUpdate[$0.offset].propertyTypes = [type]
                }
            }
        
        facilitiesToInsert
            .enumerated()
            .forEach {
                if facilitiesToInsert[$0.offset].propertyTypes != nil {
                    facilitiesToInsert[$0.offset].propertyTypes?.append(type)
                } else {
                    facilitiesToInsert[$0.offset].propertyTypes = [type]
                }
            }
        
        facilitiesToRemove
            .enumerated()
            .forEach { facilitiesToRemove[$0.offset].propertyTypes?.removeAll(where: { $0 == type }) }
        
        storage.upsert(facilitiesToInsert + facilitiesToUpdate + facilitiesToRemove) { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
