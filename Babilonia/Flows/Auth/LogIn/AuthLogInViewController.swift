//
//  AuthLogInViewController.swift
//  Babilonia
//
//  Created by Owson on 1/12/22.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit

class AuthLogInViewController: UIViewController, AlertApplicable, SpinnerApplicable {
    let alert = ApplicationAlert()
    let spinner = AppSpinner()
    
    private var scrollView: UIScrollView!
    private var bottomView: UIView!
    private var saveButton: ConfirmationButton!
    private var saveButtonShadowLayer: CALayer!
    private var cancelButton: Button!
    private var cancelButtonShadowLayer: CALayer!
    
    private let viewModel: AuthLogInViewModel
    private let keyboardAnimationController = KeyboardAnimationController()
    private var shadowApplied: Bool = false
    
    init(viewModel: AuthLogInViewModel) {
         self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        setupViews()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if !shadowApplied {
            navigationController?.navigationBar.apply(style: .shadowed)
            shadowApplied = true
        }
        keyboardAnimationController.beginTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - private
    private func layout() {
        bottomView = UIView()
        view.addSubview(bottomView)
        bottomView.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
            $0.height == 140.0
        }
        
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.layout {
            $0.top == view.topAnchor
            $0.bottom == bottomView.topAnchor
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
        
        var lastBottomView: UIView = widthView
        
        let logoImage = UIImageView()
        logoImage.image = Asset.Splash.logo.image
        scrollView.addSubview(logoImage)
        logoImage.layout {
            $0.top == lastBottomView.bottomAnchor + 72.0
            $0.leading >= scrollView.leadingAnchor + 8.0
            $0.trailing <= scrollView.trailingAnchor - 8.0
            $0.centerX == scrollView.centerXAnchor
        }
        lastBottomView = logoImage

        viewModel.inputFieldViewModels.forEach {
            let inputFieldView = InputFieldView(viewModel: $0)
            scrollView.addSubview(inputFieldView)
            inputFieldView.layout {
                $0.top == lastBottomView.bottomAnchor + (lastBottomView is InputFieldView ? 16.0 : 32.0)
                $0.leading == scrollView.leadingAnchor + 24.0
                $0.trailing == scrollView.trailingAnchor - 24.0
            }
            lastBottomView = inputFieldView
        }

        lastBottomView.layout {
            $0.bottom == scrollView.bottomAnchor
        }

        saveButton = ConfirmationButton()
        bottomView.addSubview(saveButton)
        saveButton.layout {
            $0.top == bottomView.topAnchor + 8.0
            $0.leading == bottomView.leadingAnchor + 24.0
            $0.trailing == bottomView.trailingAnchor - 24.0
            $0.height == 50.0
        }
        
        cancelButton = Button(with: .none)
        bottomView.addSubview(cancelButton)
        cancelButton.layout {
            $0.height == 50.0
            $0.leading == bottomView.leadingAnchor + 24.0
            $0.trailing == bottomView.trailingAnchor - 24.0
            $0.bottom == bottomView.bottomAnchor - 24.0
        }
    }
    
    private func setupViews() {
        view.backgroundColor = Asset.Colors.biscay.color
        
        /*if viewModel.isAvatarViewNeeded {
            setupAvatarView()
        }*/
        
        let loginButtonTitle = L10n.Buttons.Login.title.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 16.0),
            lineSpacing: 1.0,
            alignment: .center,
            color: .white,
            kern: 1
        )
        saveButton.setAttributedTitle(loginButtonTitle, for: .normal)
        
        let cancelButtonTitle = L10n.Buttons.Cancel.title.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 16.0),
            lineSpacing: 1.0,
            alignment: .center,
            color: .white,
            kern: 1,
            underlineStyle: .single
        )
        cancelButton.setAttributedTitle(cancelButtonTitle, for: .normal)
    }
    
    private func setupBindings() {
        viewModel.requestState
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                self.handle(state)
                switch state {
                case.started:
                    self.spinner.show(on: self.view, text: nil, blockUI: false)
                default:
                    self.hideSpinner()
                }
            })
            .disposed(by: disposeBag)
        viewModel.fieldsAreValidUpdated
            .drive(saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        saveButton.rx.tap
            .bind(onNext: viewModel.logIn)
            .disposed(by: disposeBag)
        cancelButton.rx.tap
            .bind(onNext: viewModel.cancel)
            .disposed(by: disposeBag)
        viewModel.emailCustomError
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
