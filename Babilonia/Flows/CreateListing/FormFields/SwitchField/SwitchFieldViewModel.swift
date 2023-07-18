//
//  SwitchFieldViewModel.swift
//  Babilonia
//
//  Created by Denis on 6/12/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit.UIImage

final class SwitchFieldViewModel {
    
    var valueUpdated: Driver<Bool> { return value.asDriver().distinctUntilChanged() }
    
    let title: String
    let image: UIImage?
    private let value: BehaviorRelay<Bool>
    
    init(title: String, image: UIImage?, value: BehaviorRelay<Bool>) {
        self.title = title
        self.image = image
        self.value = value
    }
    
    func updateValue(_ value: Bool) {
        self.value.accept(value)
    }
    
}
