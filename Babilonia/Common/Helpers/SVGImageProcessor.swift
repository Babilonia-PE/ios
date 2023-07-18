//
//  SVGImageProcessor.swift
//  Babilonia
//
//  Created by Alya Filon  on 15.02.2021.
//  Copyright © 2021 Yalantis. All rights reserved.
//

import UIKit
import Kingfisher
import SVGKit

struct SVGImgProcessor: ImageProcessor {

    var identifier: String = "com.appidentifier.webpprocessor"

    public func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image

        case .data(let data):
            let imsvg = SVGKImage(data: data)

            return imsvg?.uiImage
        }
    }
}
