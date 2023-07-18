//
//  ListingDetailsPhotosView.swift
//  Babilonia
//
//  Created by Denis on 7/11/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

final class ListingDetailsPhotosView: UIView {
    
    private var scrollView: UIScrollView!
    private var pageControl: PagesDotsView!
    private var photosCountParentView: UIView!
    private var photosCountLabel: UILabel!
    private var photosImageView: UIImageView!
    
    private var photoViews = [UIView]()

    var togglePhotoGalleryTap: (() -> Void)?
    
    // MARK: - lifecycle
    
    init() {
        super.init(frame: .zero)
        
        layout()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(photos: [ListingDetailsImage]) {
        photosCountLabel.text = String(photos.count)
        layoutPhotos(photos)

        let tap = UITapGestureRecognizer(target: self, action: #selector(togglePhotoTap))
        scrollView.addGestureRecognizer(tap)
    }
    
    // MARK: - private

    @objc
    private func togglePhotoTap() {
        togglePhotoGalleryTap?()
    }
    
    private func layout() {
        scrollView = UIScrollView()
        addSubview(scrollView)
        scrollView.layout {
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.top == topAnchor
            $0.bottom == bottomAnchor
        }

        photosCountParentView = UIView()
        addSubview(photosCountParentView)
        photosCountParentView.layout {
            $0.trailing == trailingAnchor - 8.0
            $0.bottom == bottomAnchor - 8.0
        }
        
        photosCountLabel = UILabel()
        photosCountParentView.addSubview(photosCountLabel)
        photosCountLabel.layout {
            $0.top == photosCountParentView.topAnchor + 4.0
            $0.trailing == photosCountParentView.trailingAnchor - 8.0
            $0.bottom == photosCountParentView.bottomAnchor - 4.0
            $0.height == 16.0
        }
        
        photosImageView = UIImageView()
        photosCountParentView.addSubview(photosImageView)
        photosImageView.layout {
            $0.leading == photosCountParentView.leadingAnchor + 5.0
            $0.trailing == photosCountLabel.leadingAnchor - 4.0
            $0.bottom == photosCountParentView.bottomAnchor - 5.0
        }
    }
    
    private func layoutPhotos(_ photos: [ListingDetailsImage]) {
        photoViews.forEach { $0.removeFromSuperview() }
        photoViews = []
        
        let contentOffset = scrollView.contentOffset
        
        var leftAnchor = scrollView.leadingAnchor
        var imageView: UIImageView!
        photos.forEach { photo in
            imageView = UIImageView()
            scrollView.addSubview(imageView)
            imageView.layout {
                $0.top == scrollView.topAnchor
                $0.bottom == scrollView.bottomAnchor
                $0.leading == leftAnchor
                $0.width == scrollView.widthAnchor
                $0.height == scrollView.heightAnchor
            }
            leftAnchor = imageView.trailingAnchor
            
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            switch photo {
            case .local(let photo):
                switch photo.status.value {
                case .uploading, .uploaded:
                    imageView.image = photo.image
                case .alreadyExists(let URL):
                    imageView.setImage(with: URL)
                }
            case .remote(let image):
                imageView.setImage(with: image.photo.largeURLString.flatMap(URL.init))
            }
            
            photoViews.append(imageView)
        }
        imageView?.layout {
            $0.trailing == scrollView.trailingAnchor
        }

        if pageControl != nil {
            pageControl.removeFromSuperview()
            pageControl = nil
        }
        if photoViews.count >= 2 {
            setupPageControl()
            pageControl.isHidden = false
            pageControl.dotsCount = photoViews.count > 5 ? 5 : photoViews.count
            pageControl.actualContentCount = photoViews.count
            pageControl.setCurrentDot(at: 0)
        }
        scrollView.contentOffset = contentOffset
        updatePage()
    }

    private func setupPageControl() {
        pageControl = PagesDotsView()
        addSubview(pageControl)
        pageControl.layout {
            $0.leading >= leadingAnchor + 30.0
            $0.centerX == centerXAnchor
            $0.bottom.equal(to: bottomAnchor, offsetBy: -7)
            $0.height.equal(to: 8)
        }
    }
    
    private func setupViews() {
        scrollView.isDirectionalLockEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        photosCountParentView.layer.cornerRadius = 3.0
        photosCountParentView.backgroundColor = Asset.Colors.vulcan.color.withAlphaComponent(0.5)
        
        photosCountLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12.0)
        photosCountLabel.textColor = .white
        
        photosImageView.image = Asset.ListingDetails.listingDetailsCameraSmall.image
    }
    
    private func updatePage() {
        guard scrollView.frame.width > 0.0 else { return }

        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl?.setCurrentDot(at: currentPage)
    }
    
}

extension ListingDetailsPhotosView: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updatePage()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePage()
    }
    
}
