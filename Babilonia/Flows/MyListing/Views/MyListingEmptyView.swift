//
//  MyListingEmptyView.swift
//  Babilonia
//
//  Created by Vodolazkyi Anton on 3/12/20.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class MyListingEmptyView: UIView {
    
    enum EmptyType {
        case all, notPublished, published
    }
    
    var emptyStateButton: UIButton!

    private var emptyStateLabel: UILabel!
    private var emptyStateSubtitleLabel: UILabel!
    private let emptyImageView = UIImageView(image: Asset.MyListings.myListingsEmpty.image)

    init(type: EmptyType) {
        super.init(frame: .zero)
        
        layout()
        setupViews()
        
        switch type {
        case .all:
            emptyStateButton.isHidden = false
            emptyStateSubtitleLabel.isHidden = true
            emptyStateLabel.attributedText = L10n.MyListings.EmptyState.title.toAttributed(
                with: FontFamily.SamsungSharpSans.bold.font(size: 16.0),
                lineSpacing: 5.0,
                alignment: .center,
                color: Asset.Colors.vulcan.color,
                kern: 0.5
            )
            
        case .notPublished:
            emptyStateButton.isHidden = true
            emptyStateSubtitleLabel.isHidden = true
            emptyImageView.layout.centerY?.constant = -147
            emptyStateLabel.attributedText = L10n.MyListings.EmptyStateNotPublished.title.toAttributed(
                with: FontFamily.SamsungSharpSans.bold.font(size: 16.0),
                lineSpacing: 5.0,
                alignment: .center,
                color: Asset.Colors.vulcan.color,
                kern: 0.5
            )
            
        case .published:
            emptyStateButton.isHidden = true
            emptyStateSubtitleLabel.isHidden = false
            emptyImageView.layout.centerY?.constant = -147
            emptyStateLabel.attributedText = L10n.MyListings.EmptyStatePublished.title.toAttributed(
                with: FontFamily.SamsungSharpSans.bold.font(size: 16.0),
                lineSpacing: 5.0,
                alignment: .center,
                color: Asset.Colors.vulcan.color,
                kern: 0.5
            )
            
            emptyStateSubtitleLabel.attributedText = L10n.MyListings.EmptyStatePublished.subtitle.toAttributed(
                with: FontFamily.AvenirLTStd._55Roman.font(size: 16.0),
                lineSpacing: 13.0,
                alignment: .center,
                color: Asset.Colors.almostBlack.color,
                kern: 0.25
            )
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private
    
    private func layout() {
        addSubview(emptyImageView)
        emptyImageView.layout {
            $0.centerX == centerXAnchor
            $0.centerY == centerYAnchor - 130
        }
        
        emptyStateLabel = UILabel()
        addSubview(emptyStateLabel)
        emptyStateLabel.layout {
            $0.centerX == centerXAnchor
            $0.width == 185.0
            $0.top == emptyImageView.bottomAnchor + 16.0
        }
        
        emptyStateSubtitleLabel = UILabel()
        addSubview(emptyStateSubtitleLabel)
        emptyStateSubtitleLabel.layout {
            $0.centerX == centerXAnchor
            $0.width == 297.0
            $0.top == emptyStateLabel.bottomAnchor + 25.0
        }
        
        emptyStateButton = UIButton()
        addSubview(emptyStateButton)
        emptyStateButton.layout {
            $0.top == emptyStateLabel.bottomAnchor + 42.0
            $0.centerX == centerXAnchor
            $0.height == 40.0
            $0.width >= 200.0
        }
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        emptyStateLabel.numberOfLines = 0
        emptyStateSubtitleLabel.numberOfLines = 0

        let buttonTitle = L10n.MyListings.EmptyState.Button.text.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 12.0),
            lineSpacing: 0.0,
            alignment: .center,
            color: Asset.Colors.vulcan.color,
            kern: 1
        )
        emptyStateButton.setAttributedTitle(buttonTitle, for: .normal)
        emptyStateButton.titleEdgeInsets = UIEdgeInsets(top: 13.0, left: 40.0, bottom: 11.0, right: 40.0)
        emptyStateButton.layer.cornerRadius = 20.0
        emptyStateButton.layer.borderWidth = 1.0
        emptyStateButton.layer.borderColor = Asset.Colors.cloudyBlue.color.cgColor
    }
}
