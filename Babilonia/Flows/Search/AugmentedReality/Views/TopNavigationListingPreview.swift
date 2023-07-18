//
//  TopNavigationListingPreview.swift
//  Babilonia
//
//  Created by Alya Filon  on 26.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TopNavigationListingPreview: NiblessView {

    private let photoImageView: UIImageView = .init()
    private let priceLabel: UILabel = .init()
    private let propertyTypeLabel: UILabel = .init()
    private let addressLabel: UILabel = .init()
    private let inlinePropertiesView: InlinePropertiesView = .init()

    private let disposeBag = DisposeBag()

    override init() {
        super.init()

        setupView()
    }

    func apply(_ listingViewModel: ListingViewModel) {
        propertyTypeLabel.text = listingViewModel.propertyType?.title
        inlinePropertiesView.setup(with: listingViewModel.inlinePropertiesInfo)
        addressLabel.text = listingViewModel.address

        if let image = listingViewModel.coverImage {
            photoImageView.setImage(with: image.photo.largeURLString.flatMap(URL.init))
        }

        listingViewModel.priceUpdated
            .drive(onNext: { [weak priceLabel] price in
                priceLabel?.text = price
            })
            .disposed(by: disposeBag)
    }
}

extension TopNavigationListingPreview {

    private func setupView() {
        backgroundColor = .white

        photoImageView.contentMode = .scaleAspectFill
        photoImageView.layerCornerRadius = 5
        photoImageView.clipsToBounds = true

        addSubview(photoImageView)
        photoImageView.layout {
            $0.height.equal(to: 80)
            $0.width.equal(to: 80)
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.bottom.equal(to: bottomAnchor, offsetBy: -16)
        }

        priceLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 20)
        priceLabel.textColor = Asset.Colors.almostBlack.color

        addSubview(priceLabel)
        priceLabel.layout {
            $0.leading.equal(to: photoImageView.trailingAnchor, offsetBy: 12)
            $0.top.equal(to: photoImageView.topAnchor)
        }

        propertyTypeLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 12)
        propertyTypeLabel.textColor = Asset.Colors.gunmetal.color

        addSubview(propertyTypeLabel)
        propertyTypeLabel.layout {
            $0.leading.equal(to: photoImageView.trailingAnchor, offsetBy: 12)
            $0.top.equal(to: priceLabel.bottomAnchor, offsetBy: 4)
        }

        addSubview(inlinePropertiesView)
        inlinePropertiesView.layout {
            $0.leading.equal(to: photoImageView.trailingAnchor, offsetBy: 12)
            $0.top.equal(to: propertyTypeLabel.bottomAnchor, offsetBy: 6)
        }

        addressLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12)
        addressLabel.textColor = Asset.Colors.gunmetal.color
        addSubview(addressLabel)
        addressLabel.layout {
            $0.leading.equal(to: photoImageView.trailingAnchor, offsetBy: 12)
            $0.top.equal(to: inlinePropertiesView.bottomAnchor, offsetBy: 6)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -10)
        }
    }

}
