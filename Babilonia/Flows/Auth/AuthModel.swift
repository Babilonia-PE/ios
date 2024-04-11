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
    case signUp([PhonePrefix])
    case cancelLogIn(String)
    case cancelSignUp(String)
}

final class AuthModel: EventNode {
    
    let requestState = PublishSubject<RequestState>()
    var newVersionUpdated: Driver<NewVersion> { return newVersion.asDriver() }
    private let newVersion: BehaviorRelay<NewVersion>
    
    private let userSessionController: UserSessionController
    private let configService: ConfigurationsService
    
    deinit {
        configService.removeObserver(self)
    }
    
    init(parent: EventNode, userSessionController: UserSessionController, configService: ConfigurationsService) {
        self.userSessionController = userSessionController
        self.configService = configService
        self.newVersion = BehaviorRelay(value: configService.appConfigs?.newVersion ?? NewVersion(update: false))
        
        super.init(parent: parent)
        configService.addObserver(self)
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
    
    func requestPrefixes() {
        requestState.onNext(.started)
        userSessionController.getPhonePrefixes { [weak self] phonePrefixes in
            guard let self else { return }
            self.requestState.onNext(.finished)
            raise(event: AuthEvent.signUp(phonePrefixes))
        }
    }
    
    func validateVersion() {
        guard let version = configService.appConfigs?.newVersion else { return }
        newVersion.accept(version)
    }
}

extension AuthModel: NewVersionObserver {
    
    func newVersionChanged(_ newVersion: NewVersion) {
        self.newVersion.accept(newVersion)
    }
}
