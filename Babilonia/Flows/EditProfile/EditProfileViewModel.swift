//
//  EditProfileViewModel.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/17/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

enum EditProfileType {
    case editProfile, editEmail, signUp
}

final class EditProfileViewModel {
    
    var requestState: Observable<RequestState> {
        return model.requestState.asObservable().observeOn(MainScheduler.instance)
    }
    
    var fieldsAreValidUpdated: Driver<Bool> {
        return Driver
            .combineLatest(inputFieldViewModels.map { $0.validationDriver })
            .map { $0.allSatisfy({ $0 }) }
    }
    
    var navigationTitle: String {
        switch screenType {
        case .editProfile:
            return L10n.EditProfile.title
        case .editEmail:
            return L10n.EditProfile.ChangeEmail.title
        case .signUp:
            return L10n.SignUp.title
        }
    }
    var shouldShowCameraAlert: Bool {
        get { model.shouldShowCameraAlert }
        set { model.shouldShowCameraAlert = newValue }
    }
    
    var isAvatarViewNeeded: Bool { screenType != .editEmail }
    
    var avatarUpdated: Driver<String?> { model.avatarUpdated }
    var avatarImageUpdated: Driver<UIImage?> { model.avatarImageUpdated }
    var profileDidChange: Bool { model.profileDidChange }
    var fireUploadAnimation: Observable<Void> { model.fireUploadAnimation.asObservable() }
    var avatarUploadProgress: Observable<CGFloat> { model.avatarUploadProgress.asObservable() }
    var emailCustomError: Observable<String?> { model.emailCustomError.asObservable() }
    
    var screenType: EditProfileType { model.screenType }
    private let model: EditProfileModel
    private let disposeBag = DisposeBag()
    private(set) var inputFieldViewModels = [InputFieldViewModel]()
    
    private lazy var firstNameViewModel: InputFieldViewModel = {
        let firstName = BehaviorRelay(value: model.initialFirstName())
        firstName.bind(onNext: model.updateFirstName)
            .disposed(by: disposeBag)
        var title = L10n.EditProfile.FirstName.title
        if screenType == .signUp {
            title += "*"
        }
        let viewiewModel = InputFieldViewModel(
            title: BehaviorRelay(value: title),
            text: firstName,
            validator: ProfileNameValidator(),
            editingMode: .text,
            image: nil,
            placeholder: nil,
            keyboardType: .default,
            autocorrectionType: .no
        )
        
        return viewiewModel
    }()
    
    private lazy var lastNameViewModel: InputFieldViewModel = {
        let lastName = BehaviorRelay(value: model.initialLastName())
        lastName.bind(onNext: model.updateLastName)
            .disposed(by: disposeBag)
        var title = L10n.EditProfile.LastName.title
        if screenType == .signUp {
            title += "*"
        }
        let viewModel = InputFieldViewModel(
            title: BehaviorRelay(value: title),
            text: lastName,
            validator: ProfileNameValidator(),
            editingMode: .text,
            image: nil,
            placeholder: nil,
            keyboardType: .default,
            autocorrectionType: .no
        )
        
        return viewModel
    }()
    
    private lazy var emailViewModel: InputFieldViewModel = {
        let email = BehaviorRelay(value: model.initialEmail())
        email.bind(onNext: model.updateEmail)
            .disposed(by: disposeBag)
        var title = L10n.Profile.Email.title
        if screenType == .signUp {
            title += "*"
        }
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
    
    // MARK: - lifecycle
    
    init(model: EditProfileModel) {
        self.model = model
        
        setupFormFields()
    }
    
    func saveProfile() {
        switch screenType {
        case .editProfile:
            model.saveProfile(isEmailUpdated: false)
        case .editEmail:
            model.saveProfile(isEmailUpdated: true)
        case .signUp:
            model.createProfile()
        }
    }
    
    func updateAvatar(_ image: UIImage?) {
        model.updateAvatarImage(image)
    }
    
    func close() {
        switch screenType {
        case .editProfile, .editEmail:
            model.close()
        case .signUp:
            model.cancelCreating()
        }
    }
    
    // MARK: - private
    
    private func setupFormFields() {
        
        switch screenType {
        case .editProfile:
            inputFieldViewModels = [firstNameViewModel, lastNameViewModel]
        case .editEmail:
            inputFieldViewModels = [emailViewModel]
        case .signUp:
            inputFieldViewModels = [firstNameViewModel, lastNameViewModel, emailViewModel]
        }

        emailCustomError
            .subscribe(onNext: { [weak self] error in
                guard let error = error else { return }
                
                self?.emailViewModel.setCustomError(error: error)
            })
            .disposed(by: disposeBag)
    }
    
}
