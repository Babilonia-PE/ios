//
//  AuthSignUpViewModel.swift
//  Babilonia
//
//  Created by Owson on 17/11/22.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class AuthSignUpViewModel {
    private let disposeBag = DisposeBag()
    private let model: AuthSignUpModel
    private(set) var inputFieldViewModels = [InputFieldViewModel]()
    
    var countryCode: String { return model.countryCode }
    var countryDialCode: String { return model.countryDialCode }
    
    var emailCustomError: Observable<String?> { model.emailCustomError.asObservable() }
    
    var requestState: Observable<RequestState> {
        return model.requestState.asObservable().observeOn(MainScheduler.instance)
    }
    var fieldsAreValidUpdated: Driver<Bool> {
        return Driver
            .combineLatest(inputFieldViewModels.map { $0.validationDriver })
            .map { $0.allSatisfy({ $0 }) }
    }
    
    private lazy var fullNameViewModel: InputFieldViewModel = {
        let fullName = BehaviorRelay(value: model.initialFullName())
        fullName.bind(onNext: model.updateFullName)
            .disposed(by: disposeBag)
        var title = L10n.SignUp.FullName.title
        //if screenType == .signUp {
            title += "*"
        //}
        let viewiewModel = InputFieldViewModel(
            title: BehaviorRelay(value: title),
            text: fullName,
            validator: ProfileNameValidator(),
            editingMode: .text,
            image: nil,
            placeholder: nil,
            keyboardType: .default,
            autocorrectionType: .no
        )
        
        return viewiewModel
    }()
    
//    private lazy var lastNameViewModel: InputFieldViewModel = {
//        let lastName = BehaviorRelay(value: model.initialLastName())
//        lastName.bind(onNext: model.updateLastName)
//            .disposed(by: disposeBag)
//        var title = L10n.SignUp.LastName.title
//        //if screenType == .signUp {
//            title += "*"
//        //}
//        let viewModel = InputFieldViewModel(
//            title: BehaviorRelay(value: title),
//            text: lastName,
//            validator: ProfileNameValidator(),
//            editingMode: .text,
//            image: nil,
//            placeholder: nil,
//            keyboardType: .default,
//            autocorrectionType: .no
//        )
//
//        return viewModel
//    }()
    
    private lazy var emailViewModel: InputFieldViewModel = {
        let email = BehaviorRelay(value: model.initialEmail())
        email.bind(onNext: model.updateEmail)
            .disposed(by: disposeBag)
        var title = L10n.SignUp.Email.title
        //if screenType == .signUp {
            title += "*"
        //}
        let viewModel = InputFieldViewModel(
            title: BehaviorRelay(value: title),
            text: email,
            validator: EmailValidator(),
            editingMode: .text,
            image: nil,
            placeholder: nil,
            keyboardType: .emailAddress,
            autocapitalizationType: .none,
            autocorrectionType: .no
        )
        
        return viewModel
    }()
    
    private lazy var phoneViewModel: InputFieldViewModel = {
        let phone = BehaviorRelay(value: model.initialPhone())
        phone.bind(onNext: model.updatePhone)
            .disposed(by: disposeBag)
        let title = L10n.SignUp.Phone.title
        //if screenType == .signUp {
            //title += "*"
        //}
        let viewModel = InputFieldViewModel(
            title: BehaviorRelay(value: title),
            text: phone,
            validator: EmptyPhoneNumberValidator(),
            editingMode: .text,
            image: nil,
            placeholder: nil,
            keyboardType: .phonePad,
            autocapitalizationType: .none,
            autocorrectionType: .no
        )

        return viewModel
    }()
    
    private lazy var passwordViewModel: InputFieldViewModel = {
        let password = BehaviorRelay(value: model.initialPassword())
        password.bind(onNext: model.updatePassword)
            .disposed(by: disposeBag)
        var title = L10n.SignUp.Password.title
        //if screenType == .signUp {
            title += "*"
        //}
        let viewModel = InputFieldViewModel(
            title: BehaviorRelay(value: title),
            text: password,
            validator: NotEmptyValidator(),
            editingMode: .text,
            image: nil,
            placeholder: nil,
            keyboardType: .default,
            autocorrectionType: .no,
            isSecureText: true
        )
        
        return viewModel
    }()
    
    // MARK: - lifecycle
    init(model: AuthSignUpModel) {
        self.model = model
        
        setupFormFields()
    }
    
    // MARK: - public
    func createProfile() {
        model.createProfile()
    }
    
    func cancel() {
        model.cancel()
    }
    
    func setCountry(_ code: String, dialCode: String) {
        model.countryDialCode = dialCode
        model.countryCode = code
    }
    
    // MARK: - private
    private func setupFormFields() {
        inputFieldViewModels = [
            fullNameViewModel,
            //lastNameViewModel,
            emailViewModel,
            passwordViewModel,
            phoneViewModel
        ]
        
        emailCustomError
            .subscribe(onNext: { [weak self] error in
                guard let error = error else { return }
                
                self?.emailViewModel.setCustomError(error: error)
            })
            .disposed(by: disposeBag)
    }
}
