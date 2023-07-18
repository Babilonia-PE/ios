//
//  CreateListingDescriptionModel.swift
//  Babilonia
//
//  Created by Denis on 6/7/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import RxSwift
import RxCocoa

enum CreateListingDescriptionEvent: Event {
    case back, done
}

final class CreateListingDescriptionModel: EventNode {
    
    var textUpdated: Driver<String> { return text.asDriver() }
    let initialText: String
    let maxSymbolsCount: Int
    
    private let text: BehaviorRelay<String>
    private let textUpdateHandler: ((String) -> Void)
    
    init(
        parent: EventNode,
        textUpdateHandler: @escaping ((String) -> Void),
        initialText: String,
        maxSymbolsCount: Int
    ) {
        self.textUpdateHandler = textUpdateHandler
        text = BehaviorRelay(value: initialText)
        self.initialText = initialText
        self.maxSymbolsCount = maxSymbolsCount
        
        super.init(parent: parent)
    }
    
    func updateText(_ text: String) {
        self.text.accept(text)
    }
    
    func back() {
        raise(event: CreateListingDescriptionEvent.back)
    }
    
    func done() {
        textUpdateHandler(text.value.trimmingCharacters(in: .whitespacesAndNewlines))
        raise(event: CreateListingDescriptionEvent.done)
    }
    
}
