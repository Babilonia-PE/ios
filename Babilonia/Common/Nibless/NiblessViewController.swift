//
//  NiblessViewController.swift
//
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

/// Base UIViewController for all custom controllers used in this module
class NiblessViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init is not implemented")
    }

}
