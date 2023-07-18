//
//  PhotoGalleryExtendedModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 12.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

final class PhotoGalleryExtendedModel: EventNode {

    let photos: [PhotoType]
    let index: Int

    init(parent: EventNode, photos: [PhotoType], index: Int) {
        self.photos = photos
        self.index = index

        super.init(parent: parent)
    }
    
}
