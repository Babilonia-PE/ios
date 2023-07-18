//
//  AccountModel.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/15/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

enum AccountEvent: Event {
    case logout
    case close
}

final class AccountModel: EventNode {
    
    func logout() {
        raise(event: AccountEvent.logout)
    }
    
    func close() {
        raise(event: AccountEvent.close)
    }
    
}
