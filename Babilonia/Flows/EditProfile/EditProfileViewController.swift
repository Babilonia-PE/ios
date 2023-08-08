//
//  EditProfileViewController.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/17/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation
import FBSDKCoreKit

final class EditProfileViewController: UIViewController, AlertApplicable {
    
    let alert = ApplicationAlert()
    
    private var scrollView: UIScrollView!
    private var avatarView: UIView!
    private var photoImageView: UIImageView!
    private let avatarLoaderView: AvatarLoaderView = .init()
    private var photoFormatLabel: UILabel = .init()
    private var changePhotoButton: UIButton!
    private var saveButton: ConfirmationButton!
    private var saveButtonShadowLayer: CALayer!
    private var bottomView: UIView!
    private var bottomViewConstraint: NSLayoutConstraint?

    private let viewModel: EditProfileViewModel
    private let keyboardAnimationController = KeyboardAnimationController()
    private var imagePicker: ImagePicker!
    private var shadowApplied: Bool = false
    private var fakeProgressValue: CGFloat = 0
    private var timer: Timer?
    
    // MARK: - lifecycle
    
    init(viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        setupViews()
        setupBindings()
        
        setupNavigationBar()
        setupKeyboardAnimationController()
        
        if viewModel.isAvatarViewNeeded {
            imagePicker = ImagePicker(presentationController: self) { [weak self] image in
                guard let self = self else { return }
                if let image = image {
                    self.avatarLoaderView.isHidden = self.viewModel.screenType == .signUp
                    self.viewModel.updateAvatar(image)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !shadowApplied {
            navigationController?.navigationBar.apply(style: .shadowed)
            shadowApplied = true
        }
        keyboardAnimationController.beginTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        keyboardAnimationController.endTracking()
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard saveButtonShadowLayer == nil, saveButton.frame != .zero else { return }
        
        saveButtonShadowLayer = saveButton.layer.addShadowLayer(
            color: Asset.Colors.brickRed.color.withAlphaComponent(0.3).cgColor,
            offset: CGSize(width: 0, height: 4.0),
            radius: 6.0,
            cornerRadius: 28.0
        )
    }
    
    // MARK: - private
    
    private func layout() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.layout {
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
        }
        
        let widthView = UIView()
        scrollView.addSubview(widthView)
        widthView.layout {
            $0.top == scrollView.topAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
            $0.width == scrollView.widthAnchor
            $0.height == 0.0
        }
        
        var lastBottomView: UIView
        if viewModel.isAvatarViewNeeded {
            layoutAvatarView()
            lastBottomView = avatarView
        } else {
            lastBottomView = widthView
        }
        
        viewModel.inputFieldViewModels.forEach {
            let inputFieldView = InputFieldView(viewModel: $0)
            scrollView.addSubview(inputFieldView)
            inputFieldView.layout {
                $0.top == lastBottomView.bottomAnchor + (lastBottomView is InputFieldView ? 16.0 : 32.0)
                $0.leading == scrollView.leadingAnchor + 16.0
                $0.trailing == scrollView.trailingAnchor - 16.0
            }
            lastBottomView = inputFieldView
        }
        
        lastBottomView.layout {
            $0.bottom == scrollView.bottomAnchor
        }
        
        bottomView = UIView()
        view.addSubview(bottomView)
        bottomView.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            bottomViewConstraint = $0.bottom == view.bottomAnchor
            $0.height == 104.0
        }
        
        saveButton = ConfirmationButton()
        bottomView.addSubview(saveButton)
        saveButton.layout {
            $0.top == bottomView.topAnchor + 24.0
            $0.leading == bottomView.leadingAnchor + 12.0
            $0.trailing == bottomView.trailingAnchor - 12.0
            $0.bottom == bottomView.bottomAnchor - 24.0
        }
    }
    
    private func layoutAvatarView() {
        avatarView = UIView()
        scrollView.addSubview(avatarView)
        avatarView.layout {
            $0.top == scrollView.topAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
        }
        
        photoImageView = UIImageView()
        avatarView.addSubview(photoImageView)
        photoImageView.layout {
            $0.top == avatarView.topAnchor + 33.0
            $0.centerX == avatarView.centerXAnchor
            $0.width == 88.0
            $0.height == 88.0
        }

        avatarView.addSubview(avatarLoaderView)
        avatarLoaderView.layout {
            $0.top == avatarView.topAnchor + 33.0
            $0.centerX == avatarView.centerXAnchor
            $0.width == 88.0
            $0.height == 88.0
        }

        avatarView.addSubview(photoFormatLabel)
        photoFormatLabel.layout {
            $0.leading.equal(to: avatarView.leadingAnchor, offsetBy: 85)
            $0.trailing.equal(to: avatarView.trailingAnchor, offsetBy: -85)
            $0.top.equal(to: photoImageView.bottomAnchor, offsetBy: 12)
        }
        
        changePhotoButton = UIButton()
        avatarView.addSubview(changePhotoButton)
        changePhotoButton.layout {
            $0.top == photoFormatLabel.bottomAnchor + 12.0
            $0.centerX == avatarView.centerXAnchor
            $0.leading >= avatarView.leadingAnchor + 12.0
            $0.trailing <= avatarView.trailingAnchor - 12.0
            $0.bottom == avatarView.bottomAnchor
            $0.height == 40.0
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        if viewModel.isAvatarViewNeeded {
            setupAvatarView()
        }
        
        let saveButtonTitle = L10n.EditProfile.Buttons.Save.title.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 16.0),
            lineSpacing: 1.0,
            alignment: .center,
            color: .white,
            kern: 1
        )
        saveButton.setAttributedTitle(saveButtonTitle, for: .normal)
    }
    
