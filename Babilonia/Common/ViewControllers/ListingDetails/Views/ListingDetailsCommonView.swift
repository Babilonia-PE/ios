//
//  ListingDetailsCommonView.swift
//  Babilonia
//
//  Created by Denis on 7/12/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

struct ListingDetailsCommonInfo {
    
    let price: String
    let pricePerSquareMeter: String
    let userImageURLString: String?
    let userName: String
    let propertyType: PropertyType?
    let listingType: ListingType?
    let inlinePropertiesInfo: InlinePropertiesInfo
    let areasInlinePropertiesInfo: InlinePropertiesInfo
    let isPetFriendly: Bool
    
}

final class ListingDetailsCommonView: UIView {
    
    private var priceLabel: UILabel!
    private var pricePerSquareMeterLabel: UILabel!
    private var typesView: UIView!
    private var propertyTypeImageView: UIImageView!
    private var propertyTypeLabel: UILabel!
    private var listingTypeLabel: UILabel!
    private var petFriendlyView: UIView!
    private var petFriendlyImageView: UIImageView!
    private var petFriendlyLabel: UILabel!
    private var userAvatarImageView: UIImageView!
    private var userNameLabel: UILabel!
    private var detailsInfoView: UIView!
    private var inlinePropertiesView: InlinePropertiesView!
    private var areasInlinePropertiesView: InlinePropertiesView!

    private var areaInlineViewTopConstraint: NSLayoutConstraint?

    // MARK: - lifecycle
    
    init() {
        super.init(frame: .zero)
        
        layout()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with info: ListingDetailsCommonInfo) {
        priceLabel.text = info.price
        pricePerSquareMeterLabel.text = info.pricePerSquareMeter
        propertyTypeImageView.image = info.propertyType?.icon
        propertyTypeLabel.text = info.propertyType?.title
        listingTypeLabel.text = (info.listingType?.title).flatMap { L10n.Common.For.text($0) }
        userAvatarImageView.setImage(
            with: info.userImageURLString.flatMap(URL.init),
            placeholder: Asset.Common.userAvatarPlaceholderSmall.image
        )
        userNameLabel.text = info.userName
        petFriendlyView.isHidden = !info.isPetFriendly
        
        setupTypesInfoViews(info)
        
        layoutDetailsInfo(info)
        fillInDefailsInfoViews(info)
    }
    
    // MARK: - private
    
