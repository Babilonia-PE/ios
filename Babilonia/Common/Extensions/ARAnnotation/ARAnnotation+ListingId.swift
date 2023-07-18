//
//  ARAnnotation+ListingId.swift
//  Babilonia
//
//  Created by Vitaly Chernysh on 7/22/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import ARKitLocation

private struct AssociatedKeys {
    
    static var listingId = "listingId"
    
}

extension ARAnnotation {
    
    var listingId: ListingId? {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.listingId) as? ListingId else {
                return nil
            }
            
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.listingId,
                newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
}
