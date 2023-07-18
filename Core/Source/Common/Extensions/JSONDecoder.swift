//
//  JSONDecoder.swift
//  Core
//
//  Created by Anna Sahaidak on 7/12/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

extension JSONDecoder {
    
    public convenience init(dateFormatter: DateFormatter) {
        self.init()
        keyDecodingStrategy = .convertFromSnakeCase
        dateDecodingStrategy = .formatted(dateFormatter)
    }
}
