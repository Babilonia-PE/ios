//
//  SliderViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 07.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import MultiSlider
import RxSwift
import RxCocoa

final class SliderViewModel {

    let minimumValue: CGFloat
    let maximumValue: BehaviorRelay<CGFloat>
    let sliderValue: BehaviorRelay<RangeValue>

    var snapStepSize: CGFloat {
        didSet {
            slider?.snapStepSize = snapStepSize
        }
    }

    private var slider: MultiSlider!
    private let bag = DisposeBag()

    init(minimumValue: CGFloat = 0,
         maximumValue: BehaviorRelay<CGFloat>,
         snapStepSize: CGFloat = 10,
         value: BehaviorRelay<RangeValue>) {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.snapStepSize = snapStepSize
        self.sliderValue = value
    }

    func customizeSlider(_ slider: MultiSlider) {
        self.slider = slider
        initialSetup()

        slider.orientation = .horizontal
        slider.outerTrackColor = Asset.Colors.veryLightBlueTwo.color
        slider.tintColor = Asset.Colors.watermelon.color
        slider.trackWidth = 4
        slider.hasRoundTrackEnds = true
        slider.thumbImage = Asset.Common.sliderIndicator.image

        slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        setupBinding()
    }

    func setValue(_ value: [CGFloat]) {
        slider?.value = value
    }

    func reset(with maxValue: CGFloat) {
        slider?.value = [0, maxValue]
    }

}

extension SliderViewModel {

    @objc
    private func sliderChanged(_ slider: MultiSlider) {
        guard slider.value.count == 2 else { return }

        let minValue = Int(ceil(slider.value[0]))
        var maxValue = Int(ceil(slider.value[1]))

        if Int(maximumValue.value) - maxValue < Int(snapStepSize) {
            maxValue = Int(maximumValue.value)
        }

        sliderValue.accept((min: minValue, max: maxValue))
    }

    private func initialSetup() {
        slider.minimumValue = minimumValue
        slider.maximumValue = maximumValue.value
        slider.snapStepSize = snapStepSize
        slider.value = [minimumValue, maximumValue.value]
    }

    private func setupBinding() {
        maximumValue
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }

                self.slider.maximumValue = value
                self.slider.value = [self.minimumValue, value]
            })
            .disposed(by: bag)
    }

}
