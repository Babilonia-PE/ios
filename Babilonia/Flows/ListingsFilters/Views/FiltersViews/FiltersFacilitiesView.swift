//
//  FiltersFacilitiesView.swift
//  Babilonia
//
//  Created by Alya Filon  on 02.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class FiltersFacilitiesView: NiblessView {

    private let stackView: UIStackView = .init()
    private let titleLabel: UILabel = .init()

    var facilityViews = [CreateListingFacilityView]()
    var facilitiesHeightUpdated: ((CGFloat) -> Void)?
    
    override init() {
        super.init()

        setupView()
    }

    func updateFacilities(with viewModels: [CreateListingFacilityViewModel]) {
        clearView()

        if viewModels.isEmpty {
            facilitiesHeightUpdated?(0)

            return
        }

        for viewModel in viewModels {
            let facilityView = CreateListingFacilityView(viewModel: viewModel)
            facilityViews.append(facilityView)
            stackView.addArrangedSubview(facilityView)
            facilityView.layout {
                $0.height.equal(to: 56)
            }
        }

        let totalHeight = CGFloat(48 + 56 * viewModels.count)
        facilitiesHeightUpdated?(totalHeight)
    }

    func clearView() {
        facilityViews.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

}

extension FiltersFacilitiesView {

    private func setupView() {
        titleLabel.text = L10n.Filters.propertyFacilities.uppercased()
        titleLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12)
        titleLabel.textColor = Asset.Colors.bluishGrey.color

        addSubview(titleLabel)
        titleLabel.layout {
            $0.top.equal(to: topAnchor, offsetBy: 24)
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
        }

        stackView.axis = .vertical
        stackView.distribution = .fillEqually

        addSubview(stackView)
        stackView.layout {
            $0.top.equal(to: titleLabel.bottomAnchor, offsetBy: 8)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.bottom.equal(to: bottomAnchor)
        }
    }

}
