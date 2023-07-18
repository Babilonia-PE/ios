//
//  DistanceConfigurable.swift
//  Babilonia
//
//  Created by Vitaly Chernysh on 7/19/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

protocol DistanceConfigurable: class {
    
    func applyDistance(_ distance: Double)
    func metersTitle(by distance: Double) -> String

}

extension DistanceConfigurable {
    
    func metersTitle(by distance: Double) -> String {
        if distance == 1 {
            return L10n.Ar.MetersCounter.Single.title
        } else {
            return L10n.Ar.MetersCounter.Many.title
        }
    }

}
