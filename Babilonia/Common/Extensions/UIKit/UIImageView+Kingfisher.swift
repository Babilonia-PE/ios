//
//  UIImageView+Kingfisher.swift
//
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func setImage(with url: URL?, placeholder: UIImage? = nil) {
        kf.setImage(with: url, placeholder: placeholder)
    }
    
    func cancelImageFetching() {
        kf.cancelDownloadTask()
    }
}
