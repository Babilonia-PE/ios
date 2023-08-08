//
//  PhotoGalleryModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 12.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Core

enum PhotoGalleryEvent: Event {
    case showDetailedGallery(photos: [PhotoType], index: Int)
}

struct PhotoType {
    var image: UIImage?
    var urlString: String?

    var url: URL? {
        guard let string = urlString else { return nil }

        return URL(string: string)
    }
}

final class PhotoGalleryModel: EventNode {

    var photos = [PhotoType]()
    private let config: ListingDetailsModelConfig

    init(parent: EventNode, config: ListingDetailsModelConfig) {
        self.config = config

        super.init(parent: parent)

        procceedPhotos()
    }

    func showDetailedGallery(at index: Int) {
        raise(event: PhotoGalleryEvent.showDetailedGallery(photos: photos, index: index))
    }

    private func procceedPhotos() {
        switch config {
        case .local(let listing, _):
            let photos = listing.sortedPhotos.compactMap { PhotoType(urlString: $0.photo.renderURLString) }
            self.photos = photos

        case .remote(_, let cachedListing):
            if let listing = cachedListing {
                let photos = listing.sortedPhotos.compactMap { PhotoType(urlString: $0.photo.renderURLString) }
                self.photos = photos
            }
        }
    }
    
}
