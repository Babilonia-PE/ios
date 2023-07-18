//
//  CheckoutViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 24.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation
import Stripe
import RxSwift
import RxCocoa

final class CheckoutViewModel {

    var requestState: Observable<RequestState> {
        model.requestState.asObservable().observeOn(MainScheduler.instance)
    }
    var paymentModel: ListingPaymentModel {
        model.paymentModel
    }
    lazy var cvcViewModel: InputFieldViewModel = {
        let cvcVelue = BehaviorRelay(value: "")
        cvcVelue
            .subscribe(onNext: { [weak self] value in self?.cvc = value })
            .disposed(by: disposeBag)
        let viewiewModel = InputFieldViewModel(
            title: BehaviorRelay(value: L10n.Payments.Checkout.cvc.uppercased()),
            text: cvcVelue,
            validator: CVCValidator(),
            editingMode: .text,
            image: nil,
            placeholder: nil,
            keyboardType: .numberPad,
            autocorrectionType: .no,
            isDefaultOnDismiss: true
        )

        return viewiewModel
    }()
    lazy var expirationViewModel: InputFieldViewModel = {
        let expirationValue = BehaviorRelay(value: "")
        expirationValue
            .map { (Int($0.expirationMonth()), Int($0.expirationYear())) }
            .subscribe(onNext: { [weak self] values in
                self?.expirationMonth = values.0
                self?.expirationYear = values.1
            })
            .disposed(by: disposeBag)
        let viewiewModel = InputFieldViewModel(
            title: BehaviorRelay(value: L10n.Payments.Checkout.experationDatePlaceholder),
            text: expirationValue,
            validator: CardExpirationDateValidator(),
            editingMode: .text,
            image: nil,
            placeholder: nil,
            keyboardType: .numberPad,
            autocorrectionType: .no,
            isDefaultOnDismiss: true
        )

        return viewiewModel
    }()
    lazy var cardNameViewModel: InputFieldViewModel = {
        let viewiewModel = InputFieldViewModel(
            title: BehaviorRelay(value: L10n.Payments.Checkout.cardName),
            text: BehaviorRelay(value: ""),
            validator: CardNameValidator(),
            editingMode: .text,
            image: nil,
            placeholder: nil,
            keyboardType: .default,
            autocapitalizationType: .allCharacters,
            autocorrectionType: .no,
            isDefaultOnDismiss: true
        )

        return viewiewModel
    }()

    private var cvc = ""
    private var expirationMonth: Int?
    private var expirationYear: Int?

    private let model: CheckoutModel
    private let disposeBag = DisposeBag()
    
    init(model: CheckoutModel) {
        self.model = model
    }

    func checkout(with cardParams: STPPaymentMethodCardParams,
                  authenticationContext: STPAuthenticationContext) {
        guard let expMonth = expirationMonth,
              let expYear = expirationYear,
              !cvc.isEmpty else { return }

        cardParams.cvc = cvc
        cardParams.expMonth = NSNumber(value: expMonth)
        cardParams.expYear = NSNumber(value: expYear)
        model.checkout(with: cardParams, authenticationContext: authenticationContext)
    }
    
}
