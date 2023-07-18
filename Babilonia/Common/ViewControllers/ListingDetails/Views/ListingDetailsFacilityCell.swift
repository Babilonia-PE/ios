//
//  ListingDetailsFacilityCell.swift
//  Babilonia
//
//  Created by Denis on 7/16/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import Kingfisher

struct ListingDetailsFacilityInfo {

    enum InitType {
        case facilities, advancedDetails
    }
    
    let title: String
    let imageURL: URL?
    
}

final class ListingDetailsFacilityCell: UICollectionViewCell, Reusable {
    
    private var titleTextLabel: UILabel!
    private var imageView: UIImageView!
    
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
        
        imageView.kf.cancelDownloadTask()
    }
    
    func setup(with info: ListingDetailsFacilityInfo) {
        imageView.kf.setImage(with: info.imageURL,
                              options: [.processor(SVGImgProcessor())],
                              completionHandler: { [weak self] result in
                                if case let .success(image) = result {
                                    self?.imageView.image = image.image.withRenderingMode(.alwaysTemplate)
                                }
                              })
        titleTextLabel.text = info.title
    }
    
    // MARK: - private
    
    private func layout() {
        imageView = UIImageView()
        imageView.tintColor = Asset.Colors.bluishGrey.color
        addSubview(imageView)
        imageView.layout {
            $0.top == topAnchor + 16.0
            $0.leading == leadingAnchor + 16.0
            $0.width == 24.0
            $0.height == 24.0
        }
        
        titleTextLabel = UILabel()
        addSubview(titleTextLabel)
        titleTextLabel.layout {
            $0.leading == imageView.trailingAnchor + 16.0
            $0.trailing == trailingAnchor - 16.0
            $0.centerY == centerYAnchor
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
        }
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        titleTextLabel.numberOfLines = 2
        titleTextLabel.textAlignment = .left
        titleTextLabel.textColor = Asset.Colors.vulcan.color
        titleTextLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 14.0)
    }
    
}
