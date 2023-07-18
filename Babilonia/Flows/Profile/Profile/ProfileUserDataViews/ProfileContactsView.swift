//
//  ProfileContactsView.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/10/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxCocoa

final class ProfileContactsView: UIView {

    var editButtonTap: ControlEvent<Void> { return editButton.rx.tap }
    
    private var titleLabel: UILabel!
    private var dataLabel: UILabel!
    private var editButton: UIButton!
    private var accessoryImageView: UIImageView!
    
    init() {
        super.init(frame: .zero)
        
        layout()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with viewModel: ProfileUserDataViewModel) {
        titleLabel.attributedText = viewModel.title.toAttributed(
            with: FontFamily.AvenirLTStd._65Medium.font(size: 14.0),
            color: Asset.Colors.osloGray.color
        )
        
        dataLabel.attributedText = viewModel.dataValue?.toAttributed(
            with: FontFamily.AvenirLTStd._65Medium.font(size: 16.0),
            color: Asset.Colors.vulcan.color
        )
        dataLabel.lineBreakMode = .byTruncatingTail
        
        editButton.isEnabled = viewModel.isActive
        accessoryImageView.isHidden = !viewModel.isActive
    }
    
    // MARK: - private
    
    private func layout() {
        accessoryImageView = UIImageView()
        addSubview(accessoryImageView)
        accessoryImageView.layout {
            $0.top == topAnchor + 28.0
            $0.trailing == trailingAnchor - 16.0
            $0.width == 16.0
            $0.height == 16.0
        }
        
        titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.layout {
            $0.top == topAnchor + 20.0
            $0.leading == leadingAnchor + 18.0
            $0.trailing <= accessoryImageView.leadingAnchor - 16.0
        }
        
        dataLabel = UILabel()
        addSubview(dataLabel)
        dataLabel.layout {
            $0.top == titleLabel.bottomAnchor + 5.0
            $0.leading == leadingAnchor + 18.0
            $0.trailing <= accessoryImageView.leadingAnchor - 16.0
            $0.bottom == bottomAnchor - 10.0
            $0.height == 22.0
        }
        
        editButton = UIButton()
        addSubview(editButton)
        editButton.layout {
            $0.top == topAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
        }
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        accessoryImageView.image = Asset.Profile.accessoryArrow.image
    }
    
}
