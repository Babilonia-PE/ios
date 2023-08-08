//
//  AuthLogInModel.swift
//  Babilonia
//
//  Created by Owson on 1/12/22.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import RxSwift
import RxCocoa
import Core

final class AuthLogInModel: EventNode {
    private let email: BehaviorRelay<String>
    private let password: BehaviorRelay<String>
    
    let requestState = PublishSubject<RequestState>()
    let emailCustomError = PublishRelay<String?>()
    
    private let userSessionController: UserSessionController
    
    // MARK: - lifecycle
    init(parent: EventNode, userSessionController: UserSessionController) {
        self.userSessionController = userSessionController
        
        email = BehaviorRelay(value: "")
        password = BehaviorRelay(value: "")
        
        super.init(parent: parent)
    }
    
    // MARK: - public
    func initialEmail() -> String {
        return email.value
    }
    
    func updateEmail(_ email: String) {
        self.email.accept(email)
    }
    
    func initialPassword() -> String {
        return password.value
    }
    
    func updatePassword(_ password: String) {
        self.password.accept(password)
    }
    
    func logIn() {
        requestState.onNext(.started)
        
        userSessionController.logInAccount(
            email: email.value.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password.value.trimmingCharacters(in: .whitespacesAndNewlines),
            ipAddress: NetworkUtil.getWiFiAddress() ?? "",
            userAgent: "ios",
            signProvider: "email"
        ) { [weak self] result in
            guard let self = self else { return }
            self.requestState.onNext(.finished)

            switch result {
            case .success(let session):
                self.raise(event: AuthEvent.signIn(session))
            case .failure(let error):
                self.requestState.onNext(.failed(error))
            }
        }
    }
    
    func cancel() {
        raise(event: AuthEvent.cancelLogIn(""))
    }
}
