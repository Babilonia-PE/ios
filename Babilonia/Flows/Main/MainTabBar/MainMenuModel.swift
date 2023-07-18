//
//  MainMenuModel.swift
//
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation
import Core

enum MainMenuEvent: Event {
    case logout
    case createListing
    case openMyListings
}

final class MainMenuModel: EventNode {
    
    func logOut() {
        raise(event: MainMenuEvent.logout)
    }
    
    func createListing() {
        raise(event: MainMenuEvent.createListing)
    }
    
    func openMyListings() {
        raise(event: MainMenuEvent.openMyListings)
    }
    
}
