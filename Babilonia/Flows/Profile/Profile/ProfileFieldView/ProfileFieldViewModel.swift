//
//  ProfileFieldViewModel.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/10/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Core

final class ProfileFieldViewModel {
    
    var selectedValueUpdated: Driver<String?> { return selectedValue.asDriver() }

    private(set) var title: String
    private var selectedValue: BehaviorRelay<String?>
    
    init(title: String, selectedValue: String? = nil) {
        self.title = title
        self.selectedValue = BehaviorRelay(value: selectedValue)
    }
    
    func updateSelected(value: String?) {
        selectedValue.accept(value)
    }
}
