//
//  UploadPhotosTopView.swift
//  Babilonia
//
//  Created by Denis on 7/3/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class UploadPhotosTopView: UIView {
    
    var uploadButtonTap: ControlEvent<Void> { return uploadButton.rx.tap }
    
    private var uploadPhotosImageView: UIImageView!
    private var uploadPhotosLabel: UILabel!
    private var uploadButton: UIButton!
    private var dashBorderLayer: CALayer!
    
    private let countUpdated: Driver<(Int, Int)>
    
    private let disposeBag = DisposeBag()
    
    init(countUpdated: Driver<(Int, Int)>) {
        self.countUpdated = countUpdated
        
        super.init(frame: .zero)
        
        layout()
        setupViews()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard dashBorderLayer == nil else { return }
        dashBorderLayer = layer.addDashBorderLayer(
            strokeLength: 5.0,
            fillLength: 7.0,
            lineWidth: 2.0,
            strokeColor: Asset.Colors.whiteLilac.color.cgColor,
            cornerRadius: 6.0
        )
    }
    
    // MARK: - private
    
    private func layout() {
        let containerView = UIView()
        addSubview(containerView)
        containerView.layout {
            $0.centerX == centerXAnchor
            $0.centerY == centerYAnchor
            $0.leading >= leadingAnchor
            $0.trailing <= trailingAnchor
            $0.top >= topAnchor
            $0.bottom <= bottomAnchor
        }
        
        uploadPhotosImageView = UIImageView()
        containerView.addSubview(uploadPhotosImageView)
        uploadPhotosImageView.layout {
            $0.top == containerView.topAnchor
            $0.leading == containerView.leadingAnchor
            $0.bottom == containerView.bottomAnchor
        }
        
        uploadPhotosLabel = UILabel()
        containerView.addSubview(uploadPhotosLabel)
        uploadPhotosLabel.layout {
            $0.leading == uploadPhotosImageView.trailingAnchor + 6.0
            $0.centerY == containerView.centerYAnchor
            $0.trailing == containerView.trailingAnchor
        }
        
        uploadButton = UIButton()
        addSubview(uploadButton)
        uploadButton.layout {
            $0.top == topAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
        }
    }
    
    private func setupViews() {
        backgroundColor = Asset.Colors.hintOfRed.color
        layer.cornerRadius = 6.0
        clipsToBounds = true
        
        uploadPhotosImageView.image = Asset.CreateListing.uploadPhotoIcon.image
        
        uploadPhotosLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 14.0)
        uploadPhotosLabel.textColor = Asset.Colors.osloGray.color
    }
    
    private func setupBindings() {
        countUpdated
            .drive(onNext: { [weak self] value in
                self?.updateTitle(with: value)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateTitle(with count: (Int, Int)) {
        uploadPhotosLabel.text = L10n.CreateListing.Photos.UploadView.title(count.0, count.1)
    }
    
}
