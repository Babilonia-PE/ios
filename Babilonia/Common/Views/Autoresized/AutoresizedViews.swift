//
//  AutoresizedViews.swift
//  Babilonia
//
//  Created by Denis on 7/15/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

class AutoresizedTextView: UITextView {
    
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var contentInset: UIEdgeInsets {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: contentSize.width + contentInset.left + contentInset.right,
            height: contentSize.height + contentInset.top + contentInset.bottom
        )
    }
    
}

class AutoresizedCollectionView: UICollectionView {
    
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var contentInset: UIEdgeInsets {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: contentSize.width + contentInset.left + contentInset.right,
            height: contentSize.height + contentInset.top + contentInset.bottom
        )
    }
    
}
