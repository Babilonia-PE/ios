//
//  AccountModel.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/15/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import RxSwift
import RxCocoa
import Core

enum AccountEvent: Event {
    case logout
    case close
}

final class AccountModel: EventNode {
    
    private let userService: UserService
    
    init(parent: EventNode, userService: UserService) {
        self.userService = userService
        super.init(parent: parent)
    }
    
    func logout() {
        raise(event: AccountEvent.logout)
    }
    
    func deleteAccount() {
        userService.deleteAccount { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                self.logout()
            case .failure(let error):
                if self.isUnauthenticated(error) {
                    self.raise(event: MainFlowEvent.logout)
                }
            }
        }
    }
    
    func close() {
        raise(event: AccountEvent.close)
    }
             
    private func isUnauthenticated(_ error: Error?) -> Bool {
        guard let serverError = error as? CompositeServerError,
            let code = serverError.errors.first?.code else { return false }
      
        return code == .unauthenticated
    }
}
