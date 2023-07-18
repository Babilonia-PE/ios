//
//  ListingsFiltersViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 29.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Core

final class ListingsFiltersViewModel {

    // MARK: - Observers

    var requestState: Observable<RequestState> {
        model.requestState.asObservable().observeOn(MainScheduler.instance)
    }

    var listingsCountObservable: Observable<Int?> {
        model.listingsCount.asObservable()
    }
    var facilitiesViewModels: Observable<[CreateListingFacilityViewModel]> {
        model.facilitiesViewModels.asObservable()
    }
    var histogramSlotsObservable: Observable<[HistogramSlot]> {
        model.histogramSlots.asObservable()
    }
    var viewDidChange: Observable<[FilterViewType]> {
        model.viewDidChange.asObservable()
    }

    // MARK: - ViewModels

    var listingTypeViewModel: ListingPropertyTypeViewModel {
        model.listingTypeViewModel
    }
    var histogramViewModel: HistogramViewModel {
        model.histogramViewModel
    }
    var totalAreaViewModel: SliderRangeViewModel {
        model.totalAreaViewModel
    }
    var builtAreaViewModel: SliderRangeViewModel {
        model.builtAreaViewModel
    }
    var yearViewModel: YearRangeViewModel {
        model.yearViewModel
    }
    var checkmarkFileldViewModels: [CreateListingFacilityViewModel] {
        model.checkmarkFileldViewModels
    }
    var counterViewModels: [NumberFieldViewModel] {
        model.counterViewModels
    }

    private let model: ListingsFiltersModel
    
    init(model: ListingsFiltersModel) {
        self.model = model
    }

    func reloadFilters() {
        getFilteredListingsCount()
        getHistogramSlots()
        fetchFacilities()
    }

    func resetFilters() {
        model.resetFilters()
    }

    func getFilteredListingsCount() {
        model.getFilteredListingsCount()
    }

    func getHistogramSlots() {
        model.getHistogramSlots()
    }

    func fetchFacilities() {
        model.fetchFacilities()
    }

    func apply() {
        model.apply()
    }
    
}
