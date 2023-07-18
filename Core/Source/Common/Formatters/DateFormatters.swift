//
//  DateFormatters.swift
//  Core
//
//  Created by Anna Sahaidak on 7/12/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

public struct DateFormatters {
    
    public static let timestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US")
        
        return formatter
    }()
    
}
