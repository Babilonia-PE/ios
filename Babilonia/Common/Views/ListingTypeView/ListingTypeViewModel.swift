//
//  ListingTypeViewModel.swift
//  Babilonia
//
//  Created by Vitaly Chernysh on 7/18/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import Core

protocol ListingTypeDataProvider: class {
    
    var propertyTypeSettings: (title: String?, icon: UIImage?) { get }
    var listingTypeSettings: (title: String?, color: UIColor?) { get }
    
}

struct ListingTypeViewModel {
    
    private var dataProvider: ListingTypeDataProvider!

    let alpha: CGFloat
    let labelsAlignment: LabelsAlignment
    
    var propertyTypeSettings: (title: String?, icon: UIImage?) { return dataProvider.propertyTypeSettings }
    var listingTypeSettings: (title: String?, color: UIColor?) { return dataProvider.listingTypeSettings }

    init(labelsAlignment: LabelsAlignment, alpha: CGFloat = 0.8) {
        self.labelsAlignment = labelsAlignment
        self.alpha = alpha
    }
    
    mutating func setDataProvider(_ dataProvider: ListingTypeDataProvider) {
        self.dataProvider = dataProvider
    }

}

extension ListingTypeViewModel {
    
    enum LabelsAlignment {
        case vertical, horizontal
    }

}
