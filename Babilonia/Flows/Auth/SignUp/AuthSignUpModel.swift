//
//  AuthSignUpModel.swift
//  Babilonia
//
//  Created by Owson on 17/11/22.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import RxSwift
import RxCocoa
import Core

final class AuthSignUpModel: EventNode {
    private let fullName: BehaviorRelay<String>
    //private let lastName: BehaviorRelay<String>
    private let email: BehaviorRelay<String>
    private let password: BehaviorRelay<String>
    private let phone: BehaviorRelay<String>
    
    var countryCode = ""
    var countryDialCode = ""
    
    let requestState = PublishSubject<RequestState>()
    let emailCustomError = PublishRelay<String?>()
    
    private let userSessionController: UserSessionController
    
    // MARK: - lifecycle
    init(parent: EventNode, userSessionController: UserSessionController) {
        self.userSessionController = userSessionController
        
        fullName = BehaviorRelay(value: "")
        //lastName = BehaviorRelay(value: "")
        email = BehaviorRelay(value: "")
        password = BehaviorRelay(value: "")
        phone = BehaviorRelay(value: "")
        
        super.init(parent: parent)
    }
    
    // MARK: - public
    func initialFullName() -> String {
        return fullName.value
    }
    
    func updateFullName(_ fullName: String) {
        self.fullName.accept(fullName)
    }
    
//    func initialLastName() -> String {
//        return lastName.value
//    }
    
//    func updateLastName(_ lastName: String) {
//        self.lastName.accept(lastName)
//    }
    
    func initialEmail() -> String {
        return email.value
    }
    
    func updateEmail(_ email: String) {
        self.email.accept(email)
    }
    
    func initialPhone() -> String {
        return phone.value
    }

    func updatePhone(_ phone: String) {
        self.phone.accept(phone)
    }
    
    func initialPassword() -> String {
        return password.value
    }
    
    func updatePassword(_ password: String) {
        self.password.accept(password)
    }
    
    func createProfile() {
        requestState.onNext(.started)
        userSessionController.createAccount(
            fullName: fullName.value.trimmingCharacters(in: .whitespacesAndNewlines),
            //lastName: lastName.value.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.value.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password.value.trimmingCharacters(in: .whitespacesAndNewlines),
            //phonePrefix: countryDialCode.trimmingCharacters(in: .whitespacesAndNewlines),
            phoneNumber: phone.value.trimmingCharacters(in: .whitespacesAndNewlines),
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
                if self.isEmailAlreadyTaken(error) {
                    self.emailCustomError.accept(error.localizedDescription)
                } else {
                    self.requestState.onNext(.failed(error))
                }
            }
        }
    }
    
    private func isEmailAlreadyTaken(_ error: Error?) -> Bool {
        guard let serverError = error as? CompositeServerError,
              let code = serverError.errors.first?.code else { return false }

        return code == .alreadyExist
    }
    
    func cancel() {
        raise(event: AuthEvent.cancelSignUp(""))
    }
}
