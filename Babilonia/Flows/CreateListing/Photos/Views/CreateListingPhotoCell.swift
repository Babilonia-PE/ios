//
//  CreateListingPhotoCell.swift
//  Babilonia
//
//  Created by Denis on 7/5/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

final class CreateListingPhotoCell: UICollectionViewCell, Reusable {
    
    var buttomDidTap: (() -> Void)?
    
    private var imageView: UIImageView!
    private var optionsButton: UIButton!
    private var mainImageView: UIView!
    private var mainImageLabel: UILabel!
    private var activityIndicator: UIActivityIndicatorView!
    
    private var disposeBag = DisposeBag()
    
    // MARK: - lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layout()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.cancelImageFetching()
        disposeBag = DisposeBag()
    }
    
    func setup(with photo: CreateListingPhoto) {
        switch photo.status.value {
        case .uploading, .uploaded:
            imageView.image = photo.image
        case .alreadyExists(let URL):
            imageView.setImage(with: URL)
        }
        mainImageView.isHidden = !photo.isMainPhoto
        mainImageLabel.isHidden = !photo.isMainPhoto
        
        setupBindings(with: photo)
    }
    
    // MARK: - private
    
    private func layout() {
        imageView = UIImageView()
        addSubview(imageView)
        imageView.layout {
            $0.top == topAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
        }
        
        optionsButton = UIButton()
        addSubview(optionsButton)
        optionsButton.layout {
            $0.top == topAnchor
            $0.trailing == trailingAnchor
            $0.width == 40.0
            $0.height == 40.0
        }
        
        activityIndicator = UIActivityIndicatorView()
        addSubview(activityIndicator)
        activityIndicator.layout {
            $0.top == topAnchor + 10.0
            $0.leading == leadingAnchor + 10.0
        }
        
        mainImageView = UIView()
        addSubview(mainImageView)
        mainImageView.layout {
            $0.bottom == bottomAnchor - 16.0
            $0.leading >= leadingAnchor + 4.0
            $0.centerX == centerXAnchor
            $0.height == 32.0
        }
        
        mainImageLabel = UILabel()
        addSubview(mainImageLabel)
        mainImageLabel.layout {
            $0.leading == mainImageView.leadingAnchor + 24.0
            $0.trailing == mainImageView.trailingAnchor - 24.0
            $0.centerY == mainImageView.centerYAnchor + 1.0
        }
    }
    
    private func setupViews() {
        layer.cornerRadius = 6.0
        clipsToBounds = true
        
        imageView.contentMode = .scaleAspectFill
        
        optionsButton.setImage(Asset.MyListings.myListingsMore.image.withRenderingMode(.alwaysTemplate), for: .normal)
        optionsButton.tintColor = .white
        optionsButton.addTarget(self, action: #selector(toggleButtomDidTap(_:)), for: .touchUpInside)
        
        activityIndicator.style = .white
        activityIndicator.hidesWhenStopped = true
        
        mainImageView.layer.cornerRadius = 16.0
        mainImageView.backgroundColor = Asset.Colors.vulcan.color.withAlphaComponent(0.8)
        
        mainImageLabel.textColor = .white
        mainImageLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 14.0)
        mainImageLabel.textAlignment = .center
        mainImageLabel.text = L10n.CreateListing.Photos.PhotoCell.MainImage.text
    }
    
    private func setupBindings(with photo: CreateListingPhoto) {
        photo.status
            .asDriver()
            .drive(onNext: { [unowned self] status in
                switch status {
                case .uploading:
                    self.activityIndicator.startAnimating()
                case .uploaded, .alreadyExists:
                    self.activityIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
    }

    @objc
    private func toggleButtomDidTap(_ sender: UIButton) {
        buttomDidTap?()
    }
    
}
