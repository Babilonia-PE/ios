//
//  PhotoGalleryViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 12.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation

final class PhotoGalleryViewModel {

    var photos: [PhotoType] {
        model.photos
    }
    
    private let model: PhotoGalleryModel
    
    init(model: PhotoGalleryModel) {
        self.model = model
    }

    func showDetailedGallery(at index: Int) {
        model.showDetailedGallery(at: index)
    }
    
}
