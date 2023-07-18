//
//  SearchModel.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Core
import RxSwift
import RxCocoa
import CoreLocation

protocol SearchUpdatable: class {
    func updateListings(filters: ListingFilterModel)
    func updateListings(areaInfo: FetchListingsAreaInfo,
                        placeInfo: FetchListingsPlaceInfo,
                        isCurrentLocation: Bool)
}

enum SearchEvent: Event {
    case didRequestAugmentedReality
    case locationSearch(searchTerm: String, isCurrentLocationSearch: Bool)
    case listingsFilters(areaInfo: FetchListingsAreaInfo?, model: ListingFilterModel?)
}

enum SearchMode {
    case list, map
}

final class SearchModel: EventNode {
    
    var modeUpdated: Driver<SearchMode> { return mode.asDriver().distinctUntilChanged() }
    let searchAddress = BehaviorRelay<String?>(value: nil)
    let filtersApplied = BehaviorRelay<Bool>(value: false)
    let listingsFoundCount = BehaviorRelay<Int>(value: 0)
    let appliedFilters = BehaviorRelay<[FilterInfo]>(value: [])

    var shouldShowARPopUp: Bool {
        get { !appSettingsStore.arPopUpShown }
        set { appSettingsStore.arPopUpShown = !newValue }
    }
    
    private let mode = BehaviorRelay<SearchMode>(value: .list)
    
    private var modelsMap = [SearchMode: Any]()
    private var filtersModel: ListingFilterModel?
    private var didChangeAuthorization: ((CLAuthorizationStatus) -> Void)?
    private var isCurrentLocationSearch = false
    private let updateFoundListingsCount = PublishSubject<ListingFilterModel?>()
    private let sortOption = BehaviorRelay<SortOption>(value: .mostRelevant)
    private let disposeBag = DisposeBag()
    
    private let locationManager: LocationManager
    private let configService: ConfigurationsService
    private let listingsService: ListingsService
    private let userService: UserService
    private let appSettingsStore: AppSettingsStore

    // MARK: - lifecycle
    
    init(
        parent: EventNode,
        locationManager: LocationManager,
        configService: ConfigurationsService,
        listingsService: ListingsService,
        userService: UserService,
        appSettingsStore: AppSettingsStore
    ) {
        self.locationManager = locationManager
        self.configService = configService
        self.listingsService = listingsService
        self.userService = userService
        self.appSettingsStore = appSettingsStore

        super.init(parent: parent)

        checkLocation()
        presetModels()
        setupBindings()
    }

    func checkLocation() {
        handleLocationAuthStatus(locationManager.authorizationStatus)
    }

    func handleLocationAuthStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .denied, .restricted:
            updateDefaultLocation()

        default: break
        }
    }

    func requestAugmentedRealityPresentation() {
        raise(event: SearchEvent.didRequestAugmentedReality)
    }

    func openLocationSearch(searchTerm: String) {
        raise(event: SearchEvent.locationSearch(searchTerm: searchTerm,
                                                isCurrentLocationSearch: isCurrentLocationSearch))
    }

    func removeSearchAddress() {
        isCurrentLocationSearch = false
    }

    func presentListingsFilters() {
        var areaInfo: FetchListingsAreaInfo?
        if let listModel = modelsMap[.list] as? SearchListModel {
            areaInfo = listModel.generateAreaInfo()
        }

        raise(event: SearchEvent.listingsFilters(areaInfo: areaInfo, model: filtersModel))
    }
    
    func switchMode() {
        switch mode.value {
        case .list:
            mode.accept(.map)
        case .map:
            mode.accept(.list)
        }
    }

    func removeFilter(at index: Int) {
        guard index < appliedFilters.value.count, var model = filtersModel else { return }

        let filterForRemove = appliedFilters.value[index]
        model.removeFilter(for: filterForRemove.filterType)
        updateListings(filters: model)
    }
    
    func model(for mode: SearchMode) -> Any {
        if let model = modelsMap[mode] {
            return model
        } else {
            let model: Any
            switch mode {
            case .list:
                model = SearchListModel(parent: self,
                                        locationManager: locationManager,
                                        configService: configService,
                                        listingsService: listingsService,
                                        userService: userService,
                                        updateDefaulLocation: { [weak self] in self?.updateDefaultLocation() },
                                        sortOption: sortOption)
            case .map:
                model = SearchMapModel(parent: self,
                                       locationManager: locationManager,
                                       configService: configService,
                                       listingsService: listingsService,
                                       userService: userService,
                                       sortOption: sortOption,
                                       updateFoundListingsCount: updateFoundListingsCount)
            }
            modelsMap[mode] = model
            
            return model
        }
    }

    private func presetModels() {
        modelsMap[.list] = SearchListModel(parent: self,
                                           locationManager: locationManager,
                                           configService: configService,
                                           listingsService: listingsService,
                                           userService: userService,
                                           updateDefaulLocation: { [weak self] in self?.updateDefaultLocation() },
                                           sortOption: sortOption)
        modelsMap[.map] = SearchMapModel(parent: self,
                                         locationManager: locationManager,
                                         configService: configService,
                                         listingsService: listingsService,
                                         userService: userService,
                                         sortOption: sortOption,
                                         updateFoundListingsCount: updateFoundListingsCount)
    }
    
    private func setupBindings() {
        updateFoundListingsCount.doOnNext { [weak self] filters in
            guard let filters = filters else { return }
            self?.getFilteredListingsCount(filters)
        }.disposed(by: disposeBag)
    }

    private func updateDefaultLocation() {
        let address = configService.appConfigs?.location?.address
        searchAddress.accept(address)
    }

    func getFilteredListingsCount(_ model: ListingFilterModel? = nil) {
        guard let filtersModel = model ?? filtersModel else { return }
        listingsService.getFilteredListingsCount(for: filtersModel) { [weak self] result in
            switch result {
            case .success(let metadata):
                self?.listingsFoundCount.accept(metadata.listingsCount)

            case .failure:
                self?.listingsFoundCount.accept(0)
            }
        }
    }

}

extension SearchModel: SearchUpdatable {

    func updateListings(areaInfo: FetchListingsAreaInfo,
                        placeInfo: FetchListingsPlaceInfo,
                        isCurrentLocation: Bool) {
        isCurrentLocationSearch = isCurrentLocation
        searchAddress.accept(placeInfo.searchPlace)
        filtersModel?.areaInfo = areaInfo
        getFilteredListingsCount()

        modelsMap.forEach { _, value in
            guard let listingsUpdatable = value as? ListingsUpdatable else { return }
            listingsUpdatable.updateListings(areaInfo: areaInfo,
                                             placeInfo: placeInfo,
                                             isCurrentLocation: isCurrentLocation)
        }
    }

    func updateListings(filters: ListingFilterModel) {
        filtersModel = filters
        filtersApplied.accept(true)
        appliedFilters.accept(filters.convertToFilterInfo())
        getFilteredListingsCount()
        
        modelsMap.forEach { _, value in
            guard let listingsUpdatable = value as? ListingsUpdatable else { return }
            listingsUpdatable.updateListings(filters: filters)
        }
    }

}
