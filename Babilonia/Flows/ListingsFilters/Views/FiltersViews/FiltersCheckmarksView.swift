//
//  FiltersCheckmarksView.swift
//  Babilonia
//
//  Created by Alya Filon  on 05.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class FiltersCheckmarksView: NiblessView {

    private let stackView: UIStackView = .init()

    var checkmarksHeightUpdated: ((CGFloat) -> Void)?

    override init() {
        super.init()

        setupView()
    }

    func updateCheckmarks(with viewModels: [CreateListingFacilityViewModel]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for viewModel in viewModels {
            let checkmarkView = CreateListingFacilityView(viewModel: viewModel)
            stackView.addArrangedSubview(checkmarkView)
            checkmarkView.layout {
                $0.height.equal(to: 56)
            }
        }

        let totalHeight = CGFloat(40 + 56 * viewModels.count)
        checkmarksHeightUpdated?(totalHeight)
    }

}

extension FiltersCheckmarksView {

    private func setupView() {
        stackView.axis = .vertical
        stackView.distribution = .fillEqually

        addSubview(stackView)
        stackView.layout {
            $0.top.equal(to: topAnchor, offsetBy: 32)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.bottom.equal(to: bottomAnchor, offsetBy: -8)
        }
    }

}
