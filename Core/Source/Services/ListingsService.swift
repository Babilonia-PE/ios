//
//  ListingsService.swift
//  Core
//
//  Created by Denis on 6/25/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import YALAPIClient
import DBClient

final public class ListingsService {
    
    private let userSession: UserSession
    private let client: NetworkClient
    private let storage: DBClient
    private let newClient: NetworkClient
    
    public init(userSession: UserSession, client: NetworkClient, storage: DBClient, newClient: NetworkClient) {
        self.userSession = userSession
        self.client = client
        self.storage = storage
        self.newClient = newClient
    }
    
    private let updatesQueue = DispatchQueue(label: "ListingsService.updatesQueue")
    private let updatesGroup = DispatchGroup()
    
    public func getMyListingDetails(for listingID: String, completion: @escaping (Result<Listing?>) -> Void) {
        let request = GetMyListingRequest(listingID: listingID)
        let decoder = JSONDecoder(dateFormatter: DateFormatters.timestamp)

        newClient.execute(
            request: request,
            parser: DecodableParser<Listing?>(keyPath: "data", decoder: decoder),
            completion: completion
        )
    }
    
    public func createListing(
        _ listing: Listing,
        photosInfo: CreateListingPhotosInfo,
        completion: @escaping (Result<Listing>) -> Void
        ) {
        let request = CreateListingRequest(listing: listing, photosInfo: photosInfo)
        let decoder = JSONDecoder(dateFormatter: DateFormatters.timestamp)
        newClient.execute(
            request: request,
            parser: DecodableParser<Listing>(keyPath: "object", decoder: decoder)
        ) { result in
            switch result {
            case .success(let listing):
                self.processListings([listing]) { processResult in
                    switch processResult {
                    case .success(let isSaved):
                        if isSaved {
                            completion(.success(listing))
                        } else {
                            completion(.failure(ServerError()))
                        }

                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func updateListing( //osemy
        _ listing: Listing,
        photosInfo: CreateListingPhotosInfo,
        completion: @escaping (Result<Bool>) -> Void
        ) {
        let request = UpdateListingRequest(listing: listing, photosInfo: photosInfo)
        let decoder = JSONDecoder(dateFormatter: DateFormatters.timestamp)
        newClient.execute(
            request: request,
            parser: DecodableParser<Listing>(keyPath: "object", decoder: decoder)
        ) { result in
            switch result {
            case .success(let listing):
                print("updateListing = \(listing)")
                self.processListings([listing], completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func getMyListingsObserver() -> RequestObservable<Listing> {
        let request = FetchRequest<Listing>(
            predicate: NSPredicate(
                format: "\(#keyPath(ManagedListing.user.id)) == %d", userSession.user.id
        ), sortDescriptors: [
                NSSortDescriptor(key: #keyPath(ManagedListing.createdAt), ascending: false)
        ])
        return storage.observable(for: request)

    }
    
    public func fetchMyListings(state: String, completion: @escaping (Result<Bool>) -> Void) {
        let dbrequest = FetchRequest<Listing>(
            predicate: NSPredicate(
                format: "\(#keyPath(ManagedListing.user.id)) == %d AND \(#keyPath(ManagedListing.state)) == %@",
                userSession.user.id,
                state
        ), sortDescriptors: [
                NSSortDescriptor(key: #keyPath(ManagedListing.createdAt), ascending: false)
        ])

        let localListings = storage.execute(dbrequest).require()

        let request = FetchMyListingsRequest(page: 1, state: state )
        let decoder = JSONDecoder(dateFormatter: DateFormatters.timestamp)
        newClient.execute(
            request: request,
            parser: DecodableParser<[Listing]>(keyPath: "data.records", decoder: decoder)
        ) { result in
            switch result {
            case .success(let listings):
#if DEBUG
                print("state = \(state), count = \(listings.count), listings = \(listings)")
#endif
                self.processMyListings(localListings: localListings,
                                       remoteListings: listings,
                                       completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    //osemy 25 -> 5
    public func fetchAllListings(
        areaInfo: FetchListingsAreaInfo? = nil,
        sort: String?,
        direction: String?,
        filters: ListingFilterModel? = nil,
        placeInfo: FetchListingsPlaceInfo? = nil,
        perPage: Int = 50,
        page: Int = 1,
        completion: @escaping (Result<[Listing]>) -> Void
    ) {
        let request = FetchAllListingsRequest(areaInfo: areaInfo,
                                              sort: sort,
                                              direction: direction,
                                              filters: filters,
                                              placeInfo: placeInfo,
                                              perPage: perPage,
                                              page: page)
        let decoder = JSONDecoder(dateFormatter: DateFormatters.timestamp)

        newClient.execute(
            request: request,
            parser: DecodableParser<[Listing]>(keyPath: "data.records", decoder: decoder),
            completion: completion
        )
    }
    //osemy
    public func fetchAllListings(
        searchLocation: SearchLocation,
        sort: String?,
        direction: String?,
        filters: ListingFilterModel? = nil,
        perPage: Int = 50,
        page: Int = 1,
        completion: @escaping (Result<[Listing]>) -> Void
    ) {
        let request = FetchAllListingsAddressRequest(searchLocation: searchLocation,
                                                     sort: sort,
                                                     direction: direction,
                                                     filters: filters,
                                                     perPage: perPage,
                                                     page: page)
        let decoder = JSONDecoder(dateFormatter: DateFormatters.timestamp)

        newClient.execute(
            request: request,
            parser: DecodableParser<[Listing]>(keyPath: "data.records", decoder: decoder),
            completion: completion
        )
    }

    public func getListingDetails(for listingID: String, completion: @escaping (Result<Listing?>) -> Void) {
        let request = ListingDetailsRequest(listingID: listingID)
        let decoder = JSONDecoder(dateFormatter: DateFormatters.timestamp)

        newClient.execute(
            request: request,
            parser: DecodableParser<Listing?>(keyPath: "data", decoder: decoder),
            completion: completion
        )
    }

    public func favoriteListings(completion: @escaping (Result<[Listing]>) -> Void) {
        let request = FavotitesListingsRequest()
        let decoder = JSONDecoder(dateFormatter: DateFormatters.timestamp)

        newClient.execute(
            request: request,
            parser: DecodableParser<[Listing]>(keyPath: "data.records.listings", decoder: decoder),
            completion: completion
        )
    }

    public func addListingToFavorite(
        listingID: String,
        ipAddress: String,
        userAgent: String,
        signProvider: String,
        completion: @escaping ((Result<Bool>) -> Void)) {
        let request = TrackUserActionRequest(listingID: listingID,
                                             key: .favourite,
                                             ipAddress: ipAddress,
                                             userAgent: userAgent,
                                             signProvider: signProvider)

        newClient.execute(request: request, parser: EmptyParser()) { result in
            switch result {
            case .success(let isAdded):
                completion(.success(isAdded))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func deleteListingFromFavorite(
        listingID: String,
        ipAddress: String,
        userAgent: String,
        signProvider: String,
        completion: @escaping ((Result<Bool>) -> Void)) {
        let request = DeleteUserActionRequest(listingID: listingID,
                                              key: .favourite,
                                              ipAddress: ipAddress,
                                              userAgent: userAgent,
                                              signProvider: signProvider)

        newClient.execute(request: request, parser: EmptyParser()) { result in
            switch result {
            case .success(let isDeleted):
                completion(.success(isDeleted))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func triggerContactFromFavorite(
        listingID: String,
        ipAddress: String,
        userAgent: String,
        signProvider: String,
        completion: @escaping ((Result<Bool>) -> Void)) {
        let request = TrackUserActionRequest(listingID: listingID,
                                             key: .phoneView,
                                             ipAddress: ipAddress,
                                             userAgent: userAgent,
                                             signProvider: signProvider)

        newClient.execute(request: request, parser: EmptyParser()) { result in
            switch result {
            case .success(let isTriggered):
                completion(.success(isTriggered))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func triggerWhatsappFromDetail(
        listingID: String,
        ipAddress: String,
        userAgent: String,
        signProvider: String,
        completion: @escaping ((Result<Bool>) -> Void)) {
        let request = TrackUserActionRequest(listingID: listingID,
                                             key: .whatsappView,
                                             ipAddress: ipAddress,
                                             userAgent: userAgent,
                                             signProvider: signProvider)

        newClient.execute(request: request, parser: EmptyParser()) { result in
            switch result {
            case .success(let isTriggered):
                completion(.success(isTriggered))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func triggerViewFromDetail(
        listingID: String,
        ipAddress: String,
        userAgent: String,
        signProvider: String,
        completion: @escaping ((Result<Bool>) -> Void)) {
        let request = TrackUserActionRequest(listingID: listingID,
                                             key: .viewsView,
                                             ipAddress: ipAddress,
                                             userAgent: userAgent,
                                             signProvider: signProvider)

        newClient.execute(request: request, parser: EmptyParser()) { result in
            switch result {
            case .success(let isTriggered):
                completion(.success(isTriggered))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func getFilteredListingsCount(for model: ListingFilterModel,
                                         completion: @escaping ((Result<SearchMetadata>) -> Void)) {
        let request = ListingSearchMetadataRequest(listingFilterModel: model)
        let parser = DecodableParser<SearchMetadata>(keyPath: "data")

        newClient.execute(request: request, parser: parser) { result in
            switch result {
            case .success(let searchMetadata):
                completion(.success(searchMetadata))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func getPriceHistogramSlots(for model: ListingFilterModel,
                                       completion: @escaping ((Result<[HistogramSlot]>) -> Void)) {
        let request = ListingPriceHistogramRequest(listingFilterModel: model)

        client.execute(
            request: request,
            parser: DecodableParser<[HistogramSlot]>(keyPath: "data.records"),
            completion: completion
        )
    }

    public func getTopListings(areaInfo: FetchListingsAreaInfo? = nil,
                               completion: @escaping ((Result<[Listing]>) -> Void)) {
        let decoder = JSONDecoder(dateFormatter: DateFormatters.timestamp)
        let request = TopListingsRequest(areaInfo: areaInfo)
        let parser = DecodableParser<[Listing]>(keyPath: "data.records", decoder: decoder)

        newClient.execute(request: request, parser: parser, completion: completion)
    }
    
    public func newDraftListing() -> Listing {
        return .newDraft(with: userSession.user)
    }
    
    public func updateDraftListing(_ listing: Listing, completion: ((Result<Listing?>) -> Void)? = nil) {
        updatesQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.updatesGroup.wait()
            self.updatesGroup.enter()
            
            self.storage.upsert(listing) { [weak self] result in
                completion?(result.map { $0.object as Listing? })
                self?.updatesGroup.leave()
            }
        }
    }
    
    public func removeDraftListing(_ listing: Listing, completion: (() -> Void)? = nil) {
        guard listing.status == .draft else { return }
        updatesQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.updatesGroup.wait()
            self.updatesGroup.enter()
            self.removeListingFromStorage(listing) { completion?() }
        }
    }

    // MARK: - private

    private func removeListingFromStorage(_ listing: Listing, completion: (() -> Void)? = nil) {
        self.storage.delete(listing) { [weak self] _ in
            self?.updatesGroup.leave()
            completion?()
        }
    }
    
    private func processListings(
        _ listings: [Listing],
        completion: @escaping (Result<Bool>) -> Void
        ) {
        storage.upsert(listings) { result in
            completion(result.map { true })
        }
    }

    private func processMyListings(localListings: [Listing],
                                   remoteListings: [Listing],
                                   completion: @escaping (Result<Bool>) -> Void) {

        deleteRemovedListings(localListings: localListings,
                              remoteListings: remoteListings) { [weak self] in
            self?.storage.upsert(remoteListings) { result in
                completion(result.map { true })
            }
        }
    }

    private func deleteRemovedListings(localListings: [Listing],
                                       remoteListings: [Listing],
                                       completion: @escaping () -> Void) {
        let notDraftListings = localListings.filter { $0.status != .draft }

        let listingsToDelete = notDraftListings.filter {
            !remoteListings.map { $0.id }.contains($0.id)
        }

        if !listingsToDelete.isEmpty {
            storage.delete(listingsToDelete) { _ in completion() }
        } else {
            completion()
        }
    }
    
}

private extension Listing {
    
    static func newDraft(with user: User) -> Listing {
        return Listing(
            area: nil,
            bathroomsCount: nil,
            bedroomsCount: nil,
            contactViewsCount: 0,
            favouritesCount: 0,
            id: -UUID().hashValue,
            ids: [-UUID().hashValue],
            listingDescription: "",
            listingType: nil,
            parkingSlotsCount: nil,
            petFriendly: nil,
            price: nil,
            primaryImageId: nil,
            propertyType: nil,
            status: .draft,
            viewsCount: 0,
            yearOfConstruction: nil,
            createdAt: Date(),
            adPurchasedAt: nil,
            adExpiresAt: nil,
            adPlan: nil,
            state: .notPublished,
            role: nil,
            coveredArea: nil,
            parkingForVisits: nil,
            totalFloorsCount: nil,
            floorNumber: nil,
            user: user,
            location: nil,
            images: nil,
            facilities: nil,
            advancedDetails: nil,
            contacts: nil,
            url: nil
        )
    }
    
}

public struct CreateListingPhotosInfo {
    
    let primaryImageID: Int
    let imageIDs: [Int]
    
    public init(primaryImageID: Int, imageIDs: [Int]) {
        self.primaryImageID = primaryImageID
        self.imageIDs = imageIDs
    }
    
}
