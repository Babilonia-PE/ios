//
//  CreateListingAdvancedView.swift
//  Babilonia
//
//  Created by Alya Filon  on 22.12.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class CreateListingAdvancedView: NiblessView {

    let titleLabel: UILabel = .init()
    let emptyStateLabel: UILabel = .init()
    private let scrollView: UIScrollView = .init()
    private var detailsViews = [CreateListingFacilityView]()

    override init() {
        super.init()

        setupView()
    }

    func layoutDetails(with viewModels: [CreateListingFacilityViewModel]) {
        titleLabel.removeFromSuperview()
        scrollView.addSubview(titleLabel)
        titleLabel.layout {
            $0.top.equal(to: scrollView.topAnchor, offsetBy: 8.0)
            $0.leading.equal(to: scrollView.leadingAnchor, offsetBy: 16.0)
            $0.trailing.equal(to: scrollView.trailingAnchor, offsetBy: -16.0)
            $0.height >= 24.0
        }

        var lastView: UIView = titleLabel

        detailsViews.forEach { $0.removeFromSuperview() }
        detailsViews = [CreateListingFacilityView]()
        viewModels.forEach {
            let detailView = CreateListingFacilityView(viewModel: $0)
            scrollView.addSubview(detailView)
            detailView.layout {
                $0.top.equal(to: lastView.bottomAnchor)
                $0.leading.equal(to: scrollView.leadingAnchor)
                $0.trailing.equal(to: scrollView.trailingAnchor)
            }

            detailsViews.append(detailView)
            lastView = detailView
        }

        lastView.layout {
            $0.bottom == scrollView.bottomAnchor - 28.0
        }
    }

}

extension CreateListingAdvancedView {

    private func setupView() {
        titleLabel.text = L10n.ListingDetails.Advanced.title.uppercased()
        titleLabel.textColor = Asset.Colors.bluishGrey.color
        titleLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12)

        addSubview(titleLabel)
        titleLabel.layout {
            $0.top.equal(to: safeAreaLayoutGuide.topAnchor, offsetBy: 12)
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
        }

        addSubview(scrollView)
        scrollView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
        }

        let scrollViewWidthView = UIView()
        scrollView.addSubview(scrollViewWidthView)
        scrollViewWidthView.layout {
            $0.leading.equal(to: scrollView.leadingAnchor)
            $0.trailing.equal(to: scrollView.trailingAnchor)
            $0.top.equal(to: scrollView.topAnchor)
            $0.height.equal(to: 1.0)
            $0.width.equal(to: scrollView.widthAnchor)
        }

        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textAlignment = .center
        
        addSubview(emptyStateLabel)
        emptyStateLabel.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 62.0)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -62.0)
            $0.centerY.equal(to: centerYAnchor, offsetBy: -15.0)
        }
    }

}
