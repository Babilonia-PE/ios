//
//  AuthViewModel.swift
//  Babilonia
//
//  Created by Denis on 5/31/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class AuthViewModel {
    
    var requestState: Observable<RequestState> { return model.requestState.asObservable() }
    
    private let model: AuthModel
    
    init(model: AuthModel) {
        self.model = model
    }
    
//    func login(with token: String) {
//        model.login(with: token)
//    }
    
    func login() {
        model.login()
    }
    
    func loginGuest() {
        model.loginGuest()
    }
    
    func signUp() {
        model.signUp()
    }
}
