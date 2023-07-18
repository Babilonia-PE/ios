//
//  CurrencyItemViewModel.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/19/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class CurrencyItemViewModel {
    
    var valueUpdated: Driver<Bool> { return value.asDriver().distinctUntilChanged() }
    
    let title: String
    private let value: BehaviorRelay<Bool>
    
    init(title: String, value: BehaviorRelay<Bool>) {
        self.title = title
        self.value = value
    }
    
    func changeValue() {
        guard !value.value else { return }
        self.value.accept(!value.value)
    }
    
    func resetValue() {
        self.value.accept(false)
    }
}
