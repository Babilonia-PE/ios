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
import FirebaseUI

final class AuthViewController: UIViewController, AlertApplicable, SpinnerApplicable {
    
    let alert = ApplicationAlert()
    let spinner = AppSpinner()
    
    private let viewModel: AuthViewModel
    private var startButton: UIButton!
    
    // MARK: - lifecycle
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        setupViews()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        startButton = UIButton()
        view.addSubview(startButton)
        startButton.layout {
            $0.top >= logoImage.bottomAnchor + 8.0
            $0.leading == view.leadingAnchor + 24.0
            $0.trailing == view.trailingAnchor - 24.0
            $0.bottom == view.bottomAnchor - 36.0
            $0.height == 56.0
        }
    }
    
    private func setupViews() {
        view.backgroundColor = Asset.Colors.biscay.color
        
        let buttonTitle = L10n.Start.Button.title.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 16.0),
            alignment: .center,
            color: .white,
            kern: 1
        )
        startButton.setAttributedTitle(buttonTitle, for: .normal)
        startButton.titleEdgeInsets = UIEdgeInsets(top: 2.0, left: 0.0, bottom: 0.0, right: 0.0)
        startButton.backgroundColor = Asset.Colors.mandy.color
        startButton.layer.cornerRadius = 28.0
        startButton.layer.addShadowLayer(
            color: Asset.Colors.mandy.color.withAlphaComponent(0.3).cgColor,
            offset: CGSize(width: 0, height: 4),
            radius: 6.0,
            cornerRadius: 28.0
        )
    }
    
    private func setupBindings() {
        bind(requestState: viewModel.requestState)
        
        viewModel.requestState.isLoading
            .bind { [weak self] value in
                self?.updateLoadingState(value)
            }
            .disposed(by: disposeBag)
        
        startButton.rx.tap
            .bind(onNext: presentPhoneAuth)
            .disposed(by: disposeBag)
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            spinner.show(on: view, text: nil, blockUI: true)
        } else {
            spinner.hide(from: view)
        }
    }
    
    private func presentPhoneAuth() {        
        let authUI = FUIAuth.defaultAuthUI()
        let phoneProvider = FUIPhoneAuth(authUI: FUIAuth.defaultAuthUI()!)
        authUI?.delegate = self
        authUI?.providers = [phoneProvider]
        phoneProvider.signIn(withPresenting: self, phoneNumber: nil)
    }
}

extension AuthViewController: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
            //canceled auth
            guard (error as NSError).code != 1 else { return } 

            showDefaultAlert(with: .error, message: error.localizedDescription)
        } else if let authResult = authDataResult {
            authResult.user.getIDToken { [weak self] token, error in
                if let error = error {
                    self?.showDefaultAlert(with: .error, message: error.localizedDescription)
                } else {
                    self?.viewModel.login(with: token ?? "")
                }
            }
        } else {
            showDefaultAlert(with: .error, message: L10n.Errors.somethingWentWrong)
        }
    }
}
