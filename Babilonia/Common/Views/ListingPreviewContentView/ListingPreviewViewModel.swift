//
//  ListingPreviewViewModel.swift
//  Babilonia
//
//  Created by Vitaly Chernysh on 7/19/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

struct ListingPreviewViewModel {
    
    var listingTypeViewModel: ListingTypeViewModel
    var listingID: Int {
        listingViewModel.listingID
    }
    
    let listingViewModel: ListingViewModel
    let isBottomButtonsHidden: Bool
    let photos: [ListingDetailsImage]
    
    init(
        listingTypeViewModel: ListingTypeViewModel,
        listingViewModel: ListingViewModel,
        isBottomButtonsHidden: Bool,
        photos: [ListingDetailsImage]
    ) {
        self.listingViewModel = listingViewModel
        self.listingTypeViewModel = listingTypeViewModel
        self.isBottomButtonsHidden = isBottomButtonsHidden
        self.photos = photos
        self.listingTypeViewModel.setDataProvider(listingViewModel)
    }

}
