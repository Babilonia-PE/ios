//
//  FiltersHistogramView.swift
//  Babilonia
//
//  Created by Alya Filon  on 02.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import MultiSlider
import RxSwift
import RxCocoa

final class FiltersHistogramView: NiblessView {

    private let titleLabel: UILabel = .init()
    private let rangeLabel: UILabel = .init()
    private let histogramView: HistogramView = .init()
    private let slider: MultiSlider = .init()

    private let bag = DisposeBag()

    var viewModel: HistogramViewModel! {
        didSet {
            setupBinding()
        }
    }

    override init() {
        super.init()

        setupView()
    }

    func setupHistogram(with values: [HistogramValue]) {
        histogramView.setup(with: values)
    }

}

extension FiltersHistogramView {

    private func setupBinding() {
        viewModel.sliderViewModel.customizeSlider(slider)
        viewModel.maxPrice
            .subscribe(onNext: { [weak self] value in
                self?.rangeLabel.text = "$0 - $\(value)"
            })
            .disposed(by: bag)

        viewModel.sliderValue
            .subscribe(onNext: { [weak self] value in
                let minValue = value.min
                let maxValue = value.max
                self?.histogramView.updateHistogramSlots(min: minValue, max: maxValue)
                self?.calculateRangeLabel(min: minValue, max: maxValue)
                self?.viewModel.sliderViewModel.setValue([minValue, maxValue].map { CGFloat($0) })
            })
            .disposed(by: bag)
    }

    private func setupView() {
        titleLabel.text = L10n.Filters.priceRange.uppercased()
        titleLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12)
        titleLabel.textColor = Asset.Colors.bluishGrey.color

        addSubview(titleLabel)
        titleLabel.layout {
            $0.top.equal(to: topAnchor, offsetBy: 24)
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
        }

        rangeLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 16)
        rangeLabel.textColor = Asset.Colors.almostBlack.color

        addSubview(rangeLabel)
        rangeLabel.layout {
            $0.bottom.equal(to: titleLabel.bottomAnchor)
            $0.leading.equal(to: titleLabel.trailingAnchor, offsetBy: 17)
        }

        addSubview(histogramView)
        histogramView.layout {
            $0.top.equal(to: titleLabel.bottomAnchor, offsetBy: 24)
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.height.equal(to: 61)
        }

        addSubview(slider)
        slider.layout {
            $0.bottom.equal(to: histogramView.bottomAnchor, offsetBy: 25)
            $0.leading.equal(to: leadingAnchor, offsetBy: 15)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -15)
            $0.height.equal(to: 28)
        }
    }

    private func calculateRangeLabel(min: Int, max: Int) {
        let maxPrice = viewModel.maxPrice.value
        let step = viewModel.priceStep

        let maxValue = max == 101 ? maxPrice : step * max
        let minPriceValue = String(step * min).shortPriceConverting()
        let maxPriceValue = String(maxValue).shortPriceConverting()
        rangeLabel.text = "$\(minPriceValue) - $\(maxPriceValue)"
    }

}

typealias HistogramValue = (index: Int, count: Int)

final class HistogramView: NiblessView {

    private let contentView: UIView = .init()
    private var views = [UIView]()

    private var values = [HistogramValue]()

    private let selectedColor = Asset.Colors.rosa.color
    private let deselectedColor = Asset.Colors.veryLightBlueTwo.color

    override init() {
        super.init()

        setupView()
    }

    func setup(with values: [HistogramValue]) {
        self.values = values
        drawHistogram()
    }

    func updateHistogramSlots(min: Int, max: Int) {
        for (index, view) in views.enumerated() {
            let isDeselected = index < min || index > max
            view.backgroundColor = isDeselected ? deselectedColor : selectedColor
        }
    }

}

extension HistogramView {

    private func setupView() {
        addSubview(contentView)
        contentView.pinEdges(to: self)
    }

    private func drawHistogram() {
        clearHistogram()

        let max = values.map { $0.count }.max() ?? 1
        let maxValue = CGFloat(max == 0 ? 1 : max)

        let totalHeight: CGFloat = 61
        let totalWidth = UIConstants.screenWidth - 32
        let width: CGFloat = totalWidth / CGFloat(values.count)
        let stepHeight = totalHeight / maxValue

        var offsetX: CGFloat = 0
        for (index, value) in values.enumerated() {
            let view = UIView()
            view.backgroundColor = Asset.Colors.rosa.color

            let height = stepHeight * CGFloat(value.count)
            let offsetY = totalHeight - height
            offsetX = CGFloat(index) * width

            views.append(view)
            contentView.addSubview(view)
            view.frame = CGRect(x: offsetX,
                                y: offsetY,
                                width: width,
                                height: height)
        }
    }

    private func clearHistogram() {
        views.forEach { $0.removeFromSuperview() }
        views.removeAll()
    }

}
