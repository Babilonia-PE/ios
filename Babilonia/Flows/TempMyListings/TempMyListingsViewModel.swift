//
//  TempMyListingsViewModel.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

final class TempMyListingsViewModel {
    
    private let model: TempMyListingsModel
    
    init(model: TempMyListingsModel) {
        self.model = model
    }
    
    func createListing() {
        model.createListing()
    }
    
    private func setupContent() {
        
    }
    
}
