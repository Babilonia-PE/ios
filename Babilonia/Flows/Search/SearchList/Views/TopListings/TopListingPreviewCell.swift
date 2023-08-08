//
//  TopListingPreviewCell.swift
//  Babilonia
//
//  Created by Alya Filon  on 04.12.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TopListingPreviewCell: UICollectionViewCell, Reusable {

    var didToggleFavorite: ((Bool) -> Void)?

    private let primaryImageView: UIImageView = .init()
    private let gradientImageView: UIImageView = .init()
    private let typeView: UIView = .init()
    private let typeIconImageView: UIImageView = .init()
    private let propertyTypeLabel: UILabel = .init()
    private let typeTitleLabel: UILabel = .init()
    private let addressLabel: UILabel = .init()
    private let priceLabel: UILabel = .init()
    private let pricePerSquareMeterLabel: UILabel = .init()
    private let inlinePropertiesView: InlinePropertiesView = .init()
    private let likeButton: UIButton = .init()
    private let planPlaceholderView: UIView = .init()
    private let planIconImageView: UIImageView = .init()

    private let disposeBag = DisposeBag()
    private var isSelectedLikeButton = false
    var isGuest = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(with viewModel: ListingPreviewViewModel) {
        let listingViewModel = viewModel.listingViewModel
        let listingTypeViewModel = viewModel.listingTypeViewModel

        if let imageUrl = URL(string: listingViewModel.coverImage?.photo.renderURLString ?? "") {
            primaryImageView.setImage(with: imageUrl, placeholder: Asset.MyListings.myListingsDraft.image)
        } else {
            primaryImageView.image = Asset.MyListings.myListingsDraft.image
        }

        if listingTypeViewModel.listingTypeSettings.title != nil
            && listingTypeViewModel.propertyTypeSettings.title != nil {
            let listingTypeSettings = listingTypeViewModel.listingTypeSettings
            let propertyTypeSettings = listingTypeViewModel.propertyTypeSettings
            typeView.isHidden = false
            typeView.backgroundColor = listingTypeSettings.color?.withAlphaComponent(0.8)
            typeTitleLabel.text = listingTypeSettings.title
            typeIconImageView.image = propertyTypeSettings.icon
            propertyTypeLabel.text = propertyTypeSettings.title
        } else {
            typeView.isHidden = true
        }

        let propertiesInfo = InlinePropertiesInfo(strings: listingViewModel.inlinePropertiesInfo.strings,
                                                  attributedStrings: [],
                                                  color: .white)
        inlinePropertiesView.setup(with: propertiesInfo)
        addressLabel.text = listingViewModel.address

        listingViewModel.priceUpdated
            .drive(onNext: { [weak self] price in
                self?.priceLabel.text = price
            })
            .disposed(by: disposeBag)
        listingViewModel.pricePerSquareMeterUpdated
            .drive(onNext: { [weak pricePerSquareMeterLabel] pricePerSquare in
                pricePerSquareMeterLabel?.text = pricePerSquare
            })
            .disposed(by: disposeBag)

        isSelectedLikeButton = listingViewModel.isMarkedFavorite
        toggleLikeButton()
        likeButton.isHidden = listingViewModel.isUserOwnedListing

        planIconImageView.image = listingViewModel.paymentPlanViewModel?.icon
        planPlaceholderView.backgroundColor = listingViewModel.paymentPlanViewModel?.backgroundColor
    }

    func toggleLikeButton() {
        let image = isSelectedLikeButton ? Asset.ListingPreview.likeFilled.image : Asset.ListingPreview.likeEmpty.image
        likeButton.setImage(image, for: .normal)
    }

}

extension TopListingPreviewCell {

    @objc
    private func likeButtonDidSelect() {
        if !isGuest {
            self.isSelectedLikeButton = !self.isSelectedLikeButton
            self.toggleLikeButton()
            //self.didToggleFavorite?(self.isSelectedLikeButton)
        }
        self.didToggleFavorite?(self.isSelectedLikeButton)
    }

