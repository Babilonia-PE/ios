//
//  FiltersSliderRangeView.swift
//  Babilonia
//
//  Created by Alya Filon  on 29.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MultiSlider

final class FiltersSliderRangeView: NiblessView {

    let titleLabel: UILabel = .init()
    let slider: MultiSlider = .init()
    var minimumInputFieldView: InputFieldView!
    var maximumInputFieldView: InputFieldView!

    var viewModel: SliderRangeViewModel! {
        didSet {
            setupBinding()
        }
    }

    override init() {
        super.init()

        setupView()
    }

}

// MARK: - Private Methods

extension FiltersSliderRangeView {

    private func setupBinding() {
        viewModel.sliderViewModel.customizeSlider(slider)
        viewModel.sliderViewModel.snapStepSize = 10
        titleLabel.text = viewModel.title.uppercased()
        setupRanges(with: (min: viewModel.minFieldViewModel, max: viewModel.maxFieldViewModel))
    }

    private func setupView() {
        titleLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12)
        titleLabel.textColor = Asset.Colors.bluishGrey.color

        addSubview(titleLabel)
        titleLabel.layout {
            $0.top.equal(to: topAnchor, offsetBy: 24)
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.height.equal(to: 21)
        }

        addSubview(slider)
        slider.layout {
            $0.top.equal(to: titleLabel.bottomAnchor, offsetBy: 9)
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.height.equal(to: 48)
        }
    }

    private func setupRanges(with viewModels: (min: InputFieldViewModel, max: InputFieldViewModel)) {
        minimumInputFieldView = InputFieldView(viewModel: viewModels.min)
        addSubview(minimumInputFieldView)
        minimumInputFieldView.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.top.equal(to: slider.bottomAnchor, offsetBy: 16)
            $0.height.equal(to: 56)
        }

        let dashView = UIView()
        dashView.backgroundColor = Asset.Colors.cloudyBlue.color

        addSubview(dashView)
        dashView.layout {
            $0.leading.equal(to: minimumInputFieldView.trailingAnchor, offsetBy: 30)
            $0.centerY.equal(to: minimumInputFieldView.centerYAnchor)
            $0.height.equal(to: 1)
            $0.width.equal(to: 12)
        }

        maximumInputFieldView = InputFieldView(viewModel: viewModels.max)
        addSubview(maximumInputFieldView)
        maximumInputFieldView.layout {
            $0.leading.equal(to: dashView.trailingAnchor, offsetBy: 29)
            $0.top.equal(to: minimumInputFieldView.topAnchor)
            $0.height.equal(to: 56)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.width.equal(to: minimumInputFieldView.widthAnchor)
        }
    }

}
