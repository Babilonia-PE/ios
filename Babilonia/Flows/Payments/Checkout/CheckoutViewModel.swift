//
//  CheckoutViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 24.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation
//import Stripe
import RxSwift
import RxCocoa

final class CheckoutViewModel {

    var requestState: Observable<RequestState> {
        model.requestState.asObservable().observeOn(MainScheduler.instance)
    }
    var paymentModel: ListingPaymentModel {
        model.paymentModel
    }
    
    lazy var cardValueViewModel: InputFieldViewModel = {
        let cardValue = BehaviorRelay(value: "")
        cardValue
            .subscribe(onNext: { [weak self] value in self?.card = value.replacingOccurrences(of: " ", with: "") })
            .disposed(by: disposeBag)
        let viewiewModel = InputFieldViewModel(
            title: BehaviorRelay(value: "Número de tarjeta"),
            text: cardValue,
            validator: CardValueValidator(),
            editingMode: .text,
            image: nil,
            placeholder: nil,
            keyboardType: .numberPad,
            autocorrectionType: .no,
            isDefaultOnDismiss: true
        )

        return viewiewModel
    }()
    
    lazy var cvcViewModel: InputFieldViewModel = {
        let cvcValue = BehaviorRelay(value: "")
        cvcValue
            .subscribe(onNext: { [weak self] value in self?.cvc = value })
            .disposed(by: disposeBag)
        let viewiewModel = InputFieldViewModel(
            title: BehaviorRelay(value: L10n.Payments.Checkout.cvc.uppercased()),
            text: cvcValue,
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
        let cardName = BehaviorRelay(value: "")
        cardName
            .subscribe(onNext: { [weak self] value in self?.cardName = value })
            .disposed(by: disposeBag)
        
        let viewiewModel = InputFieldViewModel(
            title: BehaviorRelay(value: L10n.Payments.Checkout.cardName),
            text: cardName,
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
    private var card = ""
    private var cardName = ""
    private var expirationMonth: Int?
    private var expirationYear: Int?
    private let model: CheckoutModel
    private let disposeBag = DisposeBag()
    
    init(model: CheckoutModel) {
        self.model = model
    }

    func checkout() {
        guard let expMonth = expirationMonth,
              let expYear = expirationYear,
              !cvc.isEmpty,
              !cardName.isEmpty,
              !card.isEmpty else { return }
        let expMonthString = expMonth < 10 ? "0\(expMonth)" : "\(expMonth)"
        model.checkoutPayu(cardNumber: card,
                           cardCvv: cvc,
                           cardExpiration: "\(expMonthString)/\(expYear)",
                           cardName: cardName)
    }
}
