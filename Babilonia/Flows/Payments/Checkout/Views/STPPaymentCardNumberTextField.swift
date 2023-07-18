//
//  STPPaymentCardNumberTextField.swift
//  Babilonia
//
//  Created by Alya Filon  on 29.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import Stripe

class STPPaymentCardNumberTextField: STPPaymentCardTextField {

    private let cvcPlaceholderString = "CVC"
    private let expirationDatePlaceholder = "MM/YY"

    private let validCVC = "123"
    private let validExpirationDate = "12/60"

    func removeCVC() {
        if let fieldsView = subviews.first {
            for view in fieldsView.subviews where view is UITextField {
                guard let textField = view as? UITextField else { continue }

                if textField.tag == 2 || textField.placeholder == cvcPlaceholderString {
                    textField.text = validCVC
                    textField.removeFromSuperview()
                }
            }
        }
    }

    func removeDate() {
        if let fieldsView = subviews.first {
            for view in fieldsView.subviews where view is UITextField {
                guard let textField = view as? UITextField else { continue }

                if textField.tag == 1 || textField.placeholder == expirationDatePlaceholder {
                    textField.text = validExpirationDate
                    textField.removeFromSuperview()
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupPlaceholders()
        removeFields()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupPlaceholders()
        removeFields()
    }

    private func setupPlaceholders() {
        cvcPlaceholder = cvcPlaceholderString
        expirationPlaceholder = expirationDatePlaceholder
    }

    func removeFields() {
        removeCVC()
        removeDate()
    }

}
