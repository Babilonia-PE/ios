//
//  NumberFieldViewModel.swift
//  Babilonia
//
//  Created by Denis on 6/12/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class NumberFieldViewModel {
    
    var valueUpdated: Driver<Int> { return value.asDriver().distinctUntilChanged() }
    var isDecreasingAvailable: Driver<Bool> {
        return value.asDriver().map { [unowned self] value in
            value > self.minimunValue
        }.distinctUntilChanged()
    }
    var isIncreasingAvailable: Driver<Bool> {
        return value.asDriver().map { [unowned self] value in
            value < self.maximumValue
        }.distinctUntilChanged()
    }

    let id: Int
    let title: String
    let value: BehaviorRelay<Int>
    private let minimunValue: Int
    private let maximumValue: Int
    
    init(id: Int = 0, title: String, value: BehaviorRelay<Int>, minimunValue: Int = 0, maximumValue: Int = 99) {
        guard minimunValue <= maximumValue else {
            fatalError("Minimun value \(minimunValue) should be less than or equal to maximum value \(maximumValue)")
        }

        self.id = id
        self.title = title
        self.minimunValue = minimunValue
        self.maximumValue = maximumValue
        self.value = value
    }
    
    func decreaseValue() {
        let newValue = value.value - 1
        value.accept(max(minimunValue, min(maximumValue, newValue)))
    }
    
    func increaseValue() {
        let newValue = value.value + 1
        value.accept(max(minimunValue, min(maximumValue, newValue)))
    }
    
}
