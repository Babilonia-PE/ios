//
//  FiltersComposer.swift
//  Babilonia
//
//  Created by Alya Filon  on 05.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Core
import RxCocoa
import RxSwift

enum RangeBound {
    case min
    case max
}

typealias RangeValue = (min: Int, max: Int)

class FiltersComposer {

    var filterModel = ListingFilterModel()
    let viewDidChange = BehaviorRelay<[FilterViewType]>(value: [])
    let listingTypeDidChange = BehaviorRelay(value: ())
    let facilities = BehaviorRelay(value: [Facility]())
    let facilitiesViewModels = BehaviorRelay<[CreateListingFacilityViewModel]>(value: [])
    let listingTypeChanged = BehaviorRelay<ListingType>(value: .sale)

    let reloadFilters = PublishRelay<Void>()
    let reloadListingCount = PublishRelay<Void>()
    let proceedYearPicker = BehaviorRelay<FilterYearValue>(value: (bound: .toYear, titles: [], startingIndex: 0))
    let proceedPropertyTypePicker = BehaviorRelay<FilterPropertyTypeValue>(value: (titles: [], startingIndex: 0))

    var listingType: ListingType = .sale {
        didSet {
            histogramViewModel.resetViewModel(to: listingType)
            filterModel.listingType = listingType
            listingTypeDidChange.accept(())
        }
    }

    var propertyType: PropertyType? {
        didSet {
            filterModel.propertyType = propertyType
            proccedPropertyType()
        }
    }

    var viewsType: [FilterViewType] = FilterViewType.allCases {
        didSet {
            viewDidChange.accept(viewsType)
        }
    }
    
    lazy var checkmarkFileldViewModels: [CreateListingFacilityViewModel] = {
        createCheckmarkFileldViewModels()
    }()

    var counterViewModels: [NumberFieldViewModel] {
        countersViewModelsMap
            .filter { self.viewsType.contains($0.key) }
            .map { $0.value }
            .sorted { $0.id < $1.id }
    }

    lazy var listingTypeViewModel: ListingPropertyTypeViewModel = {
        let listingTypeChanged = BehaviorRelay<ListingType>(value: .sale)
        listingTypeChanged
            .bind(onNext: { [weak self] type in self?.listingType = type })
            .disposed(by: disposeBag)

        let propertyTypeChanged = BehaviorRelay<PropertyType?>(value: nil)
        propertyTypeChanged
            .bind(onNext: { [weak self] type in self?.propertyType = type })
            .disposed(by: disposeBag)

        return ListingPropertyTypeViewModel(listingTypeChanged: listingTypeChanged,
                                            propertyTypeChanged: propertyTypeChanged,
                                            proceedPropertyTypePicker: proceedPropertyTypePicker)
    }()

    lazy var histogramViewModel: HistogramViewModel = {
        let sliderValue = BehaviorRelay<RangeValue>(value: (min: 0, max: 101))
        sliderValue
            .map { self.priceConverter.convertPrice(for: self.listingType, values: $0) }
            .bind(onNext: { [weak self] value in self?.updateHistogram(value) })
            .disposed(by: disposeBag)

        return HistogramViewModel(sliderValue: sliderValue)
    }()

    lazy var totalAreaViewModel: SliderRangeViewModel = {
        let rangeValueChanged = BehaviorRelay<RangeValue>(value: (min: 0, max: 0))
        rangeValueChanged
            .skip(1)
            .bind(onNext: { [weak self] values in self?.updateTotalArea(values) })
            .disposed(by: disposeBag)

        return SliderRangeViewModel(title: L10n.Filters.totalArea,
                                    sliderMaximumValue: totalAreaMaxValue,
                                    rangeValueChanged: rangeValueChanged)
    }()

    lazy var builtAreaViewModel: SliderRangeViewModel = {
        let rangeValueChanged = BehaviorRelay<RangeValue>(value: (min: 0, max: 0))
        rangeValueChanged
            .skip(1)
            .bind(onNext: { [weak self] values in self?.updateBuiltArea(values) })
            .disposed(by: disposeBag)

        return SliderRangeViewModel(title: L10n.Filters.coveredArea,
                                    sliderMaximumValue: builtAreaMaxValue,
                                    rangeValueChanged: rangeValueChanged)
    }()

