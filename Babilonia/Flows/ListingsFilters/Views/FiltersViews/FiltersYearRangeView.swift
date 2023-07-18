//
//  FiltersYearRangeView.swift
//  Babilonia
//
//  Created by Alya Filon  on 01.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class FiltersYearRangeView: NiblessView {

    private let titleLabel: UILabel = .init()
    var fromInputFieldView: InputFieldView!
    var toInputFieldView: InputFieldView!

    var viewModel: YearRangeViewModel! {
        didSet {
            setupBinding()
        }
    }

    override init() {
        super.init()

        setupView()
    }

    func setupBinding() {
        setupRanges(with: (min: viewModel.fromFieldViewModel, max: viewModel.toFieldViewModel))
    }

}

extension FiltersYearRangeView {

    private func setupView() {
        titleLabel.text = L10n.CreateListing.Details.YearOfConstruction.title.uppercased()
        titleLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12)
        titleLabel.textColor = Asset.Colors.bluishGrey.color

        addSubview(titleLabel)
        titleLabel.layout {
            $0.top.equal(to: topAnchor, offsetBy: 24)
            $0.height.equal(to: 21)
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
        }
    }

    private func setupRanges(with viewModels: (min: InputFieldViewModel, max: InputFieldViewModel)) {
        fromInputFieldView = InputFieldView(viewModel: viewModels.min)
        addSubview(fromInputFieldView)
        fromInputFieldView.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.top.equal(to: titleLabel.bottomAnchor, offsetBy: 16)
            $0.height.equal(to: 56)
        }

        let dashView = UIView()
        dashView.backgroundColor = Asset.Colors.cloudyBlue.color

        addSubview(dashView)
        dashView.layout {
            $0.leading.equal(to: fromInputFieldView.trailingAnchor, offsetBy: 30)
            $0.centerY.equal(to: fromInputFieldView.centerYAnchor)
            $0.height.equal(to: 1)
            $0.width.equal(to: 12)
        }

        toInputFieldView = InputFieldView(viewModel: viewModels.max)
        addSubview(toInputFieldView)
        toInputFieldView.layout {
            $0.leading.equal(to: dashView.trailingAnchor, offsetBy: 29)
            $0.top.equal(to: fromInputFieldView.topAnchor)
            $0.height.equal(to: 56)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.width.equal(to: fromInputFieldView.widthAnchor)
        }
    }

}
