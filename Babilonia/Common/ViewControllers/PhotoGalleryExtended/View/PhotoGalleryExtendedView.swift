//
//  PhotoGalleryExtendedView.swift
//  Babilonia
//
//  Created by Alya Filon  on 12.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class PhotoGalleryExtendedView: NiblessView {

    let backButton: UIButton = .init()
    let photoCountLabel: UILabel = .init()
    private let titleLabel: UILabel = .init()
    private let backgroungImageView: UIImageView = .init()
    private let backgroungBlurView: UIVisualEffectView = .init()
    private let scrollView: UIScrollView = .init()

    private let side: CGFloat = UIConstants.screenWidth - 16
    private var containerHeight: CGFloat {
        let offsets = UIConstants.safeLayoutTop + UIConstants.safeLayoutBottom + 86 + 35

        return UIConstants.screenHeight - offsets
    }
    private var photoCount = 0

    override init() {
        super.init()

        setupView()
    }

    func apply(photos: [PhotoType], initialIndex: Int) {
        photoCount = photos.count
        setupPhotos(photos)
        scrollPhotos(to: initialIndex)
    }

}

extension PhotoGalleryExtendedView {

    private func setupPhotos(_ photos: [PhotoType]) {
        let sideOffset: CGFloat = 8
        let totalWidth: CGFloat = side * CGFloat(photos.count) + (sideOffset * 2 * CGFloat(photos.count))
        var offsetX: CGFloat = 0

        for (index, photo) in photos.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true

            setupPhotoImage(at: imageView, photo: photo)
            scrollView.addSubview(imageView)

            offsetX = CGFloat(index) * side
            offsetX += index == 0 ? sideOffset : sideOffset * (2 * CGFloat(index)) + sideOffset
            imageView.frame = CGRect(x: offsetX, y: 0, width: side, height: containerHeight)
        }

        scrollView.contentSize = CGSize(width: totalWidth, height: containerHeight)
    }

    func scrollPhotos(to index: Int) {
        let sideOffset: CGFloat = 8
        let offsetX = CGFloat(index) * side + sideOffset * (2 * CGFloat(index))
        scrollView.contentOffset = CGPoint(x: offsetX, y: 0)
    }

    private func setupPhotoImage(at imageView: UIImageView, photo: PhotoType) {
        if let image = photo.image {
            imageView.image = image
        } else {
            imageView.kf.setImage(with: photo.url)
        }
    }

    private func setupView() {
        backgroundColor = .white

        backgroungImageView.image = Asset.CreateListing.uploadPhotoEmptyIcon.image
        backgroungImageView.contentMode = .scaleAspectFill
        backgroungImageView.clipsToBounds = true
        backgroungImageView.alpha = 0.7
        addSubview(backgroungImageView)
        backgroungImageView.pinEdges(to: self)

        backgroungBlurView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.9)
        backgroungBlurView.effect = UIBlurEffect(style: .dark)
        addSubview(backgroungBlurView)
        backgroungBlurView.pinEdges(to: self)

        backButton.setImage(Asset.Common.backIcon.image.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.tintColor = .white
        backButton.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 12.0, bottom: 10.0, right: 12.0)

        addSubview(backButton)
        backButton.layout {
            $0.top.equal(to: safeAreaLayoutGuide.topAnchor)
            $0.leading.equal(to: leadingAnchor)
        }

        titleLabel.text = L10n.PhotoGallery.title
        titleLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 16)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center

        addSubview(titleLabel)
        titleLabel.layout {
            $0.top.equal(to: safeAreaLayoutGuide.topAnchor, offsetBy: 12)
            $0.leading.equal(to: leadingAnchor, offsetBy: 35)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -35)
        }

        photoCountLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 16)
        photoCountLabel.textColor = .white
        photoCountLabel.textAlignment = .center

        addSubview(photoCountLabel)
        photoCountLabel.layout {
            $0.top.equal(to: titleLabel.bottomAnchor, offsetBy: 8)
            $0.leading.equal(to: leadingAnchor, offsetBy: 20)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -20)
        }

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self

        addSubview(scrollView)
        scrollView.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 0)
            $0.trailing.equal(to: trailingAnchor, offsetBy: 0)
            $0.top.equal(to: photoCountLabel.bottomAnchor, offsetBy: 10)
            $0.height.equal(to: containerHeight)
        }
    }

}

extension PhotoGalleryExtendedView: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x.truncatingRemainder(dividingBy: UIConstants.screenWidth) == 0 {
            let index = Int(scrollView.contentOffset.x / side)
            photoCountLabel.text = "\(index + 1)/\(photoCount)"
        }
    }

}
