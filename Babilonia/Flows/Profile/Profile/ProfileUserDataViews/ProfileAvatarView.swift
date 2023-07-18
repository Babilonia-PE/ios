//
//  ProfileAvatarView.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/10/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxCocoa

final class ProfileAvatarView: UIView {

    var editButtonTap: ControlEvent<Void> { return editButton.rx.tap }

    private var avatarImageView: UIImageView!
    private var nameLabel: UILabel!
    private var editButton: UIButton!
    private var separatorView: UIView!
    
    init() {
        super.init(frame: .zero)
        
        layout()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with avatarPath: String? = nil, avatarImage: UIImage? = nil, name: String) {
        if let avatarImage = avatarImage {
            avatarImageView.image = avatarImage
        } else if let path = avatarPath {
            avatarImageView.setImage(with: URL(string: path))
        } else {
            avatarImageView.image = Asset.Profile.userPlaceholder.image
        }
        
        nameLabel.attributedText = name.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 20.0),
            alignment: .center,
            color: Asset.Colors.vulcan.color,
            kern: 1.0
        )
        nameLabel.lineBreakMode = .byTruncatingTail
    }
    
    // MARK: - private
    
    private func layout() {
        avatarImageView = UIImageView()
        addSubview(avatarImageView)
        avatarImageView.layout {
            $0.top == topAnchor + 18.0
            $0.centerX == centerXAnchor
            $0.width == 88.0
            $0.height == 88.0
        }
        
        nameLabel = UILabel()
        addSubview(nameLabel)
        nameLabel.layout {
            $0.top == avatarImageView.bottomAnchor + 16.0
            $0.leading == leadingAnchor + 12.0
            $0.trailing == trailingAnchor - 12.0
        }
        
        editButton = UIButton()
        addSubview(editButton)
        editButton.layout {
            $0.top == topAnchor
            $0.trailing == trailingAnchor - 4.0
            $0.width == 40.0
            $0.height == 40.0
        }
        
        separatorView = UIView()
        addSubview(separatorView)
        separatorView.layout {
            $0.top == nameLabel.bottomAnchor + 16.0
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
            $0.height == 8.0
        }
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        editButton.setImage(Asset.Profile.edit.image, for: .normal)
        editButton.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 6.0, bottom: 6.0, right: 6.0)
        
        avatarImageView.backgroundColor = Asset.Colors.whiteLilac.color
        avatarImageView.layer.cornerRadius = 44.0
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        
        separatorView.backgroundColor = Asset.Colors.whiteLilac.color
    }
}
