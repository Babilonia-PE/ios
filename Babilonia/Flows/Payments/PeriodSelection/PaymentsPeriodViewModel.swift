//
//  PaymentsPeriodViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 27.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation
import Core

final class PaymentsPeriodViewModel {

    var planModel: PaymentPlanContentModel {
        model.planModel
    }

    var periodItems: [PaymentPeriodContentModel] {
        planModel.periodItems
    }

    var selectedPeriodIndex = 0
    
    private let model: PaymentsPeriodModel
    
    init(model: PaymentsPeriodModel) {
        self.model = model
    }

    func procceedChechout() {
        let selectedPeriod = periodItems[selectedPeriodIndex]
        model.chechout(with: selectedPeriod)
    }
    
}
