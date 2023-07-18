//
//  CheckoutView.swift
//  Babilonia
//
//  Created by Alya Filon  on 24.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import Stripe
import RxSwift
import RxCocoa

final class CheckoutView: NiblessView {

    let checkoutButton: ConfirmationButton = .init()
    let paymentField: STPPaymentCardNumberTextField = .init()
    private let productImageView: UIImageView = .init()
    private let productLabel: UILabel = .init()
    private let daysLabel: UILabel = .init()
    private let priceLabel: UILabel = .init()
    private let priceStackView: UIStackView = .init()
    private let planStackView: UIStackView = .init()
    private var cvcInputFieldView: InputFieldView!
    private var expirationInputFieldView: InputFieldView!
    private var cardNameInputFieldView: InputFieldView!

    private var cvcViewModel: InputFieldViewModel!
    private var expirationViewModel: InputFieldViewModel!
    private var cardNameViewModel: InputFieldViewModel!

    private let disposeBag = DisposeBag()

    override init() {
        super.init()

        setupView()
    }

    func apply(model: ListingPaymentModel) {
        productLabel.text = model.title
        productLabel.textColor = model.color
        priceLabel.text = model.price
        daysLabel.text = model.days
        productImageView.image = model.icon

        checkoutButton.setTitle(L10n.Payments.Checkout.pay(model.price).uppercased(), for: .normal)
    }

    func setupInputsFields(cvcViewModel: InputFieldViewModel,
                           expirationViewModel: InputFieldViewModel,
                           cardNameViewModel: InputFieldViewModel) {
        self.cvcViewModel = cvcViewModel
        self.expirationViewModel = expirationViewModel
        self.cardNameViewModel = cardNameViewModel

        cvcInputFieldView = InputFieldView(viewModel: cvcViewModel)
        expirationInputFieldView = InputFieldView(viewModel: expirationViewModel)
        cardNameInputFieldView = InputFieldView(viewModel: cardNameViewModel)

        setupFieldsLayout()
        setupBindings()
    }

}

extension CheckoutView {

    private func setupFieldsLayout() {
        addSubviews(cvcInputFieldView, expirationInputFieldView, cardNameInputFieldView)

        cvcInputFieldView.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.top.equal(to: paymentField.bottomAnchor, offsetBy: 16)
            $0.height.equal(to: 56)
        }

        expirationInputFieldView.layout {
            $0.leading.equal(to: cvcInputFieldView.trailingAnchor, offsetBy: 7)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.top.equal(to: paymentField.bottomAnchor, offsetBy: 16)
            $0.height.equal(to: 56)
            $0.width.equal(to: cvcInputFieldView.widthAnchor)
        }

        cardNameInputFieldView.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.top.equal(to: cvcInputFieldView.bottomAnchor, offsetBy: 16)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.height.equal(to: 56)
        }
    }

    private func setupView() {
        backgroundColor = .white

        planStackView.axis = .horizontal
        planStackView.spacing = 7
        planStackView.alignment = .center

        addSubviews(planStackView)
        planStackView.layout {
            $0.top.equal(to: safeAreaLayoutGuide.topAnchor, offsetBy: 24)
            $0.centerX.equal(to: centerXAnchor)
        }

        productImageView.contentMode = .scaleAspectFit
        planStackView.addArrangedSubview(productImageView)
        productImageView.layout { $0.height.equal(to: 22) }

        productLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 16)
        planStackView.addArrangedSubview(productLabel)

        priceStackView.axis = .horizontal
        priceStackView.spacing = 8
        priceStackView.alignment = .bottom

        addSubview(priceStackView)
        priceStackView.layout {
            $0.top.equal(to: planStackView.bottomAnchor, offsetBy: 12)
            $0.centerX.equal(to: centerXAnchor)
            $0.height.equal(to: 41)
        }

        priceLabel.textColor = Asset.Colors.watermelon.color
        priceLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 34)
        priceStackView.addArrangedSubview(priceLabel)

        daysLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 16)
        daysLabel.textColor = Asset.Colors.bluishGrey.color
        priceStackView.addArrangedSubview(daysLabel)
        daysLabel.layout { $0.height.equal(to: 24) }

        setupPaymentField()

        addSubview(paymentField)
        paymentField.layout {
            $0.top.equal(to: priceStackView.bottomAnchor, offsetBy: 32)
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.height.equal(to: 56)
        }

        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.titleLabel?.font = FontFamily.SamsungSharpSans.bold.font(size: 16)
        checkoutButton.isEnabled = false

        addSubview(checkoutButton)
        checkoutButton.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.bottom.equal(to: safeAreaLayoutGuide.bottomAnchor, offsetBy: -24)
            $0.height.equal(to: 56)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFields))
        addGestureRecognizer(tap)
    }

    private func setupPaymentField() {
        paymentField.delegate = self
        paymentField.postalCodeEntryEnabled = false
        paymentField.font = FontFamily.AvenirLTStd._65Medium.font(size: 16)
        paymentField.borderColor = Asset.Colors.cloudyBlue.color
        paymentField.cornerRadius = 6
        paymentField.textColor = Asset.Colors.almostBlack.color
        paymentField.cursorColor = Asset.Colors.hippieBlue.color

        paymentField.removeFields()
    }

    @objc
    private func dismissFields() {
        paymentField.resignFirstResponder()
        endEditing(true)
    }

    private func setupBindings() {
        cvcViewModel.shouldChangeTextHandler = { count in count <= 3 }
        cvcViewModel.editingDidEnd.bind(onNext: checkFieldsValidation ).disposed(by: disposeBag)

        cardNameViewModel.editingDidEnd.bind(onNext: checkFieldsValidation ).disposed(by: disposeBag)
        cardNameViewModel.textChanged
            .subscribe(onNext: { [weak self] text in
                let filteredText = text.count == text.filter { $0 == " " }.count ? "" : text
                self?.cardNameViewModel.updateText(filteredText.uppercased())
            })
            .disposed(by: disposeBag)

        expirationViewModel.shouldChangeTextHandler = { count in count <= 7 }
        expirationViewModel.shouldChangeTextInRangeHandler = { text, range in
            let isStart = range.location == 0 && text.isEmpty
            let isRemovingAtTheEnd = range.location == text.count - 1

            return isStart || isRemovingAtTheEnd || range.location == text.count
        }
        expirationViewModel.textChanged
            .subscribe(onNext: { [weak self] text in
                let formattedText = text.cardExpirationDateFormatted()
                self?.expirationViewModel.updateText(formattedText)
            })
            .disposed(by: disposeBag)
    }

    private func checkFieldsValidation() {
        switch (cvcViewModel.validate(), expirationViewModel.validate(),
                cardNameViewModel.validate(), paymentField.isValid) {
        case (.success, .success, .success, true):
            checkoutButton.isEnabled = true
        default:
            checkoutButton.isEnabled = false
        }
    }

}

extension CheckoutView: STPPaymentCardTextFieldDelegate {

    func paymentCardTextFieldDidBeginEditingNumber(_ textField: STPPaymentCardTextField) {
        paymentField.borderColor = Asset.Colors.hippieBlue.color
    }

    func paymentCardTextFieldDidEndEditingNumber(_ textField: STPPaymentCardTextField) {
        paymentField.borderColor = Asset.Colors.cloudyBlue.color
        checkFieldsValidation()
    }

}