    lazy var yearRangeViewModel: YearRangeViewModel = {
        return YearRangeViewModel(proceedYearPicker: proceedYearPicker)
    }()

    private var countersViewModelsMap = [FilterViewType: NumberFieldViewModel]()
    private let totalAreaMaxValue = BehaviorRelay<CGFloat>(value: 0)
    private let builtAreaMaxValue = BehaviorRelay<CGFloat>(value: 0)
    private let disposeBag = DisposeBag()
    private let priceConverter = FilterPriceConverter()

    init() {
        viewsType = FilterViewType.allCases
        setupBindings()
        countersViewModelsMap = createCounterViewModels()
    }

    func updateRanges(maxBuiltArea: Double?, maxTotalArea: Double?) {
        totalAreaViewModel.setEnablingFilelds(isEnabled: maxTotalArea != nil)
        builtAreaViewModel.setEnablingFilelds(isEnabled: maxBuiltArea != nil)

        if let maxTotalArea = maxTotalArea, totalAreaMaxValue.value != CGFloat(maxTotalArea) {
            totalAreaMaxValue.accept(CGFloat(maxTotalArea))
            totalAreaViewModel.maxTextValue.accept("\(Int(maxTotalArea))".commaConverted())

            if let presetRanges = totalAreaViewModel.presetRanges {
                totalAreaViewModel.minTextValue.accept("\(presetRanges.min)".commaConverted())
                totalAreaViewModel.maxTextValue.accept("\(presetRanges.max)".commaConverted())
                totalAreaViewModel.sliderViewModel.setValue([presetRanges.min, presetRanges.max].map { CGFloat($0) })

                filterModel.totalAreaFrom = presetRanges.min
                filterModel.totalAreaTo = presetRanges.max
            }
        }

        if let maxBuiltArea = maxBuiltArea, builtAreaMaxValue.value != CGFloat(maxBuiltArea) {
            builtAreaMaxValue.accept(CGFloat(maxBuiltArea))
            builtAreaViewModel.maxTextValue.accept("\(Int(maxBuiltArea))".commaConverted())

            if let presetRanges = builtAreaViewModel.presetRanges {
                builtAreaViewModel.minTextValue.accept("\(presetRanges.min)".commaConverted())
                builtAreaViewModel.maxTextValue.accept("\(presetRanges.max)".commaConverted())
                builtAreaViewModel.sliderViewModel.setValue([presetRanges.min, presetRanges.max].map { CGFloat($0) })

                filterModel.builtAreaFrom = presetRanges.min
                filterModel.builtAreaTo = presetRanges.max
            }
        }
    }

    func updatePropertyType(for index: Int) {
        listingTypeViewModel.updatePropertyType(for: index)
    }

    func updateYear(for bound: YearBound, yearIndex: Int) {
        yearRangeViewModel.updateYearRange(for: bound, yearIndex: yearIndex)
        switch bound {
        case .fromYear:
            filterModel.yearFrom = Int(yearRangeViewModel.fromYearTitles[yearIndex])

            let shouldSetDefaultYear = filterModel.yearTo == nil
            let toYear = shouldSetDefaultYear ? yearRangeViewModel.maxAvailableYear : filterModel.yearTo
            filterModel.yearTo = toYear
        case .toYear:
            filterModel.yearTo = Int(yearRangeViewModel.toYearTitles[yearIndex])

            let shouldSetDefaultYear = filterModel.yearFrom == nil
            let fromYear = shouldSetDefaultYear ? yearRangeViewModel.minAvailableYear : filterModel.yearFrom
            filterModel.yearFrom = fromYear
        }
        reloadFilters.accept(())
    }

    func resetFilters() {
        let areaInfo = filterModel.areaInfo
        filterModel = ListingFilterModel()
        filterModel.areaInfo = areaInfo
        listingTypeViewModel.reset()
        yearRangeViewModel.reset()
        counterViewModels.forEach { $0.value.accept(0) }
        checkmarkFileldViewModels.forEach { $0.value.accept(false) }
        resetRange()
        resetYear()
    }

    func setupFiltersModel(_ filtersModel: ListingFilterModel?) {
        if let model = filtersModel {
            filterModel = model
            listingTypeViewModel.listingType.accept(model.listingType)
            listingTypeViewModel.updatePropertyType(model.propertyType)

            presetHistogram(model)
            presetYears(model)
            presetCounters(model)
            presetCheckmarks(model)
            presetTotalArea(model)
            presetBuiltArea(model)
        } else {
            viewsType = FilterViewType.allCases
        }
    }

}

