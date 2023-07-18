//
//  GridFlowLayout.swift
//  Babilonia
//
//  Created by Denis on 7/5/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

class GridFlowLayout: UICollectionViewFlowLayout {
    
    @IBInspectable var numberOfLines: CGFloat = 1.0
    @IBInspectable var imageAreaRatio: CGFloat = 1.0
    @IBInspectable var infoAreaHeight: CGFloat = 0.0
    
    var customViewWidth: CGFloat?
    var customItemSize: CGSize {
        let itemWidth: CGFloat
        if scrollDirection == .vertical {
            itemWidth = ((customViewWidth ?? collectionView!.bounds.width) -
                (sectionInset.left + sectionInset.right) -
                minimumInteritemSpacing * (numberOfLines - 1)) / numberOfLines
        } else {
            itemWidth = collectionView!.bounds.height -
                (sectionInset.top + sectionInset.bottom) - infoAreaHeight
        }
        let itemHeight = itemWidth / imageAreaRatio + infoAreaHeight
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    override func prepare() {
        itemSize = customItemSize
    }
    
}
