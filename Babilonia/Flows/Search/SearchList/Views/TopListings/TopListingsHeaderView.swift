//
//  TopListingsHeaderView.swift
//  Babilonia
//
//  Created by Alya Filon  on 04.12.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class TopListingsHeaderView: NiblessView {

    var collectionView: UICollectionView!
    let sortView: SearchListingSortView = .init()
    private let titleLabel: UILabel = .init()

    override init() {
        super.init()

        setupView()
    }

}

extension TopListingsHeaderView {

    private func setupView() {
        backgroundColor = .white

        titleLabel.text = L10n.ListingSearch.topListingsTitle
        titleLabel.textColor = Asset.Colors.almostBlack.color
        titleLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 26)

        addSubview(titleLabel)
        titleLabel.layout {
            $0.top.equal(to: topAnchor, offsetBy: 23)
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
        }

        setupCollectionView()
    }

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.itemSize = CGSize(width: 200, height: 248)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.registerReusableCell(cellType: TopListingPreviewCell.self)
        collectionView.showsHorizontalScrollIndicator = false

        addSubview(collectionView)
        collectionView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor )
            $0.top.equal(to: titleLabel.bottomAnchor, offsetBy: 15)
        }

        addSubview(sortView)
        sortView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor )
            $0.top.equal(to: collectionView.bottomAnchor)
            $0.bottom.equal(to: bottomAnchor)
        }
    }

}
