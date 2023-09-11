//
//  CreateListingFacilityView.swift
//  Babilonia
//
//  Created by Denis on 6/14/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import SDWebImageSVGCoder

final class CreateListingFacilityView: UIView {
    
    private var titleLabel: UILabel!
    private var imageView: UIImageView!
    private var checkboxImageView: UIImageView!
    private var selectionButton: UIButton!
    private var separatorView: UIView!

    private let viewModel: CreateListingFacilityViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: CreateListingFacilityViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        layout()
        setupBindings()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private
    
    private func layout() {
        imageView = UIImageView()
        imageView.tintColor = Asset.Colors.bluishGrey.color
        addSubview(imageView)
        imageView.layout {
            $0.top == topAnchor + 16.0
            $0.leading == leadingAnchor + 16.0
            $0.width == 24
            $0.height == 24
        }
        
        titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.layout {
            $0.leading == imageView.trailingAnchor + 16.0
            $0.top == topAnchor + 17.0
            $0.bottom == bottomAnchor - 18.0
            $0.height >= 21.0
        }
        
        checkboxImageView = UIImageView()
        addSubview(checkboxImageView)
        checkboxImageView.layout {
            $0.leading == titleLabel.trailingAnchor + 12.0
            $0.trailing == trailingAnchor - 16.0
            $0.top == topAnchor + 16.0
            $0.width == 16.0
            $0.height == 16.0
        }
        
        separatorView = UIView()
        addSubview(separatorView)
        separatorView.layout {
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
            $0.height == 1.0
        }
        
        selectionButton = UIButton()
        addSubview(selectionButton)
        selectionButton.layout {
            $0.top == topAnchor
            $0.bottom == bottomAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
        }
    }
    
    private func setupViews() {
        backgroundColor = .clear

        if let image = viewModel.image {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
        } else {
            var options: KingfisherOptionsInfo = []
            if let url = viewModel.imageURL?.absoluteString, url.hasSuffix(".svg") {
                options.append(.processor(SVGImgProcessor()))
            }
            let SVGCoder = SDImageSVGCoder.shared
            SDImageCodersManager.shared.addCoder(SVGCoder)
            imageView.sd_setImage(with: viewModel.imageURL)
            imageView.contentMode = .scaleAspectFill
        }
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.textColor = Asset.Colors.vulcan.color
        titleLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 14.0)
        titleLabel.text = viewModel.title
        
        separatorView.backgroundColor = Asset.Colors.whiteLilac.color
    }
    
    private func setupBindings() {
        viewModel.valueUpdated
            .drive(onNext: { [weak self] value in
                self?.updateCheckboxImage(value)
            })
            .disposed(by: disposeBag)
        
        selectionButton.rx.tap
            .bind(onNext: viewModel.changeValue)
            .disposed(by: disposeBag)
    }
    
    private func updateCheckboxImage(_ isSelected: Bool) {
        if isSelected {
            checkboxImageView.image = Asset.Common.Checkbox.checkboxChecked.image
        } else {
            checkboxImageView.image = Asset.Common.Checkbox.checkboxUnchecked.image
        }
    }
    
}
