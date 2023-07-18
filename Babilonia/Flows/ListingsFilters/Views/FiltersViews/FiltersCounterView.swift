//
//  FiltersCounterView.swift
//  Babilonia
//
//  Created by Alya Filon  on 01.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class FiltersCounterView: NiblessView {

    private let stackView: UIStackView = .init()
    private var filterViewTypes = [FilterViewType]()

    var countersHeightUpdated: ((CGFloat) -> Void)?

    override init() {
        super.init()

        setupView()
    }

    func updateCounters(with viewModels: [NumberFieldViewModel]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for viewModel in viewModels {
            let fieldView = NumberFieldView(viewModel: viewModel)
            stackView.addArrangedSubview(fieldView)
            fieldView.layout {
                $0.height.equal(to: 40)
            }
        }

        let totalHeight = CGFloat(32 + 40 * viewModels.count) + CGFloat(32 * (viewModels.count - 1))
        countersHeightUpdated?(totalHeight)
    }

    func clearView() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        filterViewTypes.removeAll()
    }

}

extension FiltersCounterView {

    private func setupView() {
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 32

        addSubview(stackView)
        stackView.layout {
            $0.top.equal(to: topAnchor, offsetBy: 32)
            $0.bottom.equal(to: bottomAnchor)
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -24)
        }
    }

}
