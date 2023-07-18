//
//  TempMyListingsModel.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

enum TempMyListingsEvent: Event {
    case createListing
}

final class TempMyListingsModel: EventNode {
    
    func createListing() {
        raise(event: TempMyListingsEvent.createListing)
    }
    
}
