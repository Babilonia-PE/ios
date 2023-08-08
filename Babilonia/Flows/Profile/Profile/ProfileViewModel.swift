//
//  ProfileViewModel.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileViewModel {
    
    var canRefreshUser: Bool = true
    var isUserGuest: Bool = false
    var userUpdated: Driver<Void> { return model.userUpdated.map { _ in } }
    
    private(set) var avatarURLString: String?
    private(set) var avatarImage: UIImage?
    private(set) var name: String!
    private(set) var emailViewModel: ProfileUserDataViewModel!
    private(set) var phoneViewModel: ProfileUserDataViewModel!
    private(set) var currencyViewModel = ProfileFieldViewModel(title: L10n.Profile.Currency.title)
    private(set) var accountViewModel = ProfileFieldViewModel(title: L10n.Profile.Account.title)
    private(set) var termsViewModel = ProfileFieldViewModel(title: L10n.Profile.About.Terms.title)
    private(set) var privacyViewModel = ProfileFieldViewModel(title: L10n.Profile.About.Privacy.title)
    private(set) var loginViewModel = ProfileFieldViewModel(title: "Ingresar")
    private var disposeBag = DisposeBag()
    
    private let phoneFormatter = PhoneNumberTextFormatter()
    
    private let model: ProfileModel
    
    // MARK: - lifecycle
    
    init(model: ProfileModel) {
        self.model = model
        
        setupBindings()
    }
    
    func refreshUser() {
        model.refreshUser()
    }
    
    func editProfile() {
        model.editProfile()
    }
    
    func editEmail() {
        model.editEmail()
    }
    
    func editPhoneNumber() {
        model.editPhoneNumber()
    }
    
    func openAccount() {
        model.openAccount()
    }
    
    func openCurrencies() {
        model.openCurrencies()
    }
    
    func updateUser(_ user: User, avatarImage: UIImage?) {
        self.avatarImage = avatarImage
        model.updateUser(user)
    }
    
    func openTerms() {
        model.openTerms()
    }
    
    func openPrivacy() {
        model.openPrivacy()
    }
    
    func openLogin() {
        model.openLogin()
    }
    // MARK: - private
    
    private func setupBindings() {
        model.userUpdated
            .drive(onNext: { [weak self] user in
                guard let self = self else { return }
                self.isUserGuest = user.id == .guest
                self.avatarURLString = user.avatar?.smallURLString
                self.name = user.fullName
                self.emailViewModel = ProfileUserDataViewModel(
                    title: L10n.Profile.Email.title,
                    dataValue: user.email,
                    isActive: true
                )
                self.phoneViewModel = ProfileUserDataViewModel(
                    title: L10n.Profile.Phone.title,
                    dataValue: self.phoneFormatter.formatted(user.phoneNumber ?? ""),
                    isActive: true
                )
            })
            .disposed(by: disposeBag)
        
        model.currentCurrencyUpdated
            .drive(onNext: { [weak currencyViewModel] currency in
                currencyViewModel?.updateSelected(value: currency.code)
            })
            .disposed(by: disposeBag)
    }
}
