//
//  PaymentsProfileViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 27.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation

final class PaymentsProfileViewModel {
    
    private let model: PaymentsProfileModel

    var profileTypes: [PaymentProfileType] {
        PaymentProfileType.allCases
    }

    var siteURL: URL? {
        URL(string: model.siteURL)
    }

    var selectedProfileIndex = 0
    
    init(model: PaymentsProfileModel) {
        self.model = model
    }

    func selectProfile() {
        let selectedProfile = profileTypes[selectedProfileIndex]
        model.selectProfile(selectedProfile)
    }
    
}
