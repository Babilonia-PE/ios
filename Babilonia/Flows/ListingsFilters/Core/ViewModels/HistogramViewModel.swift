//
//  HistogramViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 07.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import MultiSlider
import RxSwift
import RxCocoa

final class HistogramViewModel {

    var maxPrice = BehaviorRelay<Int>(value: 0)
    var priceStep: Int = 10000
    var sliderValue: Observable<RangeValue> {
        sliderViewModel.sliderValue.asObservable()
    }
    var sliderViewModel: SliderViewModel!

    private let sliderMaximumValue = BehaviorRelay<CGFloat>(value: 101)
    private let bag = DisposeBag()
    private var listingType: ListingType = .sale
    private let prices = FilterPriceConverter()

    init(sliderValue: BehaviorRelay<RangeValue>) {
        sliderViewModel = SliderViewModel(maximumValue: sliderMaximumValue,
                                          snapStepSize: 1,
                                          value: sliderValue)
    }

    func resetViewModel(to listingType: ListingType?) {
        if let ltype = listingType {
            self.listingType = ltype
            let maxPrice = prices.maxPrice(for: ltype)
            let priceStep = prices.slotPrice(for: ltype)
            let sliderMaxValue = 101

            self.maxPrice.accept(maxPrice)
            self.priceStep = priceStep
            sliderViewModel.sliderValue.accept((min: 0, max: sliderMaxValue))
            sliderViewModel.reset(with: CGFloat(sliderMaxValue))
        }
    }

    func convertPrice(for values: RangeValue) -> (min: Int?, max: Int?) {
        prices.convertPrice(for: listingType, values: values)
    }

    func presetPrices(to listingType: ListingType, priceStart: Int?, priceEnd: Int?) {
        let start = priceStart ?? 0
        let end = priceEnd ?? prices.maxPrice(for: listingType)
        let range = prices.convertValue(for: listingType, prices: (min: start, max: end))
        sliderViewModel.sliderValue.accept(range)
    }

}

struct FilterPriceConverter {

    private let saleMaxPrice = 1000000
    private let rentMaxPrice = 10000
    private let saleSlotPrice = 10000
    private let rentSlotPrice = 100

    func maxPrice(for listingType: ListingType) -> Int {
        listingType == .sale ? saleMaxPrice : rentMaxPrice
    }

    func slotPrice(for listingType: ListingType) -> Int {
        listingType == .sale ? saleSlotPrice : rentSlotPrice
    }

    func convertPrice(for listingType: ListingType?,
                      values: RangeValue) -> (min: Int?, max: Int?) {
        if let ltype = listingType {
            let slotPrice = self.slotPrice(for: ltype)
            let minValue = values.min == 0 ? nil : slotPrice * values.min
            let maxValue = values.max == 101 ? nil : slotPrice * values.max

            return (min: minValue, max: maxValue)
        } else {
            return (min: 0, max: 0)
        }
    }

    func convertValue(for listingType: ListingType,
                      prices: (min: Int?, max: Int?)) -> RangeValue {
        let slotPrice = self.slotPrice(for: listingType)
        let minValue = prices.min == nil ? 0 : prices.min! / slotPrice
        let maxValue = prices.max == nil ? 101 : prices.max! / slotPrice

        return (min: minValue, max: maxValue)
    }

}
