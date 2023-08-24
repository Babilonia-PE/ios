//
//  Bundle+Extensions.swift
//  Babilonia
//
//  Created by Brayan Munoz Campos on 23/08/23.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import Foundation

extension Bundle {
    
    public var buildVersionNumber: Int {
        return Int(infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
    }
}
