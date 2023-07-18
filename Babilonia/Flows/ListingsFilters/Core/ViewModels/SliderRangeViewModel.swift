//
//  SliderRangeViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 07.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import RxSwift
import RxCocoa

final class SliderRangeViewModel {

    let minTextValue = BehaviorRelay<String>(value: "0")
    let maxTextValue = BehaviorRelay<String>(value: "0")
    let sliderValue = BehaviorRelay<RangeValue>(value: (min: 0, max: 0))
    var presetRanges: RangeValue? {
        didSet {
            guard let ranges = presetRanges else { return }
            rangeValueChanged.accept((min: ranges.min, max: ranges.max))
        }
    }

    lazy var minFieldViewModel: InputFieldViewModel = {
        let viewModel = InputFieldViewModel(title: BehaviorRelay(value: L10n.Filters.Range.min),
                                            text: minTextValue,
                                            validator: nil,
                                            editingMode: .text,
                                            image: nil,
                                            placeholder: nil,
                                            keyboardType: .numberPad,
                                            autocorrectionType: .no)

        return viewModel
    }()
    lazy var maxFieldViewModel: InputFieldViewModel = {
        let viewModel = InputFieldViewModel(title: BehaviorRelay(value: L10n.Filters.Range.max),
                                            text: maxTextValue,
                                            validator: nil,
                                            editingMode: .text,
                                            image: nil,
                                            placeholder: nil,
                                            keyboardType: .numberPad,
                                            autocorrectionType: .no)

        return viewModel
    }()

    let title: String
    let sliderViewModel: SliderViewModel

    private let rangeValueChanged: BehaviorRelay<RangeValue>
    private let sliderMaximumValue: BehaviorRelay<CGFloat>
    private let bag = DisposeBag()
    private var minValueConvertered: Int? {
        Int(minTextValue.value.clearCommaConverting())
    }

    init(title: String,
         sliderMaximumValue: BehaviorRelay<CGFloat>,
         rangeValueChanged: BehaviorRelay<RangeValue>) {
        self.title = title
        self.sliderMaximumValue = sliderMaximumValue
        self.rangeValueChanged = rangeValueChanged

        sliderViewModel = SliderViewModel(maximumValue: sliderMaximumValue,
                                          snapStepSize: 10,
                                          value: sliderValue)
        setupBinding()
    }

    func setEnablingFilelds(isEnabled: Bool) {
        minFieldViewModel.textFieldEnabled.onNext(isEnabled)
        maxFieldViewModel.textFieldEnabled.onNext(isEnabled)
    }

}

// MARK: - Private Methods

extension SliderRangeViewModel {

    private func setupBinding() {
        sliderMaximumValue
            .distinctUntilChanged()
            .map { "\(Int($0))".commaConverted() }
            .subscribe(onNext: { [weak self] value in
                self?.maxTextValue.accept(value)
            })
            .disposed(by: bag)

        sliderViewModel.sliderValue
            .skip(1)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] value in
                self?.minTextValue.accept("\(value.min)".commaConverted())
                self?.maxTextValue.accept("\(value.max)".commaConverted())
                self?.rangeValueChanged.accept(value)
            })
            .disposed(by: bag)

        minTextValue
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] value in
                guard let self = self, let minValue = Int(value),
                    let maxValue = Int(self.maxTextValue.value.clearCommaConverting()) else { return }

                self.rangeValueChanged.accept((min: minValue, max: maxValue))
                self.sliderViewModel.setValue(self.validateSliderRanges(for: .min,
                                                                        minValue: CGFloat(minValue),
                                                                        maxValue: CGFloat(maxValue)))
            })
            .disposed(by: bag)

        maxTextValue
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] value in
                guard let self = self, let maxValue = Int(value),
                    let minValue = Int(self.minTextValue.value.clearCommaConverting()) else { return }

                self.rangeValueChanged.accept((min: minValue, max: maxValue))
                self.sliderViewModel.setValue(self.validateSliderRanges(for: .max,
                                                                        minValue: CGFloat(minValue),
                                                                        maxValue: CGFloat(maxValue)))
            })
            .disposed(by: bag)

        setupEditingFlowBinding()
    }

    private func setupEditingFlowBinding() {
        minFieldViewModel.editingDidEnd
            .subscribe(onNext: { [weak self] in
                self?.validateRangeField(for: .min)
                self?.validateEmptyFields(for: .min)
            })
            .disposed(by: bag)

        maxFieldViewModel.editingDidEnd
            .subscribe(onNext: { [weak self] in
                self?.validateRangeField(for: .max)
                self?.validateEmptyFields(for: .max)
            })
            .disposed(by: bag)

        minFieldViewModel.editingDidBegin
            .subscribe(onNext: { [weak self] in
                guard var value = self?.minTextValue.value else { return }
                if value == "0" { value = "" }
                self?.minTextValue.accept(value.clearCommaConverting())
            })
            .disposed(by: bag)

        maxFieldViewModel.editingDidBegin
            .subscribe(onNext: { [weak self] in
                guard var value = self?.maxTextValue.value else { return }
                if value == "0" { value = "" }
                self?.maxTextValue.accept(value.clearCommaConverting())
            })
            .disposed(by: bag)
    }

    private func validateSliderRanges(for bound: RangeBound, minValue: CGFloat, maxValue: CGFloat) -> [CGFloat] {
        let isValid = minValue <= maxValue
        switch bound {
        case .min:
            return isValid ? [minValue, maxValue] : [maxValue, maxValue]
        case .max:
            return isValid ? [minValue, maxValue] : [minValue, minValue]
        }
    }

    private func validateRangeField(for bound: RangeBound) {
        guard let minValue = Int(minTextValue.value.clearCommaConverting()),
            let maxValue = Int(maxTextValue.value.clearCommaConverting()) else { return }

        let isValid = minValue <= maxValue
        switch bound {
        case .min:
            let value = isValid ? minTextValue.value : "\(maxValue)"
            minTextValue.accept(value.commaConverted())
        case .max:
            let value = isValid ? maxTextValue.value : "\(minValue)"
            maxTextValue.accept(value.commaConverted())
        }
    }

    private func validateEmptyFields(for bound: RangeBound) {
        switch bound {
        case .min:
            if minTextValue.value.isEmpty { minTextValue.accept("0") }
        case .max:
            let maxValue = Int(sliderViewModel.maximumValue.value)
            if maxTextValue.value.isEmpty {
                guard let minValue = minValueConvertered else { return }

                maxTextValue.accept("\(maxValue)".commaConverted())
                rangeValueChanged.accept((min: minValue, max: maxValue))
                sliderViewModel.setValue([minValue, maxValue].map { CGFloat($0) })
            }
        }
    }

}
