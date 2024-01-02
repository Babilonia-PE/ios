//
//  SystemAlert.swift
//  Babilonia
//
//  Created by Alya Filon  on 02.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

class SystemAlert {

    static func present(on controller: UIViewController,
                        title: String? = nil,
                        message: String = "",
                        completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: L10n.Buttons.OkButton.title, style: .default, handler: { _ in
            completion?()
        }))

        controller.present(alert, animated: true)
    }
    
    static func present(on controller: UIViewController,
                        title: String? = nil,
                        message: String = "",
                        confirmTitle: String = L10n.Buttons.OkButton.title,
                        confirm: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: confirmTitle, style: .default, handler: { _ in
            confirm?()
        }))

        controller.present(alert, animated: true, completion: nil)
    }

    static func present(on controller: UIViewController,
                        title: String? = nil,
                        message: String = "",
                        confirmTitle: String = L10n.Buttons.OkButton.title,
                        declineTitle: String = L10n.Buttons.Cancel.title,
                        confirm: (() -> Void)? = nil,
                        decline: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: confirmTitle, style: .default, handler: { _ in
            confirm?()
        }))

        alert.addAction(UIAlertAction(title: declineTitle, style: .cancel, handler: { _ in
            decline?()
        }))

        controller.present(alert, animated: true, completion: nil)
    }

    static func presentDestructive(on controller: UIViewController,
                                   title: String? = nil,
                                   message: String = "",
                                   destructTitle: String = L10n.Buttons.OkButton.title,
                                   declineTitle: String = L10n.Buttons.Cancel.title,
                                   destruct: (() -> Void)? = nil,
                                   decline: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: destructTitle, style: .destructive, handler: { _ in
            destruct?()
        }))

        alert.addAction(UIAlertAction(title: declineTitle, style: .cancel, handler: { _ in
            decline?()
        }))

        controller.present(alert, animated: true, completion: nil)
    }

}
