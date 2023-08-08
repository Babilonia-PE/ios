//
//  AuthLogInViewModel.swift
//  Babilonia
//
//  Created by Owson on 1/12/22.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class AuthLogInViewModel {
    private let disposeBag = DisposeBag()
    private let model: AuthLogInModel
    private(set) var inputFieldViewModels = [InputFieldViewModel]()
    
    var emailCustomError: Observable<String?> { model.emailCustomError.asObservable() }
    
    var requestState: Observable<RequestState> {
        return model.requestState.asObservable().observeOn(MainScheduler.instance)
    }
    var fieldsAreValidUpdated: Driver<Bool> {
        return Driver
            .combineLatest(inputFieldViewModels.map { $0.validationDriver })
            .map { $0.allSatisfy({ $0 }) }
    }
    
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
    init(model: AuthLogInModel) {
        self.model = model
        
        setupFormFields()
    }
    
    // MARK: - public
    func logIn() {
        model.logIn()
    }
    
    func cancel() {
        model.cancel()
    }
    
    // MARK: - private
    private func setupFormFields() {
        inputFieldViewModels = [
            emailViewModel,
            passwordViewModel
        ]
        
        emailCustomError
            .subscribe(onNext: { [weak self] error in
                guard let error = error else { return }
                
                self?.emailViewModel.setCustomError(error: error)
            })
            .disposed(by: disposeBag)
    }
}
