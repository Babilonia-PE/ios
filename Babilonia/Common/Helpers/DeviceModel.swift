//
//  DeviceModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 21.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

public class DeviceModel {

    private let identifier: String

    public init() {
        #if targetEnvironment(simulator)
        self.identifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
        #else
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        self.identifier = String(cString: machine)
        #endif
    }

    public var isIPhoneX: Bool {
        let identifiers = ["iPhone10,3", "iPhone10,6", "iPhone11,2",
                           "iPhone11,8", "iPhone12,1", "iPhone12,3",
                           "iPhone12,8", "iPhone13,1", "iPhone13,2", "iPhone13,3"]

        return identifiers.contains(identifier) == true || isIPhoneXMax
    }

    public var isIPhoneXMax: Bool {
        return identifier ==  "iPhone11,4"
            || identifier == "iPhone11,6"
            || identifier == "iPhone12,5"
            || identifier == "iPhone12,5"
            || identifier == "iPhone13,4"
    }

}
