//
//  AccountViewModel.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/15/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

final class AccountViewModel {
    
    private(set) var signOutViewModel = ProfileFieldViewModel(title: L10n.Profile.Account.SignOut.title)
    
    private(set) var deleteAccountViewModel = ProfileFieldViewModel(title: L10n.Profile.Account.DeleteAccount.title)
    
    private let model: AccountModel
    
    init(model: AccountModel) {
        self.model = model
    }
    
    func logout() {
        model.logout()
    }
    
    func deleteAccount() {
        model.deleteAccount()
    }
    
    func close() {
        model.close()
    }
    
}
