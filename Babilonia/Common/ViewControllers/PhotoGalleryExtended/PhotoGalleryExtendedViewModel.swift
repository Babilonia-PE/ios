//
//  PhotoGalleryExtendedViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 12.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation

final class PhotoGalleryExtendedViewModel {

    var photos: [PhotoType] {
        model.photos
    }
    
    var initialCurrentPhotoTitle: String {
        "\(model.index + 1)/\(model.photos.count)"
    }

    var initialIndex: Int {
        model.index
    }
    
    private let model: PhotoGalleryExtendedModel
    
    init(model: PhotoGalleryExtendedModel) {
        self.model = model
    }
    
}
