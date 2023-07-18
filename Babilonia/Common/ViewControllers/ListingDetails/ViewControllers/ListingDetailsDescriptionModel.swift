//
//  ListingDetailsDescriptionModel.swift
//  Babilonia
//
//  Created by Denis on 7/16/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

enum ListingDetailsDescriptionEvent: Event {
    case back
}

final class ListingDetailsDescriptionModel: EventNode {
    
    let descriptionString: String
    
    init(parent: EventNode, descriptionString: String) {
        self.descriptionString = descriptionString
        
        super.init(parent: parent)
    }
    
    func back() {
        raise(event: ListingDetailsDescriptionEvent.back)
    }
    
}
