//
//  PaymentsProfileView.swift
//  Babilonia
//
//  Created by Alya Filon  on 27.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class PaymentsProfileView: NiblessView {

    let selectProfileButton: ConfirmationButton = .init()
    var collectionView: UICollectionView!
    let linkButton: UIButton = .init()
    private let titleLabel: UILabel = .init()
    private let descriptionLabel: UILabel = .init()

    override init() {
        super.init()

        setupView()
    }

}

extension PaymentsProfileView {

    private func setupView() {
        backgroundColor = .white

        titleLabel.text = L10n.Payments.ProfileSelection.description
        titleLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 14)
        titleLabel.textColor = Asset.Colors.gunmetal.color
        titleLabel.textAlignment = .center

        addSubview(titleLabel)
        titleLabel.layout {
            $0.top.equal(to: topAnchor, offsetBy: 8)
            $0.leading.equal(to: leadingAnchor, offsetBy: 38)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -38)
        }

        setupCollectionView()

        selectProfileButton.setTitle(L10n.Payments.ProfileSelection.button.uppercased(), for: .normal)
        selectProfileButton.setTitleColor(.white, for: .normal)
        selectProfileButton.titleLabel?.font = FontFamily.SamsungSharpSans.bold.font(size: 16)

        addSubview(selectProfileButton)
        selectProfileButton.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.bottom.equal(to: safeAreaLayoutGuide.bottomAnchor, offsetBy: -24)
            $0.height.equal(to: 56)
        }

        let attributedText = L10n.Payments.Profile.description
            .toAttributedLinkPart(with: FontFamily.AvenirLTStd._55Roman.font(size: 14),
                                  color: Asset.Colors.gunmetal.color,
                                  lineSpacing: 8,
                                  stringPart: L10n.Payments.Profile.descriptionLink)
        descriptionLabel.attributedText = attributedText
        descriptionLabel.numberOfLines = 0

        addSubview(descriptionLabel)
        descriptionLabel.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.bottom.equal(to: selectProfileButton.topAnchor, offsetBy: -40)
        }

        addSubview(linkButton)
        linkButton.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.bottom.equal(to: selectProfileButton.topAnchor, offsetBy: -40)
            $0.height.equal(to: 25)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -40)
        }
    }

    private func setupCollectionView() {
        let spacing: CGFloat = 20
        let width = (UIConstants.screenWidth - 49 - spacing * 2) / 3
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.itemSize = CGSize(width: width, height: width + 50)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.bounces = false
        collectionView.isScrollEnabled = false
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .clear

        collectionView.registerReusableCell(cellType: PaymentsProfileTypeCell.self)

        addSubview(collectionView)
        collectionView.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 24)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -24)
            $0.top.equal(to: titleLabel.bottomAnchor, offsetBy: 32)
            $0.bottom.equal(to: bottomAnchor)
        }
    }

}
