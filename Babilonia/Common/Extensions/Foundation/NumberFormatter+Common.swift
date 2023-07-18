//
//  NSNumberFormatter+Common.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/2/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

extension NumberFormatter {
    
    static let integerFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        
        return formatter
    }()
    
}
