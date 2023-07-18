//
//  CheckoutViewController.swift
//  Babilonia
//
//  Created by Alya Filon  on 24.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Stripe

final class CheckoutViewController: NiblessViewController, AlertApplicable, SpinnerApplicable, HasCustomView {
    
    typealias CustomView = CheckoutView
    
    let alert = ApplicationAlert()
    let spinner = AppSpinner()
    
    private let viewModel: CheckoutViewModel
    
    init(viewModel: CheckoutViewModel) {
         self.viewModel = viewModel
        
        super.init()
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        let customView = CustomView()
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        setupView() 
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        customView.paymentField.resignFirstResponder()
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        customView.checkoutButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                self.viewModel.checkout(with: self.customView.paymentField.cardParams,
                                        authenticationContext: self)
            })
            .disposed(by: disposeBag)

        viewModel.requestState
            .subscribe(onNext: { [weak self] state in
                self?.handle(state)
                switch state {
                case .started:
                    self?.showSpinner()
                default:
                    self?.hideSpinner()
                }
            })
            .disposed(by: disposeBag)
    }

    private func setupView() {
        title = L10n.Payments.Checkout.title
        
        customView.apply(model: viewModel.paymentModel)
        customView.setupInputsFields(cvcViewModel: viewModel.cvcViewModel,
                                     expirationViewModel: viewModel.expirationViewModel,
                                     cardNameViewModel: viewModel.cardNameViewModel)
    }

}

extension CheckoutViewController: STPAuthenticationContext {

    func authenticationPresentingViewController() -> UIViewController {
        return self
    }

}
