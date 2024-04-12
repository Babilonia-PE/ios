//
//  AuthViewController.swift
//  Babilonia
//
//  Created by Denis on 5/31/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FirebasePhoneAuthUI

final class AuthViewController: UIViewController, AlertApplicable, SpinnerApplicable {
    
    let alert = ApplicationAlert()
    let spinner = AppSpinner()
    var autoPhoneAuth: Bool = false {
        didSet {
            if autoPhoneAuth {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self](_) in
                    self?.presentLogIn()
                }
            }
        }
    }
    private let viewModel: AuthViewModel
    private var signUpButton: UIButton = .init()
    private var logInButton: UIButton = .init()
    private var guestButton: UIButton = .init()
    
    private var bindingsSet = false
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // MARK: - lifecycle
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        setupViews()
        setupBindings()
        initObservers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)

        super.viewWillDisappear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - private
    
    private func layout() {
        let logoImage = UIImageView()
        logoImage.image = Asset.Splash.logo.image
        view.addSubview(logoImage)
        logoImage.layout {
            $0.centerX == view.centerXAnchor
            $0.centerY == view.centerYAnchor
            $0.leading >= view.leadingAnchor + 8.0
            $0.trailing <= view.trailingAnchor - 8.0
        }
        
        view.addSubview(guestButton)
        guestButton.layout {
            $0.leading == view.leadingAnchor + 24.0
            $0.trailing == view.trailingAnchor - 24.0
            $0.bottom == view.bottomAnchor - 24.0
            $0.height == 56.0
        }
        
        view.addSubview(logInButton)
        logInButton.layout {
            $0.top >= logoImage.bottomAnchor + 8.0
            $0.leading == view.leadingAnchor + 24.0
            $0.trailing == view.trailingAnchor - 24.0
            $0.bottom == guestButton.topAnchor - 5.0
            $0.height == 56.0
        }
        
        view.addSubview(signUpButton)
        signUpButton.layout {
            $0.top >= logoImage.bottomAnchor + 8.0
            $0.leading == view.leadingAnchor + 24.0
            $0.trailing == view.trailingAnchor - 24.0
            $0.bottom == logInButton.topAnchor - 16.0
            $0.height == 56.0
        }
    }
    
    private func setupViews() {
        view.backgroundColor = Asset.Colors.biscay.color
        
        let signUpButtonTitle = L10n.Start.SignUpButton.title.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 16.0),
            alignment: .center,
            color: .white,
            kern: 1
        )
        signUpButton.setAttributedTitle(signUpButtonTitle, for: .normal)
        signUpButton.titleEdgeInsets = UIEdgeInsets(top: 2.0, left: 0.0, bottom: 0.0, right: 0.0)
        signUpButton.backgroundColor = Asset.Colors.mandy.color
        signUpButton.layer.cornerRadius = 28.0
        signUpButton.layer.addShadowLayer(
            color: Asset.Colors.mandy.color.withAlphaComponent(0.3).cgColor,
            offset: CGSize(width: 0, height: 4),
            radius: 6.0,
            cornerRadius: 28.0
        )
        
        let loginButtonTitle = L10n.Start.LogInButton.title.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 16.0),
            alignment: .center,
            color: .white,
            kern: 1
        )
        logInButton.setAttributedTitle(loginButtonTitle, for: .normal)
        logInButton.titleEdgeInsets = UIEdgeInsets(top: 2.0, left: 0.0, bottom: 0.0, right: 0.0)
        logInButton.backgroundColor = Asset.Colors.mandy.color
        logInButton.layer.cornerRadius = 28.0
        logInButton.layer.addShadowLayer(
            color: Asset.Colors.mandy.color.withAlphaComponent(0.3).cgColor,
            offset: CGSize(width: 0, height: 4),
            radius: 6.0,
            cornerRadius: 28.0
        )
        
        let guestTitle = L10n.Skip.Button.title.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 16.0),
            alignment: .center,
            color: .white,
            kern: 1,
            underlineStyle: .single
        )
        
        guestButton.setAttributedTitle(guestTitle, for: .normal)
        guestButton.titleEdgeInsets = UIEdgeInsets(top: 2.0, left: 0.0, bottom: 0.0, right: 0.0)
        guestButton.layer.cornerRadius = 28.0
        guestButton.layer.addShadowLayer(
            color: Asset.Colors.mandy.color.withAlphaComponent(0.3).cgColor,
            offset: CGSize(width: 0, height: 4),
            radius: 6.0,
            cornerRadius: 28.0
        )
    }
    
    private func setupBindings() {
        bind(requestState: viewModel.requestState)
        
        viewModel.newVersionUpdated
            .drive(onNext: { [weak self] value in
                if value.update ?? false {
                    self?.presentSignOut()
                }
                print("//==//")
                print(value.update)
            })
            .disposed(by: disposeBag)
        
        viewModel.requestState.isLoading
            .bind { [weak self] value in
                self?.updateLoadingState(value)
            }
            .disposed(by: disposeBag)
        
        signUpButton.rx.tap
            .bind(onNext: presentSignUp)
            .disposed(by: disposeBag)
        
        logInButton.rx.tap
            .bind(onNext: presentLogIn)
            .disposed(by: disposeBag)
        
        guestButton.rx.tap
            .bind(onNext: loginAsGuest)
            .disposed(by: disposeBag)
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            spinner.show(on: view, text: nil, blockUI: true)
        } else {
            spinner.hide(from: view)
        }
    }
    
//    private func presentPhoneAuth() {
//        let authUI = FUIAuth.defaultAuthUI()
//        let phoneProvider = FUIPhoneAuth(authUI: FUIAuth.defaultAuthUI()!)
//        authUI?.delegate = self
//        authUI?.providers = [phoneProvider]
//        phoneProvider.signIn(withPresenting: self, phoneNumber: nil)
//    }
    
    private func presentSignUp() {
        viewModel.signUp()
    }
    
    private func presentLogIn() {
        viewModel.login()
    }
    
    private func loginAsGuest() {
        viewModel.loginGuest()
    }
    
    private func presentSignOut() {
        SystemAlert.present(on: self,
                            title: L10n.Popups.ForceUpdate.title,
                            message: L10n.Popups.ForceUpdate.text,
                            confirmTitle: L10n.Popups.ForceUpdate.ForceUpdate.title,
                            declineTitle: L10n.Buttons.Cancel.title,
                            confirm: { [weak self] in
            self?.openAppStore()
        })
    }
    
    private func openAppStore() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1472174345") {
            UIApplication.shared.open(url)
        }
    }
    
    private func initObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func willEnterForeground() {
        viewModel.viewWillAppear()
    }
}

//extension AuthViewController: FUIAuthDelegate {
//
//    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
//        if let error = error {
//            //canceled auth
//            guard (error as NSError).code != 1 else { return }
//
//            showDefaultAlert(with: .error, message: error.localizedDescription)
//        } else if let authResult = authDataResult {
//            authResult.user.getIDToken { [weak self] token, error in
//                if let error = error {
//                    self?.showDefaultAlert(with: .error, message: error.localizedDescription)
//                } else {
//                    self?.viewModel.login(with: token ?? "")
//                }
//            }
//        } else {
//            showDefaultAlert(with: .error, message: L10n.Errors.somethingWentWrong)
//        }
//    }
//}
