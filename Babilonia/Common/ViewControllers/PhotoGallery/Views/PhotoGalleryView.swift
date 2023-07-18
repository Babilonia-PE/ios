//
//  PhotoGalleryView.swift
//  Babilonia
//
//  Created by Alya Filon  on 12.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class PhotoGalleryView: NiblessView {

    let backButton: UIButton = .init()
    let photoCountLabel: UILabel = .init()
    var collectionView: UICollectionView!
    private let titleLabel: UILabel = .init()

    override init() {
        super.init()

        setupView()
    }

}

extension PhotoGalleryView {

    private func setupView() {
        backgroundColor = .white

        backButton.setImage(Asset.Common.backIcon.image.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.tintColor = Asset.Colors.almostBlack.color
        backButton.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 12.0, bottom: 10.0, right: 12.0)

        addSubview(backButton)
        backButton.layout {
            $0.top.equal(to: safeAreaLayoutGuide.topAnchor)
            $0.leading.equal(to: leadingAnchor)
        }

        titleLabel.text = L10n.PhotoGallery.title
        titleLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 16)
        titleLabel.textColor = Asset.Colors.almostBlack.color
        titleLabel.textAlignment = .center

        addSubview(titleLabel)
        titleLabel.layout {
            $0.top.equal(to: safeAreaLayoutGuide.topAnchor, offsetBy: 12)
            $0.leading.equal(to: leadingAnchor, offsetBy: 35)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -35)
        }

        photoCountLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 16)
        photoCountLabel.textColor = Asset.Colors.almostBlack.color
        photoCountLabel.textAlignment = .center

        addSubview(photoCountLabel)
        photoCountLabel.layout {
            $0.top.equal(to: titleLabel.bottomAnchor, offsetBy: 8)
            $0.leading.equal(to: leadingAnchor, offsetBy: 20)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -20)
        }

        setupCollectionView()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()

        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.registerReusableCell(cellType: PhotoGalleryCell.self)

        addSubview(collectionView)
        collectionView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.top.equal(to: photoCountLabel.bottomAnchor, offsetBy: 18)
            $0.bottom.equal(to: safeAreaLayoutGuide.bottomAnchor)
        }
    }

}
