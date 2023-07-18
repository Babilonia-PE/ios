//
//  AnnotationViewModel.swift
//  Babilonia
//
//  Created by Vitaly Chernysh on 7/17/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxCocoa
import Core

typealias ListingImage = Core.ListingImage

protocol AnnotationViewModel: class {

    var coverImage: ListingImage? { get }
    var priceUpdated: Driver<String> { get }
    var propertyType: PropertyType? { get }
    var annotationInlinePropertiesInfo: InlinePropertiesInfo { get }

}
