//
//  LocationSearchViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 17.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Core

final class LocationSearchViewModel {

    var requestState: Observable<RequestState> {
        return model.requestState.asObservable().observeOn(MainScheduler.instance)
    }
    var searchTerm: String {
        model.searchTerm
    }
    var currentLocationObservable: Observable<String?> {
        model.currentLocation.asObservable()
    }
    var locationsObservable: Observable<[SearchLocations]> {
        model.locations.asObservable()
    }
    var recentSearchesObservable: Observable<[RecentSearch]> {
        model.recentSearches.asObservable()
    }
    var requestForLocationPermissionObservable: Observable<Void> {
        model.requestForLocationPermission.asObservable()
    }
    var locations: [SearchLocations] {
        model.locations.value
    }
    var recentSearches: [RecentSearch] {
        model.recentSearches.value
    }
    var isCurrentLocationSearch: Bool {
        set {
            model.isCurrentLocationSearch = newValue
        }
        get {
            model.isCurrentLocationSearch
        }
    }

    private let model: LocationSearchModel
    
    init(model: LocationSearchModel) {
        self.model = model
    }

    func requestCurrentLocation() {
        model.requestCurrentLocation()
    }

    func searchLocations(with term: String) {
        model.searchLocations(with: term)
    }

    func proccedSearch(with term: String) {
        model.proccedSearch(with: term)
    }

    func updateListingsWithAddress(at index: Int, isRecentSearches: Bool) {
        model.updateListingsWithAddress(at: index, isRecentSearches: isRecentSearches)
    }

    func fetchRecentSearches() {
        model.fetchRecentSearches()
    }

    func resultRowsCount(isRecentSearches: Bool) -> Int {
        isRecentSearches ? recentSearches.count : locations.count
    }

    func resultName(isRecentSearches: Bool, index: Int) -> String {
        if isRecentSearches {
            return recentSearches[index].queryString
        } else {
            return locations[index].address
        }
    }

}