    private func setupViews() {
        primaryImageView.contentMode = .scaleAspectFill
        primaryImageView.layerCornerRadius = 10
        primaryImageView.clipsToBounds = true

        addSubview(primaryImageView)
        primaryImageView.pinEdges(to: self)

        gradientImageView.image = Asset.ListingPreview.topListingGradient.image
        gradientImageView.contentMode = .scaleAspectFill
        gradientImageView.layerCornerRadius = 10
        gradientImageView.clipsToBounds = true
        addSubview(gradientImageView)
        gradientImageView.pinEdges(to: self, with: UIEdgeInsets(top: 72, left: 0, bottom: 0, right: 0))

        setupTypeView()

        addSubview(inlinePropertiesView)
        inlinePropertiesView.layout {
            $0.bottom.equal(to: bottomAnchor, offsetBy: -15)
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.trailing.lessThanOrEqual(to: trailingAnchor, offsetBy: -10)
        }

        addressLabel.textColor = .white
        addressLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12)
        addSubview(addressLabel)
        addressLabel.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -5)
            $0.bottom.equal(to: inlinePropertiesView.topAnchor, offsetBy: -13)
        }

        priceLabel.textColor = .white
        priceLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 20)
        addSubview(priceLabel)
        priceLabel.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.bottom.equal(to: addressLabel.topAnchor, offsetBy: -7)
        }

        pricePerSquareMeterLabel.textColor = .white
        pricePerSquareMeterLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 12)
        addSubview(pricePerSquareMeterLabel)
        pricePerSquareMeterLabel.layout {
            $0.leading.equal(to: priceLabel.trailingAnchor, offsetBy: 5)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -5)
            $0.bottom.equal(to: addressLabel.topAnchor, offsetBy: -11)
        }

        likeButton.addTarget(self, action: #selector(likeButtonDidSelect), for: .touchUpInside)
        likeButton.setImage(Asset.ListingPreview.likeEmpty.image, for: .normal)
        addSubview(likeButton)
        likeButton.layout {
            $0.top.equal(to: topAnchor, offsetBy: 9)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -7)
            $0.height.equal(to: 24.0)
            $0.width.equal(to: 24.0)
        }

        setupPlanView()
    }

    private func setupTypeView() {
        typeView.layerCornerRadius = 4
        addSubview(typeView)
        typeView.layout {
            $0.top.equal(to: topAnchor, offsetBy: 8)
            $0.leading.equal(to: leadingAnchor, offsetBy: 8)
            $0.trailing.lessThanOrEqual(to: primaryImageView.trailingAnchor, offsetBy: -8)
            $0.bottom.lessThanOrEqual(to: primaryImageView.bottomAnchor, offsetBy: -8)
        }

        typeView.addSubview(typeIconImageView)
        typeIconImageView.layout {
            $0.top.equal(to: typeView.topAnchor, offsetBy: 8)
            $0.leading.equal(to: typeView.leadingAnchor, offsetBy: 4)
            $0.height.equal(to: 16.0)
            $0.width.equal(to: 16.0)
        }

        propertyTypeLabel.textColor = .white
        propertyTypeLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 10)
        typeView.addSubview(propertyTypeLabel)
        propertyTypeLabel.layout {
            $0.top.equal(to: typeView.topAnchor, offsetBy: 6)
            $0.leading.equal(to: typeIconImageView.trailingAnchor, offsetBy: 6)
            $0.trailing.lessThanOrEqual(to: typeView.trailingAnchor, offsetBy: -16)
        }

        typeTitleLabel.textColor = .white
        typeTitleLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12)
        typeView.addSubview(typeTitleLabel)
        typeTitleLabel.layout {
            $0.top.equal(to: propertyTypeLabel.bottomAnchor, offsetBy: 1)
            $0.leading.equal(to: typeIconImageView.trailingAnchor, offsetBy: 6)
            $0.trailing.lessThanOrEqual(to: typeView.trailingAnchor, offsetBy: -17)
            $0.bottom.equal(to: typeView.bottomAnchor, offsetBy: -3)
        }
    }

    private func setupPlanView() {
        planPlaceholderView.layerCornerRadius = 4

        addSubview(planPlaceholderView)
        planPlaceholderView.layout {
            $0.top.equal(to: typeView.bottomAnchor, offsetBy: 9)
            $0.leading.equal(to: leadingAnchor, offsetBy: 8)
            $0.height.equal(to: 20)
            $0.width.equal(to: 20)
        }

        planIconImageView.contentMode = .scaleAspectFit
        planPlaceholderView.addSubview(planIconImageView)
        planIconImageView.pinEdges(to: planPlaceholderView)
    }

}
