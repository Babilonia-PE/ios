//
//  AuthSignUpViewController.swift
//  Babilonia
//
//  Created by Owson on 17/11/22.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit
//import CountryPickerView

class AuthSignUpViewController: UIViewController, AlertApplicable, SpinnerApplicable {
    let alert = ApplicationAlert()
    let spinner = AppSpinner()
    
    private var scrollView: UIScrollView!
    private var bottomView: UIView!
    private var saveButton: ConfirmationButton!
    private var saveButtonShadowLayer: CALayer!
    private var cancelButton: Button!
    private var cancelButtonShadowLayer: CALayer!
    private var countryButton: Button!
    private var countryButtonShadowLayer: CALayer!
    
    private let viewModel: AuthSignUpViewModel
    private let keyboardAnimationController = KeyboardAnimationController()
    private var shadowApplied: Bool = false
    
    //private let countryPickerView = CountryPickerView()
    
    init(viewModel: AuthSignUpViewModel) {
         self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        //setupCountry()
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
//    private func setupCountry() {
//        var countryCode = "PE"
//        if let code = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String {
//            countryCode = code
//        }
//        self.viewModel.setCountry(
//            countryCode,
//            dialCode: countryPickerView.getCountryByCode(countryCode)?.phoneCode ?? ""
//        )
//    }
    
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

        //var phoneViewModel: InputFieldViewModel?
        
        viewModel.inputFieldViewModels.forEach {
//            let title = $0.getTitle()
//            if title == L10n.SignUp.Phone.title {
//                phoneViewModel = $0
//                return
//            }
            let inputFieldView = InputFieldView(viewModel: $0)
            scrollView.addSubview(inputFieldView)
            inputFieldView.layout {
                $0.top == lastBottomView.bottomAnchor + (lastBottomView is InputFieldView ? 16.0 : 32.0)
                $0.leading == scrollView.leadingAnchor + 24.0
                $0.trailing == scrollView.trailingAnchor - 24.0
            }
            lastBottomView = inputFieldView
        }
        
//        if let viewModel = phoneViewModel {
//            let phoneView = UIView()
//            scrollView.addSubview(phoneView)
//            phoneView.layout {
//                $0.top == lastBottomView.bottomAnchor + (lastBottomView is InputFieldView ? 16.0 : 32.0)
//                $0.leading == scrollView.leadingAnchor + 24.0
//                $0.trailing == scrollView.trailingAnchor - 24.0
//                $0.height == 60
//            }
//            self.setupPhoneView(parentView: phoneView, viewModel: viewModel)
//            lastBottomView = phoneView
//        }

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
    
//    private func setupPhoneView(parentView: UIView, viewModel: InputFieldViewModel) {
//        countryButton = Button(with: .none)
//        parentView.addSubview(countryButton)
//        countryButton.layout {
//            //$0.centerY == parentView.centerYAnchor
//            $0.top == parentView.topAnchor
//            $0.bottom == parentView.bottomAnchor
//            $0.leading == parentView.leadingAnchor
//            $0.width == 80.0
//        }
//
//        let inputFieldView = InputFieldView(viewModel: viewModel)
//        parentView.addSubview(inputFieldView)
//        inputFieldView.layout {
//            $0.top == parentView.topAnchor
//            $0.bottom == parentView.bottomAnchor
//            $0.leading == countryButton.trailingAnchor + 8.0
//            $0.trailing == parentView.trailingAnchor
//        }
//    }
    
    private func setupViews() {
        view.backgroundColor = Asset.Colors.biscay.color
        
        let saveButtonTitle = L10n.Buttons.Save.title.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 16.0),
            lineSpacing: 1.0,
            alignment: .center,
            color: .white,
            kern: 1
        )
        saveButton.setAttributedTitle(saveButtonTitle, for: .normal)
        
        let cancelButtonTitle = L10n.Buttons.Cancel.title.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 16.0),
            lineSpacing: 1.0,
            alignment: .center,
            color: .white,
            kern: 1,
            underlineStyle: .single
        )
        cancelButton.setAttributedTitle(cancelButtonTitle, for: .normal)
        
        //self.setupPhoneButtonView()
    }
    
//    private func setupPhoneButtonView() {
//        let countryButtonTitle = self.viewModel.countryDialCode.toAttributed(
//            with: FontFamily.SamsungSharpSans.bold.font(size: 16.0),
//            lineSpacing: 1.0,
//            alignment: .left,
//            color: .white,
//            kern: 1
//        )
//        if let country = countryPickerView.getCountryByCode(self.viewModel.countryCode) {
//            countryButton.setImage(country.flag, for: .normal)
//        }
//        countryButton.imageView?.contentMode = .scaleAspectFit
//        countryButton.imageEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 40)
//        countryButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        countryButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        countryButton.setAttributedTitle(countryButtonTitle, for: .normal)
//    }
    
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
            .bind(onNext: viewModel.createProfile)
            .disposed(by: disposeBag)
        cancelButton.rx.tap
            .bind(onNext: viewModel.cancel)
            .disposed(by: disposeBag)
        viewModel.emailCustomError
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
//        countryButton.rx.tap
//            .bind(onNext: self.showCountryList)
//            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //countryPickerView.delegate = self
        //countryPickerView.dataSource = self
    }
    
//    func showCountryList() {
//        countryPickerView.showCountriesList(from: self)
//    }
}

//extension AuthSignUpViewController: CountryPickerViewDelegate {
//    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
//        self.viewModel.setCountry(country.code, dialCode: country.phoneCode)
//        self.setupPhoneButtonView()
//    }
//}

//extension AuthSignUpViewController: CountryPickerViewDataSource {
//
//    func preferredCountries(in countryPickerView: CountryPickerView) -> [Country] {
//        let codes = [
//            "+54",
//            "+55",
//            "+56",
//            "+57",
//            "+593",
//            "+1",
//            "+52",
//            "+595",
//            "+51",
//            "+598"
//        ]
//        return codes.compactMap { countryPickerView.getCountryByPhoneCode($0) }
//    }
//
//    func sectionTitleForPreferredCountries(in countryPickerView: CountryPickerView) -> String? {
//        return L10n.SignUp.CountryList.title
//    }
//
//    func showOnlyPreferredSection(in countryPickerView: CountryPickerView) -> Bool {
//        return true
//    }
//
//    func showPhoneCodeInList(in countryPickerView: CountryPickerView) -> Bool {
//        return true
//    }
//
//    func searchBarPosition(in countryPickerView: CountryPickerView) -> SearchBarPosition {
//        return .hidden
//    }
//}
