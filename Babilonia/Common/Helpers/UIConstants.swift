//
//  Constants.swift
//  Babilonia
//
//  Created by Alya Filon  on 21.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

struct UIConstants {

    private static let deviceModel = DeviceModel()

    static var isPhoneX: Bool {
        deviceModel.isIPhoneX
    }

    static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    static var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }

    static var safeLayoutBottom: CGFloat {
        deviceModel.isIPhoneX ? 34 : 0
    }

    static var safeLayoutTop: CGFloat {
        deviceModel.isIPhoneX ? 24 : 0
    }

    static var defaultKeyboardHeight: CGFloat {
        deviceModel.isIPhoneX ? 291 : 224
    }

}
