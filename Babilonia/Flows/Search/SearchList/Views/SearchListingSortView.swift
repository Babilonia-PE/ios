//
//  SearchListingSortView.swift
//  Babilonia
//
//  Created by Vodolazkyi Anton on 3/11/20.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class SearchListingSortView: UIView {
    
    var actionButton: UIButton!
    var sortOptionLabel: UILabel!

    private var titleLabel: UILabel!
    private var iconImageView: UIImageView!
    
    init() {
        super.init(frame: .zero)
        
        setupViews()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private
    
    private func layout() {
        addSubview(iconImageView)
        iconImageView.layout {
            $0.width == 16
            $0.height == 16
            $0.trailing == trailingAnchor - 16.0
            $0.bottom == bottomAnchor - 4
        }
        
        addSubview(sortOptionLabel)
        sortOptionLabel.layout {
            $0.trailing == iconImageView.leadingAnchor - 8
            $0.centerY == iconImageView.centerYAnchor
        }
        
        addSubview(titleLabel)
        titleLabel.layout {
            $0.trailing == sortOptionLabel.leadingAnchor - 8
            $0.centerY == sortOptionLabel.centerYAnchor
        }
        
        addSubview(actionButton)
        actionButton.layout {
            $0.top == topAnchor
            $0.bottom == bottomAnchor
            $0.trailing == trailingAnchor
            $0.leading == titleLabel.leadingAnchor
        }
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        titleLabel = UILabel()
        titleLabel.font = FontFamily.AvenirLTStd._45Book.font(size: 12)
        titleLabel.textColor = Asset.Colors.bluishGrey.color
        titleLabel.text = L10n.Listing.List.sortBy

        sortOptionLabel = UILabel()
        sortOptionLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12)
        sortOptionLabel.textColor = Asset.Colors.gunmetal.color
        
        iconImageView = UIImageView(image: Asset.Common.arrowDownGrey.image)
        
        actionButton = UIButton()
    }
}
