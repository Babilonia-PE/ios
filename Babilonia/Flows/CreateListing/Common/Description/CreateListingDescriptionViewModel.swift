//
//  CreateListingDescriptionViewModel.swift
//  Babilonia
//
//  Created by Denis on 6/7/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class CreateListingDescriptionViewModel {
    
    var countText: Driver<String> {
        return model.textUpdated.map { [unowned self] text in
            return "(\(text.count)/\(self.model.maxSymbolsCount))"
        }
    }
    
    var initialText: String { return model.initialText }
    var maxSymbolsCount: Int { model.maxSymbolsCount }
    
    private let model: CreateListingDescriptionModel
    
    init(model: CreateListingDescriptionModel) {
        self.model = model
    }
    
    func updateText(_ text: String) {
        model.updateText(text)
    }
    
    func back() {
        model.back()
    }
    
    func done() {
        model.done()
    }
    
}
