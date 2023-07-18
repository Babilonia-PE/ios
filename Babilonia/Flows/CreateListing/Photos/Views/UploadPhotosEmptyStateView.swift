//
//  UploadPhotosEmptyStateView.swift
//  Babilonia
//
//  Created by Denis on 7/3/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxCocoa

final class UploadPhotosEmptyStateView: UIView {
    
    var uploadButtonTap: ControlEvent<Void> { return uploadButton.rx.tap }
    
    private var contentView: UIView!
    private var iconImageView: UIImageView!
    private var titleLabel: UILabel!
    private var uploadButton: UIButton!
    
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
        contentView = UIView()
        addSubview(contentView)
        contentView.layout {
            $0.centerY == centerYAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
        }
        
        iconImageView = UIImageView()
        contentView.addSubview(iconImageView)
        iconImageView.layout {
            $0.top == contentView.topAnchor
            $0.centerX == contentView.centerXAnchor
        }
        
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        titleLabel.layout {
            $0.top == iconImageView.bottomAnchor + 16.0
            $0.leading == contentView.leadingAnchor + 63.0
            $0.trailing == contentView.trailingAnchor - 63.0
        }
        
        uploadButton = UIButton()
        contentView.addSubview(uploadButton)
        uploadButton.layout {
            $0.top == titleLabel.bottomAnchor + 43.0
            $0.leading >= contentView.leadingAnchor + 16.0
            $0.trailing <= contentView.trailingAnchor - 16.0
            $0.centerX == contentView.centerXAnchor
            $0.width >= 200.0
            $0.height == 40.0
            $0.bottom == contentView.bottomAnchor
        }
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        iconImageView.image = Asset.CreateListing.uploadPhotoEmptyIcon.image
        
        titleLabel.numberOfLines = 0
        titleLabel.attributedText = L10n.CreateListing.Photos.EmptyState.text.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 16.0),
            lineSpacing: 4.0,
            alignment: .center,
            color: Asset.Colors.vulcan.color,
            kern: 0.5
        )
        
        uploadButton.setAttributedTitle(
            L10n.CreateListing.Photos.EmptyState.Button.title.toAttributed(
                with: FontFamily.SamsungSharpSans.bold.font(size: 12.0),
                lineSpacing: 0.0,
                alignment: .center,
                color: Asset.Colors.vulcan.color,
                kern: 1.0
            ),
            for: .normal
        )
        uploadButton.layer.cornerRadius = 20.0
        uploadButton.layer.borderWidth = 1.0
        uploadButton.layer.borderColor = Asset.Colors.pumice.color.cgColor
    }
    
}
