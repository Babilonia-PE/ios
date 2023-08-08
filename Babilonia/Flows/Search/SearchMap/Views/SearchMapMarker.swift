//
//  SearchMapMarker.swift
//  Babilonia
//
//  Created by Denis on 7/28/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct SearchMapMarkerInfo {
    var priceString: String
    var propertyType: PropertyType
    var listingId: ListingId
}

final class SearchMapMarker: UIView {
    
    var isSelected = false {
        didSet {
            guard oldValue != isSelected else { return }
            updateSelection()
        }
    }
    
    private(set) var listingId: ListingId!
    
    private var backgroundImageView: UIImageView!
    private var backgroundView: UIView!
    private var propertyTypeImageView: UIImageView!
    private var priceLabel: UILabel!
    
    private var propertyType: PropertyType!
    private var wasShown = false {
        didSet {
            guard oldValue != isSelected else { return }
            updateShown()
        }
    }
    
    // MARK: - lifecycle
    
    init() {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 37.0))
        
        layout()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with info: SearchMapMarkerInfo) {
        listingId = info.listingId
        priceLabel.text = info.priceString
        propertyType = info.propertyType
        
        updateShown()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bounds = CGRect(
            x: bounds.minX,
            y: bounds.minY,
            width: backgroundView.frame.width,
            height: bounds.height)
        
    }
    
    // MARK: - private
    
    private func layout() {
        backgroundImageView = UIImageView()
        addSubview(backgroundImageView)
        backgroundImageView.layout {
            $0.top == topAnchor
            $0.bottom == bottomAnchor
            $0.centerX == centerXAnchor
            $0.width == 10.0
            $0.height == 37.0
        }
        
        backgroundView = UIView()
        addSubview(backgroundView)
        backgroundView.layout {
            $0.top == topAnchor
            $0.leading == leadingAnchor
            $0.height == 32.0
        }
        
        propertyTypeImageView = UIImageView()
        backgroundView.addSubview(propertyTypeImageView)
        propertyTypeImageView.layout {
            $0.top == backgroundView.topAnchor + 8.0
            $0.leading == backgroundView.leadingAnchor + 12.0
            $0.width == 16.0
            $0.height == 16.0
        }
        
        priceLabel = UILabel()
        backgroundView.addSubview(priceLabel)
        priceLabel.layout {
            $0.leading == propertyTypeImageView.trailingAnchor + 2.0
            $0.top == backgroundView.topAnchor + 9.0
            $0.trailing == backgroundView.trailingAnchor - 12.0
            $0.height == 16.0
        }
    }
    
    private func setupViews() {
        backgroundImageView.image = Asset.Search.Map.searchMapPin.image
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 16.0
        backgroundView.backgroundColor = Asset.Colors.biscay.color
        priceLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12.0)
        priceLabel.textColor = Asset.Colors.babyBlueEyes.color
        propertyTypeImageView.tintColor = Asset.Colors.babyBlueEyes.color
    }
    
    private func updateSelection() {
        if isSelected {
            wasShown = true
            propertyTypeImageView.tintColor = .white
            priceLabel.textColor = .white
        } else {
            propertyTypeImageView.tintColor = Asset.Colors.babyBlueEyes.color
            priceLabel.textColor = Asset.Colors.babyBlueEyes.color
        }
    }
    
    private func updateShown() {
        if wasShown {
            propertyTypeImageView.image = propertyType.pinShownImage
        } else {
            propertyTypeImageView.image = propertyType.pinImage
        }
    }
    
}

private extension PropertyType {
    
    var pinImage: UIImage {
        let image: UIImage
        switch self {
        case .apartment:
            image = Asset.Search.Map.apartmentPinIcon.image
        case .commercial:
            image = Asset.Search.Map.commercialPinIcon.image
        case .house:
            image = Asset.Search.Map.housePinIcon.image
        case .land:
            image = Asset.Search.Map.landPinIcon.image
        case .office:
            image = Asset.Search.Map.officePinIcon.image
        case .room:
            image = Asset.Search.Map.roomPinIcon.image
        case .localIndustrial:
            return Asset.Search.Map.commercialPinIcon.image
        case .landAgricultural:
            return Asset.Search.Map.landPinIcon.image
        case .landIndustrial:
            return Asset.Search.Map.landPinIcon.image
        case .landCommercial:
            return Asset.Search.Map.commercialPinIcon.image
        case .cottage:
            return Asset.Search.Map.housePinIcon.image
        case .beachHouse:
            return Asset.Search.Map.housePinIcon.image
        case .building:
            return Asset.Search.Map.commercialPinIcon.image
        case .hotel:
            return Asset.Search.Map.commercialPinIcon.image
        case .deposit:
            return Asset.Search.Map.landPinIcon.image
        case .parking:
            return Asset.Search.Map.landPinIcon.image
        case .airs:
            return Asset.Search.Map.officePinIcon.image
        }
        
        return image.withRenderingMode(.alwaysTemplate)
    }
    
    var pinShownImage: UIImage {
        let image: UIImage
        switch self {
        case .apartment:
            image = Asset.Search.Map.apartmentViewedPinIcon.image
        case .commercial:
            image = Asset.Search.Map.commercialViewedPinIcon.image
        case .house:
            image = Asset.Search.Map.houseViewedPinIcon.image
        case .land:
            image = Asset.Search.Map.landViewedPinIcon.image
        case .office:
            image = Asset.Search.Map.officeViewedPinIcon.image
        case .room:
            image = Asset.Search.Map.roomViewedPinIcon.image
        case .localIndustrial:
            return Asset.Search.Map.commercialViewedPinIcon.image
        case .landAgricultural:
            return Asset.Search.Map.landViewedPinIcon.image
        case .landIndustrial:
            return Asset.Search.Map.landViewedPinIcon.image
        case .landCommercial:
            return Asset.Search.Map.commercialViewedPinIcon.image
        case .cottage:
            return Asset.Search.Map.houseViewedPinIcon.image
        case .beachHouse:
            return Asset.Search.Map.houseViewedPinIcon.image
        case .building:
            return Asset.Search.Map.commercialViewedPinIcon.image
        case .hotel:
            return Asset.Search.Map.commercialViewedPinIcon.image
        case .deposit:
            return Asset.Search.Map.landViewedPinIcon.image
        case .parking:
            return Asset.Search.Map.landViewedPinIcon.image
        case .airs:
            return Asset.Search.Map.officeViewedPinIcon.image
        }
        return image.withRenderingMode(.alwaysTemplate)
    }
    
}
