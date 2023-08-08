//
//  ListingsFiltersModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 29.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Core
import RxSwift
import RxCocoa
import DBClient

enum ListingsFiltersEvent: Event {
    case applyFilters(filters: ListingFilterModel)
}

final class ListingsFiltersModel: EventNode {

    // Observers

    let requestState = PublishSubject<RequestState>()
    let listingsCount = BehaviorRelay<Int?>(value: nil)
    let histogramSlots = BehaviorRelay(value: [HistogramSlot]())
    var viewDidChange: BehaviorRelay<[FilterViewType]> {
        filtersComposer.viewDidChange
    }

    // MARK: ViewModels

    var listingTypeViewModel: ListingPropertyTypeViewModel {
        filtersComposer.listingTypeViewModel
    }
    var histogramViewModel: HistogramViewModel {
        filtersComposer.histogramViewModel
    }
    var totalAreaViewModel: SliderRangeViewModel {
        filtersComposer.totalAreaViewModel
    }
    var builtAreaViewModel: SliderRangeViewModel {
        filtersComposer.builtAreaViewModel
    }
    var yearViewModel: YearRangeViewModel {
        filtersComposer.yearRangeViewModel
    }
    var checkmarkFileldViewModels: [CreateListingFacilityViewModel] {
        filtersComposer.checkmarkFileldViewModels
    }
    var counterViewModels: [NumberFieldViewModel] {
        filtersComposer.counterViewModels
    }
    var facilitiesViewModels: BehaviorRelay<[CreateListingFacilityViewModel]> {
        filtersComposer.facilitiesViewModels
    }

    // MARK: Services

    private let listingsService: ListingsService
    private let facilitiesService: FacilitiesService
    private var facilitiesObserver: RequestObservable<Facility>!
    private let filtersComposer = FiltersComposer()
    private let bag = DisposeBag()

    init(parent: EventNode,
         listingsService: ListingsService,
         facilitiesService: FacilitiesService,
         areaInfo: FetchListingsAreaInfo?,
         filtersModel: ListingFilterModel?) {
        self.listingsService = listingsService
        self.facilitiesService = facilitiesService

        super.init(parent: parent)

        filtersComposer.setupFiltersModel(filtersModel)
        filtersComposer.filterModel.areaInfo = areaInfo
        setupBinding()
    }

    func resetFilters() {
        filtersComposer.resetFilters()
    }

    func apply() {
        let filters = filtersComposer.filterModel
        raise(event: ListingsFiltersEvent.applyFilters(filters: filters))
    }

}

// MARK: - Binding

extension ListingsFiltersModel {

    private func proceedWithYearSelection(for bound: YearBound, titles: [String], startingIndex: Int) {
        let updateBlock = { [unowned self] (index: Int) in
            self.filtersComposer.updateYear(for: bound, yearIndex: index)
        }
        raise(event: CreateListingCommonEvent.pickPropertyType(from: titles,
                                                        updateHandler: updateBlock,
                                                        title: L10n.CreateListing.Details.YearOfConstruction.title,
                                                        startingIndex: startingIndex))
    }

    private func proceedWithPropertySelection(titles: [String], startingIndex: Int) {
        let updateBlock = { [unowned self] (index: Int) in
            self.filtersComposer.updatePropertyType(for: index)
        }
        raise(event: CreateListingCommonEvent.pickPropertyType(from: titles,
                                                               updateHandler: updateBlock,
                                                               title: L10n.CreateListing.Common.PropertyType.title,
                                                               startingIndex: startingIndex))
    }

    private func setupBinding() {
        filtersComposer.listingTypeDidChange
            .skip(1)
            .subscribe(onNext: { [weak self] in
                self?.getFilteredListingsCount()
                self?.getHistogramSlots()
            })
            .disposed(by: bag)

        filtersComposer.reloadFilters
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .skip(1)
            .subscribe(onNext: { [weak self] in
                self?.getFilteredListingsCount()
                self?.getHistogramSlots()
            })
            .disposed(by: bag)

        filtersComposer.reloadListingCount
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.getFilteredListingsCount()
            })
            .disposed(by: bag)

        filtersComposer.proceedYearPicker
            .skip(1)
            .subscribe(onNext: { [weak self] values in
                self?.proceedWithYearSelection(for: values.bound,
                                               titles: values.titles,
                                               startingIndex: values.startingIndex)
            })
            .disposed(by: bag)

        filtersComposer.proceedPropertyTypePicker
            .skip(1)
            .subscribe(onNext: { [weak self] values in
                self?.proceedWithPropertySelection(titles: values.titles,
                                                   startingIndex: values.startingIndex)
            })
            .disposed(by: bag)
    }

}

// MARK: - API requests

extension ListingsFiltersModel {

    func getFilteredListingsCount() {
        var filterModel = filtersComposer.filterModel
        if let location = RecentLocation.shared.currentLocation {
            filterModel.searchLocation = location
        }
        
        listingsService.getFilteredListingsCount(for: filterModel) { [weak self] result in
            switch result {
            case .success(let metadata):
                self?.listingsCount.accept(metadata.listingsCount)
                self?.filtersComposer.updateRanges(maxBuiltArea: metadata.maxBuiltArea,
                                                   maxTotalArea: metadata.maxTotalArea)

            case .failure(let error):
                if self?.isUnauthenticated(error) == true {
                    self?.raise(event: MainFlowEvent.logout)
                } else {
                    self?.listingsCount.accept(0)
                }
            }
        }
    }

    func getHistogramSlots() {
        listingsService.getPriceHistogramSlots(for: filtersComposer.filterModel) { [weak self] result in
            switch result {
            case .success(let slots):
                self?.histogramSlots.accept(slots)

            case .failure:
                self?.histogramSlots.accept([])
            }
        }
    }

    func fetchFacilities() {
        requestState.onNext(.started)
        facilitiesService.getFacilities(for: filtersComposer.propertyType ?? .apartment) { [weak self] result in
            switch result {
            case .success(let facilities):
                self?.requestState.onNext(.finished)
                self?.filtersComposer.facilities.accept(facilities.sorted { $0.id < $1.id })
            case .failure(let error):
                if self?.isUnauthenticated(error) == true {
                    self?.raise(event: MainFlowEvent.logout)
                } else {
                    self?.requestState.onNext(.failed(nil))
                    self?.filtersComposer.facilities.accept([])
                }
            }
        }

    }

    private func isUnauthenticated(_ error: Error?) -> Bool {
        guard let serverError = error as? CompositeServerError,
              let code = serverError.errors.first?.code else { return false }
        
        return code == .unauthenticated
    }
}
