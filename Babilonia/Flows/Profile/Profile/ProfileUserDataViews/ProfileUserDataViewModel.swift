//
//  ProfileUserDataViewModel.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/11/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

final class ProfileUserDataViewModel {
    
    private(set) var title: String
    private(set) var dataValue: String?
    private(set) var isActive: Bool
    
    init(title: String, dataValue: String?, isActive: Bool) {
        self.title = title
        self.dataValue = dataValue
        self.isActive = isActive
    }
}
