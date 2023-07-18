//
//  UserDefaults+Extensions.swift
//  Core
//
//  Created by Alya Filon  on 23.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation

public protocol AppSettingsStore: class {

    var arPopUpShown: Bool { get set }
    var cameraAlertDidShow: Bool { get set }

}

extension UserDefaults: AppSettingsStore {

    private enum AppSettingsStoreKeys: String {
        case arPopUpShownKey
        case cameraAlertDidShowKey
    }

    public var arPopUpShown: Bool {
        get {
            return bool(forKey: key(from: .arPopUpShownKey))
        }

        set {
            set(newValue, forKey: key(from: .arPopUpShownKey))
        }
    }

    public var cameraAlertDidShow: Bool {
        get {
            return bool(forKey: key(from: .cameraAlertDidShowKey))
        }

        set {
            set(newValue, forKey: key(from: .cameraAlertDidShowKey))
        }
    }

    private func key(from value: AppSettingsStoreKeys) -> String {
        return "\(Bundle.main.bundleIdentifier!).\(value.rawValue)"
    }

}
