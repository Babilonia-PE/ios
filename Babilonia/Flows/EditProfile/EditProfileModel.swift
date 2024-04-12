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
import YALAPIClient

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
        return fullName.value != userSession.user.fullName ?? ""
//        return firstName.value != userSession.user.firstName ?? "" ||
//            lastName.value != userSession.user.lastName ?? ""
    }
    var shouldShowCameraAlert: Bool {
        get { appSettingsStore.cameraAlertDidShow }
        set { appSettingsStore.cameraAlertDidShow = newValue }
    }

    private var avatar: UIImage?
    private var avatarUploadAtOnce = false
    
    private let fullName: BehaviorRelay<String>
    //private let lastName: BehaviorRelay<String>
    private let avatarURLString: BehaviorRelay<String?>
    private let avatarImage: BehaviorRelay<UIImage?>
    private let email: BehaviorRelay<String>
    private let photoId: BehaviorRelay<Int?>
    private let phoneNumber: BehaviorRelay<String>
    
    private let userService: UserService
    private let userSession: UserSession
    private let appSettingsStore: AppSettingsStore = UserDefaults()
    
    private let imagesService: ImagesService
    
    private var cancellationsMap = [Int: YALAPIClient.Cancelable]()
    
    // Corregir
    let phonePrefixes: [PhonePrefix] = []
    
    // MARK: - lifecycle
    
    init(parent: EventNode,
         userSession: UserSession,
         userService: UserService,
         imagesService: ImagesService,
         screenType: EditProfileType) {
        self.imagesService = imagesService
        self.userService = userService
        self.userSession = userSession
        self.screenType = screenType
        
        fullName = BehaviorRelay(value: userSession.user.fullName ?? "")
        //lastName = BehaviorRelay(value: userSession.user.lastName ?? "")
        avatarURLString = BehaviorRelay(value: userSession.user.avatar?.renderURLString)
        avatarImage = BehaviorRelay(value: userSession.user.avatar == nil ? Asset.Profile.userPlaceholder.image : nil)
        email = BehaviorRelay(value: userSession.user.email ?? "")
        photoId = BehaviorRelay(value: nil)
        phoneNumber = BehaviorRelay(value: userSession.user.phoneNumber ?? "")
        
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
    
    func initialFullName() -> String {
        return fullName.value
    }
    
    func updateFullName(_ fullName: String) {
        self.fullName.accept(fullName)
    }
    
//    func initialLastName() -> String {
//        return lastName.value
//    }
//
//    func updateLastName(_ lastName: String) {
//        self.lastName.accept(lastName)
//    }
    
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
    
    func initialPhoneNumber() -> String {
        return phoneNumber.value
    }
    
    func updatePhoneNumber(_ phoneNumber: String) {
        self.phoneNumber.accept(phoneNumber)
    }
    
    func createProfile() {
        requestState.onNext(.started)
        
        var user = userSession.user!
        user.fullName = fullName.value
        //user.lastName = lastName.value
        user.email = email.value
        
        userService.updateProfile(
            fullName: fullName.value.trimmingCharacters(in: .whitespacesAndNewlines),
            //lastName: lastName.value.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.value
            //image: avatar
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.requestState.onNext(.finished)
                self.raise(event: CreateProfileEvent.userCreated(userSession: self.userSession))
            case .failure(let error):
                if self.isEmailAlreadyTaken(error) {
                    self.emailCustomError.accept(error.localizedDescription)
                } else if self.isUnauthenticated(error) {
                    self.raise(event: MainFlowEvent.logout)
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
        user.fullName = fullName.value
        //user.lastName = lastName.value
        user.email = email.value
        user.phoneNumber = phoneNumber.value
        
        refresh(user: user)
        
        userService.updateProfile(
            fullName: fullName.value.trimmingCharacters(in: .whitespacesAndNewlines),
            //lastName: lastName.value.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.value,
            photoId: photoId.value,
            phoneNumber: phoneNumber.value
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
                } else if self.isUnauthenticated(error) {
                    self.raise(event: MainFlowEvent.logout)
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
        
        if let image = avatar {
            let user = userSession.user!
            let uploadCancellable = imagesService.uploadImage(image, type: "profile") { [weak self] result in
                guard let self = self else { return }
                
                self.cancellationsMap.removeValue(forKey: user.id)
                
                switch result {
                case .success(let images):
                    self.photoId.accept(images[0].id)
                    self.requestState.onNext(.success(L10n.EditProfile.UpdateAvatar.Popup.Success.text))
                case .failure(let error):
                    if self.isUnauthenticated(error) {
                        self.raise(event: MainFlowEvent.logout)
                    }
                    self.requestState.onNext(.failed(error))
                }
                
            }
            if let cancellable = uploadCancellable {
                cancellationsMap[user.id] = cancellable
            }
        }

//        let user = userSession.user!
//        userService.updateProfile(firstName: user.firstName,
//                                  lastName: user.lastName,
//                                  email: user.email,
//                                  image: avatar,
//                                  progressHandler: progressHandler) { result in
//            self.raise(event: EditProfileEvent.updateRefreshMode(isOn: true))
//
//            switch result {
//            case .success:
//                self.requestState.onNext(.success(L10n.EditProfile.UpdateAvatar.Popup.Success.text))
//            case .failure(let error):
//                if self.isUnauthenticated(error) {
//                    self.raise(event: MainFlowEvent.logout)
//                } else {
//                    self.refresh(user: self.userSession.user)
//                    self.requestState.onNext(.failed(error))
//                }
//            }
//        }
    }
    
    func refresh(user: User) {
        raise(event: EditProfileEvent.refresh(user: user, avatar: avatarImage.value))
    }
    
    func close() {
        raise(event: EditProfileEvent.close)
    }

    // MARK: - private
    
    private func isEmailAlreadyTaken(_ error: Error?) -> Bool {
        guard let serverError = error as? CompositeServerError,
              let code = serverError.errors.first?.code else { return false }

        return code == .alreadyExist
    }
    
    private func isUnauthenticated(_ error: Error?) -> Bool {
        guard let serverError = error as? CompositeServerError,
              let code = serverError.errors.first?.code else { return false }
        
        return code == .unauthenticated
    }
}
