//
//  ListingTypeView.swift
//  Babilonia
//
//  Created by Vitaly Chernysh on 7/18/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

final class ListingTypeView: UIView {
    
    private var imageView: UIImageView!
    private var propertyTypeLabel: UILabel!
    private var listingTypeLabel: UILabel!
    private var stackView: UIStackView!

    init() {
        super.init(frame: CGRect.zero)
        
        layout()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with viewModel: ListingTypeViewModel) {
        backgroundColor = viewModel.listingTypeSettings.color?.withAlphaComponent(viewModel.alpha)
        
        stackView.axis = viewModel.labelsAlignment == .vertical ? .vertical : .horizontal
        stackView.spacing = viewModel.labelsAlignment == .vertical ? 1.0 : 5.0
        
        propertyTypeLabel.text = viewModel.propertyTypeSettings.title
        listingTypeLabel.text = viewModel.listingTypeSettings.title
        imageView.image = viewModel.propertyTypeSettings.icon
    }
    
    private func layout() {
        imageView = UIImageView()
        addSubview(imageView)
        imageView.layout {
            $0.height == 16.0
            $0.width == 16.0
            $0.centerY == centerYAnchor
            $0.leading == leadingAnchor + 4.0
        }
        
        propertyTypeLabel = UILabel()
        listingTypeLabel = UILabel()
        
        stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.addArrangedSubview(propertyTypeLabel)
        stackView.addArrangedSubview(listingTypeLabel)
        addSubview(stackView)
        stackView.layout {
            $0.top == topAnchor + 3.0
            $0.bottom == bottomAnchor - 3.0
            $0.leading == imageView.trailingAnchor + 8.0
            $0.trailing == trailingAnchor - 8.0
        }
    }
    
    private func setupViews() {
        addCornerRadius(4.0)

        propertyTypeLabel.numberOfLines = 0
        propertyTypeLabel.textColor = .white
        propertyTypeLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 10.0)
        
        listingTypeLabel.numberOfLines = 0
        listingTypeLabel.textColor = .white
        listingTypeLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12.0)
    }

}
