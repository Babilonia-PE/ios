//
//  PhotoGalleryCell.swift
//  Babilonia
//
//  Created by Alya Filon  on 12.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import Kingfisher

final class PhotoGalleryCell: UICollectionViewCell, Reusable {

    let photoImageView: LoadingImageView = .init()

    var imageLoadingHandler: (() -> Void)?

    // MARK: - lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        photoImageView.kf.cancelDownloadTask()
    }

    func apply(photo: PhotoType) {
        if let image = photo.image {
            photoImageView.image = image
        } else {
            photoImageView.kf.setImage(with: photo.url)
        }
    }

}

extension PhotoGalleryCell {

    private func setupView() {
        clipsToBounds = true

        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.imageDidSet = { [weak self] in
            self?.imageLoadingHandler?()
        }

        addSubview(photoImageView)
        photoImageView.pinEdges(to: self)
    }

}

class LoadingImageView: UIImageView {

    var imageDidSet: (() -> Void)?

    override var image: UIImage? {
        didSet {
            imageDidSet?()
        }
    }
}
