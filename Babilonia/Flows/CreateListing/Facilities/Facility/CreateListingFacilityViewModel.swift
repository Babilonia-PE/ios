//
//  CreateListingFacilityViewModel.swift
//  Babilonia
//
//  Created by Denis on 6/14/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit.UIImage

final class CreateListingFacilityViewModel {
    
    var valueUpdated: Driver<Bool> { return value.asDriver().distinctUntilChanged() }

    let id: Int?
    let title: String
    let imageURL: URL?
    let image: UIImage?
    let value: BehaviorRelay<Bool>
    
    init(id: Int? = nil, title: String, imageURL: URL? = nil, image: UIImage? = nil, value: BehaviorRelay<Bool>) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.image = image
        self.value = value
    }
    
    func changeValue() {
        self.value.accept(!value.value)
    }
    
}
