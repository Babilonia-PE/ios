//
//  CreateListingModelUpdatable.swift
//  Babilonia
//
//  Created by Denis on 6/25/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Core

typealias UpdateListingBlock = (inout Listing) -> Void

protocol CreateListingModelUpdatable {
    
    var updateListingCallback: ((UpdateListingBlock, Bool) -> Void)? { get }
    
}

extension CreateListingModelUpdatable {
    
    func fetchListing(_ update: UpdateListingBlock) {
        updateListingCallback?(update, false)
    }
    
    func updateListing(_ update: UpdateListingBlock) {
        updateListingCallback?(update, true)
    }
    
}