    private func setupAvatarView() {
        photoImageView.layer.cornerRadius = 44.0
        photoImageView.clipsToBounds = true
        photoImageView.backgroundColor = Asset.Colors.whiteLilac.color
        photoImageView.contentMode = .scaleAspectFill

        avatarLoaderView.layerCornerRadius = 44
        avatarLoaderView.clipsToBounds = true
        avatarLoaderView.isHidden = true

        photoFormatLabel.textAlignment = .center
        photoFormatLabel.numberOfLines = 0
        photoFormatLabel.text = L10n.EditProfile.avatarFormats
        photoFormatLabel.font = FontFamily.AvenirLTStd._45Book.font(size: 12)
        photoFormatLabel.textColor = Asset.Colors.bluishGrey.color
        
        let changePhotoButtonTitle = L10n.EditProfile.Buttons.ChangePhoto.title.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 12.0),
            lineSpacing: 0.0,
            alignment: .center,
            color: Asset.Colors.vulcan.color,
            kern: 1
        )
        changePhotoButton.setAttributedTitle(changePhotoButtonTitle, for: .normal)
        changePhotoButton.layerCornerRadius = 20.0
        changePhotoButton.layerBorderWidth = 1.0
        changePhotoButton.layerBorderColor = Asset.Colors.pumice.color
        changePhotoButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 33.0, bottom: 0.0, right: 33.0)
    }
    
    private func setupBindings() {
        viewModel.requestState
            .subscribe(onNext: { [weak self] state in
                self?.handle(state)
                switch state {
                case .finished, .success, .failed:
                    self?.avatarLoaderView.isHidden = true
                default: break
                }
            })
            .disposed(by: disposeBag)
        if viewModel.isAvatarViewNeeded {
            setupAvatarViewBindings()
        }
        viewModel.fieldsAreValidUpdated
            .drive(saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        saveButton.rx.tap
            .bind(onNext: viewModel.saveProfile)
            .disposed(by: disposeBag)
        viewModel.emailCustomError
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupAvatarViewBindings() {
        viewModel.avatarImageUpdated
            .drive(onNext: { [weak photoImageView] image in
                photoImageView?.image = image
            })
            .disposed(by: disposeBag)
        viewModel.avatarUpdated
            .drive(onNext: { [weak photoImageView] urlString in
                guard let urlString = urlString else { return }
                photoImageView?.setImage(with: URL(string: urlString))
            })
            .disposed(by: disposeBag)
        changePhotoButton.rx.tap
            .bind { [weak self] in
                self?.changePhoto()
            }
            .disposed(by: disposeBag)
        viewModel.fireUploadAnimation
            .subscribe(onNext: { [weak self] in
                self?.setupAvatarUploadTimer()
            })
            .disposed(by: disposeBag)
        viewModel.avatarUploadProgress
            .subscribe(onNext: { [weak self] progress in
                self?.avatarLoaderView.updateProgress(progress)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = viewModel.navigationTitle
        let button = UIBarButtonItem(image: Asset.Common.closeIcon.image,
                                     style: .plain,
                                     target: nil,
                                     action: nil)

        button.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if self.viewModel.profileDidChange {
                    SystemAlert.present(
                        on: self,
                        title: L10n.EditProfile.ExitAlert.title,
                        message: L10n.EditProfile.ExitAlert.message,
                        confirmTitle: L10n.Buttons.Save.title,
                        declineTitle: L10n.CreateListing.Finish.Button.title,
                        confirm: { [weak self] in
                            self?.viewModel.saveProfile()
                        },
                        decline: { [weak self] in
                            self?.viewModel.close()
                        }
                    )
                } else {
                    self.viewModel.close()
                }

            })
            .disposed(by: disposeBag)
        navigationItem.leftBarButtonItem = button
    }
    
    private func changePhoto() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(
            title: L10n.ImagePicker.Camera.title,
            style: .default,
            handler: { [unowned self] _ in
                if viewModel.shouldShowCameraAlert &&
                    AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
                    self.presentCameraAccessAlert()

                    return
                }
                self.imagePicker.sourceType = .camera
                self.imagePicker.present(allowsEditing: false)
                viewModel.shouldShowCameraAlert = true
            }
        ))
        alert.addAction(UIAlertAction(
            title: L10n.ImagePicker.Gallery.title,
            style: .default,
            handler: { [unowned self] _ in
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.present()
            }
        ))
        alert.addAction(UIAlertAction(
            title: L10n.Buttons.Cancel.title,
            style: .cancel,
            handler: nil
        ))
        
        present(alert, animated: true, completion: nil)
    }

    private func presentCameraAccessAlert() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsURL),
              viewModel.shouldShowCameraAlert else { return }

        SystemAlert.present(on: self,
                            message: L10n.Popups.CameraAccess.text,
                            confirmTitle: L10n.Buttons.Settings.title,
                            declineTitle: L10n.Buttons.Cancel.title,
                            confirm: {
                                UIApplication.shared.open(settingsURL)
                            })
    }

    private func setupAvatarUploadTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.07, target: self,
                                     selector: #selector(updateProgress),
                                     userInfo: nil, repeats: true)
    }

    @objc
    private func updateProgress() {
        guard fakeProgressValue < 1 else {
            timer?.invalidate()
            timer = nil
            avatarLoaderView.isHidden = true

            return
        }
        avatarLoaderView.updateProgress(fakeProgressValue)
        fakeProgressValue += 0.1
    }
    
}

