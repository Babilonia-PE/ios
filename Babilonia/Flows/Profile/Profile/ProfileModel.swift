//
//  ProfileModel.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import RxSwift
import RxCocoa
import Core

enum ProfileEvent: Event {
    case editProfile
    case editEmail
    case editPhoneNumber
    case open(link: String, title: String)
    case openCurrencies
    case openAccount
}

final class ProfileModel: EventNode {
    
    var userUpdated: Driver<User> { return user.asDriver() }
    
    var currentCurrencyUpdated: Driver<Currency> { return currentCurrency.asDriver() }
    
    private let currentCurrency: BehaviorRelay<Currency>
    private let user: BehaviorRelay<User>
    
    private let userSession: UserSession
    private let userService: UserService
    private let configService: ConfigurationsService
    
    // MARK: - lifecycle
    
    deinit {
        configService.removeObserver(self)
    }
    
    init(parent: EventNode, userSession: UserSession, userService: UserService, configService: ConfigurationsService) {
        self.userSession = userSession
        self.userService = userService
        self.configService = configService
        
        user = BehaviorRelay(value: userSession.user)
        currentCurrency = BehaviorRelay(value: configService.currency)
        
        super.init(parent: parent)
        
        configService.addObserver(self)
    }
    
    func editProfile() {
        raise(event: ProfileEvent.editProfile)
    }
    
    func editEmail() {
        raise(event: ProfileEvent.editEmail)
    }
    
    func editPhoneNumber() {
        raise(event: ProfileEvent.editPhoneNumber)
    }
    
    func openAccount() {
        raise(event: ProfileEvent.openAccount)
    }
    
    func openCurrencies() {
        raise(event: ProfileEvent.openCurrencies)
    }
    
    func updateUser(_ user: User) {
        self.user.accept(user)
    }
    
    func openTerms() {
        guard let link = configService.appConfigs?.termsURLString else { return }
        raise(event: ProfileEvent.open(link: link, title: L10n.Profile.About.Terms.title))
    }
    
    func openPrivacy() {
        guard let link = configService.appConfigs?.privacyURLString else { return }
        raise(event: ProfileEvent.open(link: link, title: L10n.Profile.About.Privacy.title))
    }
    
    func openLogin() {
        raise(event: MainFlowEvent.logoutAndLogin)
    }
    
    func refreshUser() {
        userService.getProfile { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.user.accept(user)
            case .failure(let error):
                if self.isUnauthenticated(error) {
                    self.raise(event: MainFlowEvent.logout)
                }
            }
        }
    }
    
    private func isUnauthenticated(_ error: Error?) -> Bool {
        guard let serverError = error as? CompositeServerError,
              let code = serverError.errors.first?.code else { return false }
        
        return code == .unauthenticated
    }
    
    // MARK: - currency observing
    
    func addCurrencyObserver(_ observer: CurrencyObserver) {
        configService.addObserver(observer)
    }
    
    func removeCurrencyObserver(_ observer: CurrencyObserver) {
        configService.removeObserver(observer)
    }
    
}

extension ProfileModel: CurrencyObserver {
    
    func currencyChanged(_ currency: Currency) {
        currentCurrency.accept(currency)
    }
    
}
