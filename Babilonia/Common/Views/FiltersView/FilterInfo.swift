//
//  FilterInfo.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/24/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

struct FilterInfo {
    
    enum Mode {
        case common, type(ListingType)
    }
    
    let attributedTitle: NSAttributedString
    let mode: Mode
    let filterType: FilterType
    
    init(attributedTitle: NSAttributedString, mode: Mode, filterType: FilterType) {
        self.attributedTitle = attributedTitle
        self.mode = mode
        self.filterType = filterType
    }

}
