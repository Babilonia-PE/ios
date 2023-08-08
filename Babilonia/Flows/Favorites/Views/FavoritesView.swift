//
//  FavoritesView.swift
//  Babilonia
//
//  Created by Alya Filon  on 23.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class FavoritesView: NiblessView {

    var tableView: UITableView = .init()

    private var favoritesLabel: UILabel = .init()
    private var emptyView: UIView = .init()
    private let emptyIconImageView: UIImageView = .init()
    private let emptyTitleLabel: UILabel = .init()
    private let emptyDescriptionLabel: UILabel = .init()

    override init() {
        super.init()

        setupView()
    }

    func setupView(isEmpty: Bool) {
        tableView.isHidden = isEmpty
        emptyView.isHidden = !isEmpty
    }

}

extension FavoritesView {

    private func setupView() {
        backgroundColor = .white

        favoritesLabel.text = L10n.FavoritesListings.title
        favoritesLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 26)
        favoritesLabel.textColor = Asset.Colors.almostBlack.color

        addSubview(favoritesLabel)
        favoritesLabel.layout {
            $0.top.equal(to: safeAreaLayoutGuide.topAnchor, offsetBy: 27)
            $0.leading.equal(to: leadingAnchor, offsetBy: 14)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -14)
        }

        setupEmptyView()
        setupTableView()
    }

    private func setupEmptyView() {
        addSubview(emptyView)
        emptyView.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 39)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -39)
            $0.centerY.equal(to: centerYAnchor)
        }

        emptyIconImageView.image = Asset.MyListings.favoritesEmpty.image
        emptyIconImageView.contentMode = .scaleAspectFit

        emptyView.addSubview(emptyIconImageView)
        emptyIconImageView.layout {
            $0.top.equal(to: emptyView.topAnchor)
            $0.height.equal(to: 64)
            $0.width.equal(to: 64)
            $0.centerX.equal(to: emptyView.centerXAnchor)
        }

        emptyTitleLabel.text = L10n.FavoritesListings.Empty.title
        emptyTitleLabel.textColor = Asset.Colors.almostBlack.color
        emptyTitleLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 16)
        emptyTitleLabel.textAlignment = .center
        emptyTitleLabel.numberOfLines = 0

        emptyView.addSubview(emptyTitleLabel)
        emptyTitleLabel.layout {
            $0.top.equal(to: emptyIconImageView.bottomAnchor, offsetBy: 14)
            $0.leading.equal(to: emptyView.leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: emptyView.trailingAnchor, offsetBy: -16)
        }

        let descriptionText = L10n.FavoritesListings.Empty.Description.first.toAttributedImaged(
            with: Asset.Common.favoritesIcon.image,
            secondPart: L10n.FavoritesListings.Empty.Description.second,
            font: FontFamily.AvenirLTStd._55Roman.font(size: 16),
            lineSpacing: 20,
            alignment: .center,
            color: .white,
            kern: 0
        )

        emptyDescriptionLabel.attributedText = descriptionText
        emptyDescriptionLabel.textColor = Asset.Colors.almostBlack.color
        emptyDescriptionLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 16)
        emptyDescriptionLabel.textAlignment = .center
        emptyDescriptionLabel.numberOfLines = 0

        emptyView.addSubview(emptyDescriptionLabel)
        emptyDescriptionLabel.layout {
            $0.top.equal(to: emptyTitleLabel.bottomAnchor, offsetBy: 18)
            $0.leading.equal(to: emptyView.leadingAnchor)
            $0.trailing.equal(to: emptyView.trailingAnchor)
            $0.bottom.equal(to: emptyView.bottomAnchor)
        }
    }

    private func setupTableView() {
        tableView.registerReusableCell(cellType: ListingTableViewCell.self)
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.isHidden = true
        tableView.rowHeight = 272.0

        addSubview(tableView)
        tableView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.top.equal(to: favoritesLabel.bottomAnchor, offsetBy: 17)
            $0.bottom.equal(to: bottomAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
    }

}