// MARK: Filters preseting

extension FiltersComposer {

    private func presetHistogram(_ model: ListingFilterModel) {
        histogramViewModel.presetPrices(to: model.listingType,
                                        priceStart: model.priceStart,
                                        priceEnd: model.priceEnd)
    }

    private func presetTotalArea(_ model: ListingFilterModel) {
        if let valueFrom = model.totalAreaFrom, let valueTo = model.totalAreaTo {
            totalAreaViewModel.presetRanges = (min: valueFrom, max: valueTo)
        }
    }

    private func presetBuiltArea(_ model: ListingFilterModel) {
        if let valueFrom = model.builtAreaFrom, let valueTo = model.builtAreaTo {
            builtAreaViewModel.presetRanges = (min: valueFrom, max: valueTo)
        }
    }

    private func presetYears(_ model: ListingFilterModel) {
        yearRangeViewModel.presetSelectedYears(fromYear: model.yearFrom, toYear: model.yearTo)
    }

    private func presetCounters(_ model: ListingFilterModel) {
        let values = [model.bedroomsCount, model.bathroomsCount,
                      model.totalFloorsCount, model.floorNumber, model.parkingSlotsCount]
            .map { $0 ?? 0 }
        for (index, viewModel) in counterViewModels.enumerated() {
            viewModel.value.accept(values[index])
        }
    }

    private func presetCheckmarks(_ model: ListingFilterModel) {
        let values = [model.parkingForVisits]
        for (index, viewModel) in checkmarkFileldViewModels.enumerated() {
            viewModel.value.accept(values[index])
        }
    }

}

// MARK: Filters updating

extension FiltersComposer {

    private func setupBindings() {
        facilities
            .bind(onNext: { [weak self] facilities in self?.createFacilitiesViewModels(for: facilities) })
            .disposed(by: disposeBag)
    }

    private func proccedPropertyType() {
        switch propertyType {
        case .apartment:
            viewsType = FilterViewType.allCases

        case .house:
            var types = FilterViewType.allCases
            types.removeAll { $0 == .floorNumber }
            viewsType = types

        case .commercial, .office:
            var types = FilterViewType.allCases
            types.removeAll { $0 == .bedrooms || $0 == .totalFloors }
            viewsType = types

        case .land:
            resetYear()
            var types = FilterViewType.commonTypes
            types.removeAll { $0 == .builtArea }
            viewsType = types + [.facilities]

        case .room:
            var types = FilterViewType.allCases
            types.removeAll { $0 == .builtArea || $0 == .totalFloors }
            viewsType = types

        default:
            viewsType = FilterViewType.allCases
        }
    }

    private func updateHistogram(_ value: (min: Int?, max: Int?)) {
        guard filterModel.priceStart != value.min || filterModel.priceEnd != value.max else { return }

        let priceEnd = value.max == priceConverter.maxPrice(for: listingType) ? nil : value.max
        filterModel.priceStart = value.min
        filterModel.priceEnd = priceEnd
        reloadListingCount.accept(())
    }

    private func updateTotalArea(_ value: RangeValue) {
        filterModel.totalAreaFrom = value.min == 0 ? nil : value.min
        filterModel.totalAreaTo = value.max == Int(totalAreaMaxValue.value) ? nil : value.max

        switch (filterModel.totalAreaFrom == nil, filterModel.totalAreaTo == nil) {
        case (false, true):
            filterModel.totalAreaTo = Int(totalAreaMaxValue.value)
        case (true, false):
            filterModel.totalAreaFrom = 0
        default: break
        }

        reloadFilters.accept(())
    }

    private func updateBuiltArea(_ value: RangeValue) {
        filterModel.builtAreaFrom = value.min == 0 ? nil : value.min
        filterModel.builtAreaTo = value.max == Int(builtAreaMaxValue.value) ? nil : value.max

        switch (filterModel.builtAreaFrom == nil, filterModel.builtAreaTo == nil) {
        case (false, true):
            filterModel.builtAreaTo = Int(builtAreaMaxValue.value)
        case (true, false):
            filterModel.builtAreaFrom = 0
        default: break
        }

        reloadFilters.accept(())
    }