    //swiftlint:disable:next function_body_length
    private func layout() {
        priceLabel = UILabel()
        addSubview(priceLabel)
        priceLabel.layout {
            $0.top == topAnchor + 13.0
            $0.leading == leadingAnchor + 16.0
            $0.height == 32.0
        }
        priceLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 800.0), for: .horizontal)
        priceLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 700.0), for: .horizontal)
        
        pricePerSquareMeterLabel = UILabel()
        addSubview(pricePerSquareMeterLabel)
        pricePerSquareMeterLabel.layout {
            $0.top == topAnchor + 22.0
            $0.leading == priceLabel.trailingAnchor + 10.0
            $0.height == 24.0
        }
        
        userAvatarImageView = UIImageView()
        addSubview(userAvatarImageView)
        userAvatarImageView.layout {
            $0.top == topAnchor + 14.0
            $0.leading >= pricePerSquareMeterLabel.trailingAnchor + 10.0
            $0.trailing == trailingAnchor - 31.0
            $0.width == 40.0
            $0.height == 40.0
        }
        userAvatarImageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 810.0), for: .horizontal)
        userAvatarImageView.setContentHuggingPriority(UILayoutPriority(rawValue: 690.0), for: .horizontal)
        
        typesView = UIView()
        addSubview(typesView)
        typesView.layout {
            $0.top == priceLabel.bottomAnchor + 9.0
            $0.leading == leadingAnchor + 16.0
            $0.height == 24.0
        }
        
        propertyTypeImageView = UIImageView()
        typesView.addSubview(propertyTypeImageView)
        propertyTypeImageView.layout {
            $0.centerY == typesView.centerYAnchor
            $0.leading == typesView.leadingAnchor + 4.0
            $0.width == 16.0
            $0.height == 16.0
        }
        
        propertyTypeLabel = UILabel()
        typesView.addSubview(propertyTypeLabel)
        propertyTypeLabel.layout {
            $0.centerY == typesView.centerYAnchor + 1.0
            $0.leading == propertyTypeImageView.trailingAnchor + 6.0
        }
        
        listingTypeLabel = UILabel()
        typesView.addSubview(listingTypeLabel)
        listingTypeLabel.layout {
            $0.centerY == typesView.centerYAnchor + 1.0
            $0.leading == propertyTypeLabel.trailingAnchor + 6.0
            $0.trailing == typesView.trailingAnchor - 8.0
        }
        
        petFriendlyView = UIView()
        addSubview(petFriendlyView)
        petFriendlyView.layout {
            $0.top == priceLabel.bottomAnchor + 9.0
            $0.leading == typesView.trailingAnchor + 8.0
            $0.height == 24.0
        }
        
        petFriendlyImageView = UIImageView()
        petFriendlyView.addSubview(petFriendlyImageView)
        petFriendlyImageView.layout {
            $0.centerY == petFriendlyView.centerYAnchor
            $0.leading == petFriendlyView.leadingAnchor + 8.0
            $0.width == 16.0
            $0.height == 16.0
        }
        
        petFriendlyLabel = UILabel()
        petFriendlyView.addSubview(petFriendlyLabel)
        petFriendlyLabel.layout {
            $0.centerY == petFriendlyView.centerYAnchor + 1.0
            $0.leading == petFriendlyImageView.trailingAnchor + 4.0
            $0.trailing == petFriendlyView.trailingAnchor - 8.0
        }
        
        userNameLabel = UILabel()
        addSubview(userNameLabel)
        userNameLabel.layout {
            $0.top == userAvatarImageView.bottomAnchor + 4.0
            $0.centerX == userAvatarImageView.centerXAnchor
            $0.leading >= petFriendlyView.trailingAnchor + 6.0
            $0.trailing <= trailingAnchor - 10.0
            $0.height == 16.0
        }
        userNameLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 690.0), for: .horizontal)
        userNameLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 810.0), for: .horizontal)
        
        detailsInfoView = UIView()
        addSubview(detailsInfoView)
        detailsInfoView.layout {
            $0.top == typesView.bottomAnchor + 12.0
            $0.bottom == bottomAnchor - 20.0
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
        }
    }
    
    private func layoutDetailsInfo(_ info: ListingDetailsCommonInfo) {
        inlinePropertiesView?.removeFromSuperview()
        inlinePropertiesView = InlinePropertiesView()
        detailsInfoView.addSubview(inlinePropertiesView)
        inlinePropertiesView.layout {
            $0.leading == detailsInfoView.leadingAnchor + 16.0
            $0.trailing <= detailsInfoView.trailingAnchor - 16.0
            $0.top.equal(to: detailsInfoView.topAnchor)
        }

        areasInlinePropertiesView?.removeFromSuperview()
        areasInlinePropertiesView = InlinePropertiesView()
        detailsInfoView.addSubview(areasInlinePropertiesView)
        areasInlinePropertiesView.layout {
            $0.leading == detailsInfoView.leadingAnchor + 16.0
            $0.trailing <= detailsInfoView.trailingAnchor - 16.0
            areaInlineViewTopConstraint = $0.top.equal(to: inlinePropertiesView.bottomAnchor, offsetBy: 9)
            $0.bottom.equal(to: detailsInfoView.bottomAnchor)
        }
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        priceLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 26.0)
        priceLabel.textColor = Asset.Colors.vulcan.color
        
        pricePerSquareMeterLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 14.0)
        pricePerSquareMeterLabel.textColor = Asset.Colors.trout.color
        
        userAvatarImageView.layer.cornerRadius = 20.0
        userAvatarImageView.clipsToBounds = true
        userAvatarImageView.contentMode = .scaleAspectFill
        userNameLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12.0)
        userNameLabel.textColor = Asset.Colors.vulcan.color
        
        typesView.layer.cornerRadius = 4.0
        propertyTypeLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 10.0)
        propertyTypeLabel.textColor = .white
        listingTypeLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12.0)
        listingTypeLabel.textColor = .white
        
        petFriendlyView.layer.cornerRadius = 4.0
        petFriendlyView.backgroundColor = Asset.Colors.solitude.color
        petFriendlyLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12.0)
        petFriendlyLabel.textColor = Asset.Colors.biscay.color
        petFriendlyLabel.text = L10n.ListingDetails.PetFriendly.text
        petFriendlyImageView.image = Asset.ListingDetails.petFriendlyIconSmall.image
    }
    
    private func setupTypesInfoViews(_ info: ListingDetailsCommonInfo) {
        switch info.listingType {
        case .sale?:
            typesView.backgroundColor = Asset.Colors.hippieBlue.color.withAlphaComponent(0.8)
            typesView.isHidden = false
        case .rent?:
            typesView.backgroundColor = Asset.Colors.orange.color.withAlphaComponent(0.8)
            typesView.isHidden = false
        case nil:
            typesView.isHidden = true
        }
    }
    
    private func fillInDefailsInfoViews(_ info: ListingDetailsCommonInfo) {
        inlinePropertiesView.setup(with: info.inlinePropertiesInfo)
        areasInlinePropertiesView.setup(with: info.areasInlinePropertiesInfo)

        let isInlineInfoEmpty = info.inlinePropertiesInfo.attributedStrings.isEmpty &&
            info.inlinePropertiesInfo.strings.isEmpty
        areaInlineViewTopConstraint?.constant = isInlineInfoEmpty ? 0 : 12
    }
    
}

extension PropertyType {
    
    var icon: UIImage {
        switch self {
        case .apartment:
            return Asset.CreateListing.createListingPageCommon.image
        case .house:
            return Asset.MyListings.myListingsHouseIcon.image
        case .commercial:
            return Asset.MyListings.myListingsCommercialIcon.image
        case .office:
            return Asset.MyListings.myListingsOfficeIcon.image
        case .land:
            return Asset.MyListings.myListingsLandIcon.image
        case .room:
            return Asset.MyListings.myListingsRoomIcon.image
        }
    }
    
}
