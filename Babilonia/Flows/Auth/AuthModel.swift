//
//  AuthModel.swift
//  Babilonia
//
//  Created by Denis on 5/31/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Core
import RxCocoa
import RxSwift

enum AuthEvent: Event {
    case signIn(UserSession)
    case logIn(String)
    case signUp(String)
    case cancelLogIn(String)
    case cancelSignUp(String)
}

final class AuthModel: EventNode {
    
    let requestState = PublishSubject<RequestState>()
    
    private let userSessionController: UserSessionController
    
    init(parent: EventNode, userSessionController: UserSessionController) {
        self.userSessionController = userSessionController
        
        super.init(parent: parent)
    }
    
//    func login(with token: String) {
//        requestState.onNext(.started)
//        userSessionController.openSession(token) { [weak self] result in
//            guard let self = self else { return }
//            self.requestState.onNext(.finished)
//
//            switch result {
//            case .success(let session):
//                self.raise(event: AuthEvent.signIn(session))
//
//            case .failure(let error):
//                self.requestState.onNext(.failed(error))
//            }
//        }
//    }
    
    func login() {
        raise(event: AuthEvent.logIn(""))
    }
    
    func loginGuest() {
        requestState.onNext(.started)
        let session = userSessionController.openSessionGuest()
        raise(event: AuthEvent.signIn(session))
    }
    
    func signUp() {
        raise(event: AuthEvent.signUp(""))
    }
}