    private func updateCheckmark(for type: FilterViewType, value: Bool) {
        switch type {
        case .parkingForVisitors:
            filterModel.parkingForVisits = value
        default: break
        }

        reloadFilters.accept(())
    }

    private func updateCounter(for type: FilterViewType, value: Int) {
        switch type {
        case .bedrooms:
            filterModel.bedroomsCount = value
        case .bathrooms:
            filterModel.bathroomsCount = value
        case .totalFloors:
            filterModel.totalFloorsCount = value
        case .floorNumber:
            filterModel.floorNumber = value
        case .parkingSlots:
            filterModel.parkingSlotsCount = value
        default: break
        }
        
        reloadFilters.accept(())
    }

    private func updateFacility(for id: Int, value: Bool) {
        if value {
            guard !filterModel.facilityIds.contains(id) else { return }
            filterModel.facilityIds.append(id)
        } else {
            filterModel.facilityIds.removeAll(where: { $0 == id })
        }
        reloadFilters.accept(())
    }

    private func updateAllFacilities(value: Bool) {
        facilitiesViewModels.value.forEach { viewModel in
            guard viewModel.title != self.facilitiesViewModels.value.first?.title else { return }
            viewModel.value.accept(value)
        }
    }

    func resetRange() {
        filterModel.totalAreaFrom = nil
        filterModel.totalAreaTo = nil
        filterModel.builtAreaTo = nil
        filterModel.builtAreaFrom = nil
    }

    private func resetYear() {
        filterModel.yearFrom = nil
        filterModel.yearTo = nil
    }

}

// MARK: ViewModels creation

extension FiltersComposer {

    private func createCheckmarkFileldViewModels() -> [CreateListingFacilityViewModel] {
        let checkmarksViewTypes = viewsType.filter { FilterViewType.checkmarksFilters.contains($0) }

        let viewModels = checkmarksViewTypes.map { type -> CreateListingFacilityViewModel in
            let value = BehaviorRelay(value: false)
            value
                .bind(onNext: { [weak self] value in self?.updateCheckmark(for: type, value: value) })
                .disposed(by: disposeBag)
            
            let viewModel = CreateListingFacilityViewModel(title: type.title,
                                                           image: type.icon,
                                                           value: value)

            return viewModel
        }

        return viewModels
    }

    private func createCounterViewModels() -> [FilterViewType: NumberFieldViewModel] {
        var viewModels = [FilterViewType: NumberFieldViewModel]()
        for (index, filter) in FilterViewType.counterFilters.enumerated() {
            let value = BehaviorRelay<Int>(value: 0)
            value
                .bind(onNext: { [weak self] value in self?.updateCounter(for: filter, value: value) })
                .disposed(by: disposeBag)

            let viewModel = NumberFieldViewModel(id: index,
                                                 title: filter.title,
                                                 value: value,
                                                 minimunValue: 0,
                                                 maximumValue: 99)
            viewModels[filter] = viewModel
        }

        return viewModels
    }

    private func createFacilitiesViewModels(for facilities: [Facility]) {
        let values = filterModel.facilityIds
        var viewModels = facilities.map { facility -> CreateListingFacilityViewModel in
            let imageURL = URL(string: facility.icon?.originalURLString ?? "")
            let facilityValue = BehaviorRelay(value: values.contains(facility.id))
            facilityValue
                .bind(onNext: { [weak self] value in self?.updateFacility(for: facility.id, value: value) })
                .disposed(by: disposeBag)

            let viewModel = CreateListingFacilityViewModel(id: facility.id,
                                                           title: facility.title,
                                                           imageURL: imageURL,
                                                           value: facilityValue)

            return viewModel
        }

        if !viewModels.isEmpty {
            let filteredIds = filterModel.facilityIds.filter { viewModels.map { $0.id }.contains($0) }
            let value = filteredIds.count == viewModels.count && !filterModel.facilityIds.isEmpty
            let facilityValue = BehaviorRelay(value: value)
            facilityValue
                .bind(onNext: updateAllFacilities(value:))
                .disposed(by: disposeBag)

            let allFacilitiesViewModel = CreateListingFacilityViewModel(
                title: L10n.Filters.allFacilities,
                image: Asset.CreateListing.allFacilitiesIcon.image,
                value: facilityValue
            )
            viewModels.insert(allFacilitiesViewModel, at: 0)
        }

        facilitiesViewModels.accept(viewModels)
    }

}
