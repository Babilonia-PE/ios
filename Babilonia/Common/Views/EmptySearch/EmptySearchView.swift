//
//  EmptySearchView.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/26/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

final class EmptySearchView: UIView {

    private var titleLabel: UILabel!
    private var textLabel: UILabel!
    
    // MARK: - lifecycle
    
    init() {
        super.init(frame: .zero)
        
        layout()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private
    
    private func layout() {
        titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.layout {
            $0.top == topAnchor + 11.0
            $0.leading == leadingAnchor + 17.0
            $0.trailing == trailingAnchor - 17.0
        }
        
        textLabel = UILabel()
        addSubview(textLabel)
        textLabel.layout {
            $0.top == titleLabel.bottomAnchor + 9.0
            $0.leading == leadingAnchor + 17.0
            $0.trailing == trailingAnchor - 17.0
            $0.bottom == bottomAnchor - 13.0
        }
    }
    
    private func setupViews() {
        backgroundColor = Asset.Colors.bleachWhite.color
        layer.borderWidth = 1.0
        layer.borderColor = Asset.Colors.orange.color.cgColor
        layer.cornerRadius = 6.0
        
        titleLabel.numberOfLines = 0
        titleLabel.attributedText = L10n.ListingSearch.EmptyResult.title.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 14.0),
            color: Asset.Colors.vulcan.color
        )
        
        textLabel.numberOfLines = 0
        textLabel.attributedText = L10n.ListingSearch.EmptyResult.text.toAttributed(
            with: FontFamily.AvenirLTStd._55Roman.font(size: 14.0),
            color: Asset.Colors.mako.color
        )
    }
}
