//
//  ListingStatisticsView.swift
//  Babilonia
//
//  Created by Alya Filon  on 12.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class ListingStatisticsView: NiblessView {

    private let contentView: UIView = .init()
    private let stackView: UIStackView = .init()
    private let viewsCountLabel: UILabel = .init()
    private let likesCountLabel: UILabel = .init()
    private let contactsCountLabel: UILabel = .init()
    private let viewsImageView: UIImageView = .init()
    private let likesImageView: UIImageView = .init()
    private let contactsImageView: UIImageView = .init()

    override init() {
        super.init()

        setupView()
    }

    func applyStatistics(_ value: ListingStatisticsValue) {
        viewsCountLabel.text = "\(value.views)"
        likesCountLabel.text = "\(value.likes)"
        contactsCountLabel.text = "\(value.contacts)"

        viewsImageView.image = value.views == 0 ?
            Asset.MyListings.statViewsIcon.image.withRenderingMode(.alwaysTemplate) :
            Asset.MyListings.statViewsIcon.image

        likesImageView.image = value.likes == 0 ?
            Asset.MyListings.statLikesCount.image.withRenderingMode(.alwaysTemplate) :
            Asset.MyListings.statLikesCount.image

        contactsImageView.image = value.contacts == 0 ?
            Asset.MyListings.statContactsIcon.image.withRenderingMode(.alwaysTemplate) :
            Asset.MyListings.statContactsIcon.image
    }
}

extension ListingStatisticsView {

    private func setupView() {
        contentView.backgroundColor = Asset.Colors.antiFlashWhite.color
        contentView.layerCornerRadius = 12

        addSubview(contentView)
        contentView.layout {
            $0.top.equal(to: topAnchor)
            $0.leading.equal(to: leadingAnchor, offsetBy: 8)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -8)
            $0.bottom.equal(to: bottomAnchor, offsetBy: -8)
            $0.height.equal(to: 64)
        }

        stackView.axis = .horizontal
        contentView.addSubview(stackView)
        stackView.pinEdges(to: contentView)

        setupStackViewContent()
    }

    private func setupStackViewContent() {
        viewsImageView.image = Asset.MyListings.statViewsIcon.image
        let viewsView = statisticCompenent(imageView: viewsImageView,
                                           countLabel: viewsCountLabel,
                                           title: L10n.MyListings.Statistics.views)

        stackView.addArrangedSubview(viewsView)
        stackView.addArrangedSubview(dotView())

        likesImageView.image = Asset.MyListings.statLikesCount.image
        let likesView = statisticCompenent(imageView: likesImageView,
                                           countLabel: likesCountLabel,
                                           title: L10n.MyListings.Statistics.favorites)

        stackView.addArrangedSubview(likesView)
        stackView.addArrangedSubview(dotView())

        contactsImageView.image = Asset.MyListings.statContactsIcon.image
        let contactsView = statisticCompenent(imageView: contactsImageView,
                                              countLabel: contactsCountLabel,
                                              title: L10n.MyListings.Statistics.contacts)

        stackView.addArrangedSubview(contactsView)
    }

    private func statisticCompenent(imageView: UIImageView, countLabel: UILabel, title: String) -> UIView {
        let view = UIView()

        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Asset.Colors.bluishGrey.color
        view.addSubview(imageView)
        imageView.layout {
            $0.width.equal(to: 20)
            $0.height.equal(to: 20)
            $0.leading.equal(to: view.leadingAnchor, offsetBy: 19)
            $0.top.equal(to: view.topAnchor, offsetBy: 19)
        }

        countLabel.text = "0"
        countLabel.textColor = Asset.Colors.almostBlack.color
        countLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 20)
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.minimumScaleFactor = 0.5

        view.addSubview(countLabel)
        countLabel.layout {
            $0.leading.equal(to: imageView.trailingAnchor, offsetBy: 10)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.top.equal(to: view.topAnchor, offsetBy: 13)
        }

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = Asset.Colors.bluishGrey.color
        titleLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 12)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5

        view.addSubview(titleLabel)
        titleLabel.layout {
            $0.leading.equal(to: imageView.trailingAnchor, offsetBy: 10)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.top.equal(to: countLabel.bottomAnchor, offsetBy: 1)
        }

        let dotViewWidth: CGFloat = 6
        let viewWidth = (UIConstants.screenWidth - 16 - dotViewWidth * 2) / 3
        view.layout {
            $0.width.equal(to: viewWidth)
        }

        return view
    }

    private func dotView() -> UIView {
        let view = UIView()

        let dotView = UIView()
        dotView.backgroundColor = Asset.Colors.cloudyBlue.color
        dotView.layerCornerRadius = 3

        view.addSubview(dotView)
        dotView.layout {
            $0.height.equal(to: 6)
            $0.width.equal(to: 6)
            $0.centerX.equal(to: view.centerXAnchor)
            $0.centerY.equal(to: view.centerYAnchor)
        }

        return view
    }

}