extension EditProfileViewController {

    private func setupKeyboardAnimationController() {
        keyboardAnimationController.willAnimatedKeyboardPresentation = { [unowned self] frame in
            self.scrollView.contentInset = UIEdgeInsets(
                top: 0.0,
                left: 0.0,
                bottom: frame.height + self.bottomView.frame.height,
                right: 0.0
            )
            self.bottomViewConstraint?.constant = -frame.height
        }
        keyboardAnimationController.animateKeyboardPresentation = { [unowned self] _ in
            self.view.layoutIfNeeded()
        }

        keyboardAnimationController.willAnimatedKeyboardFrameChange = { [unowned self] frame in
            self.scrollView.contentInset = UIEdgeInsets(
                top: 0.0,
                left: 0.0,
                bottom: frame.height + self.bottomView.frame.height,
                right: 0.0
            )
            self.bottomViewConstraint?.constant = -frame.height
        }
        keyboardAnimationController.animateKeyboardFrameChange = { [unowned self] _ in
            self.view.layoutIfNeeded()
        }

        keyboardAnimationController.willAnimatedKeyboardDismissal = { [unowned self] _ in
            self.scrollView.contentInset = .zero
            self.bottomViewConstraint?.constant = 0.0
        }
        keyboardAnimationController.animateKeyboardDismissal = { [unowned self] _ in
            self.view.layoutIfNeeded()
        }
    }
    
    func userCreated() {
        AppEvents.logEvent(AppEvents.Name("CompleteRegistration"))
    }

}
