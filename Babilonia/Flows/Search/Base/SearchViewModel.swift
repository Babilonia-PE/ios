//
//  SearchViewModel.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import UIKit.UIImage
import RxCocoa
import RxSwift

final class SearchViewModel {
    
    var switchButtonImageUpdated: Driver<UIImage> { return model.modeUpdated.map { $0.buttonImage } }
    var arButtonAvailable: Driver<Bool> { return model.modeUpdated.map { $0 == .map } }
    var modeUpdated: Driver<SearchMode> { return model.modeUpdated.distinctUntilChanged() }
    var onSearchText: Driver<String?> { return searchText.asDriver() }
    var filtersApplied: Observable<Bool> { return model.filtersApplied.asObservable() }
    var listingsFoundCount: Observable<Int> { return model.listingsFoundCount.asObservable() }

    var searchAssressObservable: Observable<String?> {
        model.searchAddress.asObservable()
    }
    var shouldShowARPopUp: Bool {
        get { model.shouldShowARPopUp }
        set { model.shouldShowARPopUp = newValue }
    }
    var appliedFilters: Observable<[FilterInfo]> { model.appliedFilters.asObservable() }

    private let model: SearchModel
    
    private var viewModelsMap = [SearchMode: Any]()
    private let searchText = BehaviorRelay<String?>(value: nil)
    private let disposeBag = DisposeBag()

    init(model: SearchModel) {
        self.model = model
    }
    
    func requestAugmentedRealityPresentation() {
        model.requestAugmentedRealityPresentation()
    }

    func openLocationSearch(searchTerm: String) {
        model.openLocationSearch(searchTerm: searchTerm)
    }

    func presentListingsFilters() {
        model.presentListingsFilters()
    }

    func removeFilter(at index: Int) {
        model.removeFilter(at: index)
    }

    func switchMode() {
        model.switchMode()
    }

    func removeSearchAddress() {
        model.removeSearchAddress()
    }
    
    func viewModel(for mode: SearchMode) -> Any {
        if let viewModel = viewModelsMap[mode] {
//            if mode == .map {
//                updateViewModelData()
//            }
            return viewModel
        } else {
            let viewModel: Any
            switch mode {
            case .list:
                guard let searchListModel = model.model(for: mode) as? SearchListModel else {
                    fatalError("Can't cast to \(SearchListModel.self)")
                }
                viewModel = SearchListViewModel(model: searchListModel)
            case .map:
                guard let searchMapModel = model.model(for: mode) as? SearchMapModel else {
                    fatalError("Can't cast to \(SearchMapModel.self)")
                }
                
//                if let searchListModel = model.model(for: .list) as? SearchListModel {
//                    if RecentLocation.shared.currentLocation != nil {
//                        searchMapModel.updateListingByList(listing: searchListModel.firstListing())
//                    } else if let mapLocation = searchListModel.getMapLocation() {
//                        searchMapModel.updateListingByList(listing: nil)
//                        searchMapModel.updateCoordinate(mapLocation)
//                    } else {
//                        searchMapModel.updateListingByList(listing: searchListModel.firstListing())
//                    }
//                } else {
//                    searchMapModel.updateListingByList(listing: nil)
//                }
                
                viewModel = SearchMapViewModel(model: searchMapModel)
                
                if mode == .map {
                    updateViewModelData()
                }
            }
            viewModelsMap[mode] = viewModel
            
            return viewModel
        }
    }

    func updateViewModelData() {
        guard let searchMapModel = model.model(for: .map) as? SearchMapModel else {
            return
        }
        
        if let searchListModel = model.model(for: .list) as? SearchListModel {
            if RecentLocation.shared.currentLocation != nil {
                searchMapModel.updateListingByList(listing: searchListModel.firstListing())
            } else if let mapLocation = searchListModel.getMapLocation() {
                searchMapModel.updateListingByList(listing: nil)
                searchMapModel.updateCoordinate(mapLocation)
            } else {
                searchMapModel.updateListingByList(listing: searchListModel.firstListing())
            }
        } else {
            searchMapModel.updateListingByList(listing: nil)
        }
    }
}

private extension SearchMode {
    
    var buttonImage: UIImage {
        switch self {
        case .list:
            return Asset.Search.mapModeIcon.image
        case .map:
            return Asset.Search.listModeIcon.image
        }
    }
    
}
