//
//  ExternalDataComposerManager.swift
//  Babilonia
//
//  Created by Alya Filon  on 25.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import MessageUI

class ExternalDataComposerManager: NSObject {

    unowned var controller: UIViewController

    init(controller: UIViewController) {
        self.controller = controller

        super.init()
    }

    @objc
    func proceedEmail(_ email: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])

            controller.present(mail, animated: true)
        }
    }

    @objc
    func proceedPhone(_ phone: String) {
        guard
            let url = URL(string: "TEL://\(phone.filter { $0 != "-" && !$0.isWhitespace })"),
            UIApplication.shared.canOpenURL(url)
            else { return }

        UIApplication.shared.open(url)
    }

}

extension ExternalDataComposerManager: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }

}
