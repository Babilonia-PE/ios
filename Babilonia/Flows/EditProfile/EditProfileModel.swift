//
//  EditProfileModel.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/17/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import RxSwift
import RxCocoa
import Core

typealias User = Core.User

enum CreateProfileEvent: Event {
    case userCreated(userSession: UserSession)
    case cancel
}

enum EditProfileEvent: Event {
    case refresh(user: User, avatar: UIImage?)
    case updateRefreshMode(isOn: Bool)
    case close
}

final class EditProfileModel: EventNode {
    
    var avatarUpdated: Driver<String?> { return avatarURLString.asDriver() }
    var avatarImageUpdated: Driver<UIImage?> { return avatarImage.asDriver() }
    let fireUploadAnimation = PublishRelay<Void>()
    let avatarUploadProgress = PublishRelay<CGFloat>()
    let emailCustomError = PublishRelay<String?>()
    let screenType: EditProfileType

    var progressHandler: ((Progress) -> Void)?
    
    let requestState = PublishSubject<RequestState>()
    var profileDidChange: Bool {
        return firstName.value != userSession.user.firstName ?? "" ||
            lastName.value != userSession.user.lastName ?? ""
    }
    var shouldShowCameraAlert: Bool {
        get { appSettingsStore.cameraAlertDidShow }
        set { appSettingsStore.cameraAlertDidShow = newValue }
    }

    private var avatar: UIImage?
    private var avatarUploadAtOnce = false
    
    private let firstName: BehaviorRelay<String>
    private let lastName: BehaviorRelay<String>
    private let avatarURLString: BehaviorRelay<String?>
    private let avatarImage: BehaviorRelay<UIImage?>
    private let email: BehaviorRelay<String>
    
    private let userService: UserService
    private let userSession: UserSession
    private let appSettingsStore: AppSettingsStore = UserDefaults()
    
    // MARK: - lifecycle
    
    init(parent: EventNode,
         userSession: UserSession,
         userService: UserService,
         screenType: EditProfileType) {
        self.userService = userService
        self.userSession = userSession
        self.screenType = screenType
        
        firstName = BehaviorRelay(value: userSession.user.firstName ?? "")
        lastName = BehaviorRelay(value: userSession.user.lastName ?? "")
        avatarURLString = BehaviorRelay(value: userSession.user.avatar?.mediumURLString)
        avatarImage = BehaviorRelay(value: userSession.user.avatar == nil ? Asset.Profile.userPlaceholder.image : nil)
        email = BehaviorRelay(value: userSession.user.email ?? "")
        
        super.init(parent: parent)
    }

    private func setupProgressHandler() {
        progressHandler = { [weak self] progress in
            guard self?.avatarUploadAtOnce == false else {
                self?.avatarUploadProgress.accept(CGFloat(progress.fractionCompleted))

                return
            }
            self?.avatarUploadAtOnce = progress.fractionCompleted == 1

            if self?.avatarUploadAtOnce == true {
                self?.fireUploadAnimation.accept(())
                self?.progressHandler = nil
            } else {
                self?.avatarUploadProgress.accept(CGFloat(progress.fractionCompleted))
            }
        }
    }
    
    func initialFirstName() -> String {
        return firstName.value
    }
    
    func updateFirstName(_ firstName: String) {
        self.firstName.accept(firstName)
    }
    
    func initialLastName() -> String {
        return lastName.value
    }
    
    func updateLastName(_ lastName: String) {
        self.lastName.accept(lastName)
    }
    
    func updateAvatarImage(_ image: UIImage?) {
        avatar = image
        avatarImage.accept(image)

        if screenType != .signUp {
            updateAvatar()
        }
    }
    
    func initialEmail() -> String {
        return email.value
    }
    
    func updateEmail(_ email: String) {
        self.email.accept(email)
    }
    
    func createProfile() {
        requestState.onNext(.started)
        
        var user = userSession.user!
        user.firstName = firstName.value
        user.lastName = lastName.value
        user.email = email.value
        
        userService.updateProfile(
            firstName: firstName.value.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.value.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.value,
            image: avatar
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.requestState.onNext(.finished)
                self.raise(event: CreateProfileEvent.userCreated(userSession: self.userSession))
            case .failure(let error):
                if self.isEmailAlreadyTaken(error) {
                    self.emailCustomError.accept(error.localizedDescription)
                } else {
                    self.requestState.onNext(.failed(error))
                }
            }
        }
        
    }
    
    func cancelCreating() {
        raise(event: CreateProfileEvent.cancel)
    }
    
    func saveProfile(isEmailUpdated: Bool) {
        requestState.onNext(.started)
        raise(event: EditProfileEvent.updateRefreshMode(isOn: false))
        
        var user = userSession.user!
        user.firstName = firstName.value
        user.lastName = lastName.value
        user.email = email.value
        
        refresh(user: user)
        
        userService.updateProfile(
            firstName: firstName.value.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.value.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.value
        ) { result in
            self.raise(event: EditProfileEvent.updateRefreshMode(isOn: true))
            
            switch result {
            case .success:
                let message: String
                if isEmailUpdated {
                    message = L10n.EditProfile.UpdateEmail.Popup.Success.text
                } else {
                    message = L10n.EditProfile.UpdateUser.Popup.Success.text
                }
                self.requestState.onNext(.success(message))
                self.close()
            case .failure(let error):
                self.refresh(user: self.userSession.user)
                if isEmailUpdated {
                    self.emailCustomError.accept(error.localizedDescription)
                } else {
                    self.requestState.onNext(.failed(error))
                }
            }
        }
    }

    func updateAvatar() {
        avatarUploadAtOnce = false
        setupProgressHandler()
        requestState.onNext(.started)
        raise(event: EditProfileEvent.updateRefreshMode(isOn: false))

        let user = userSession.user!
        userService.updateProfile(firstName: user.firstName,
                                  lastName: user.lastName,
                                  email: user.email,
                                  image: avatar,
                                  progressHandler: progressHandler) { result in
            self.raise(event: EditProfileEvent.updateRefreshMode(isOn: true))

            switch result {
            case .success:
                self.requestState.onNext(.success(L10n.EditProfile.UpdateAvatar.Popup.Success.text))
            case .failure(let error):
                self.refresh(user: self.userSession.user)
                self.requestState.onNext(.failed(error))
            }
        }
    }
    
    func refresh(user: User) {
        raise(event: EditProfileEvent.refresh(user: user, avatar: avatarImage.value))
    }
    
    func close() {
        raise(event: EditProfileEvent.close)
    }

    private func isEmailAlreadyTaken(_ error: Error?) -> Bool {
        guard let serverError = error as? CompositeServerError,
              let code = serverError.errors.first?.code else { return false }

        return code == .alreadyExist
    }
    
}
