//
//  Reusable.swift
//
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

/// Inspired by non-swift3 version of https://github.com/AliSoftware/Reusable

// MARK: Code-based Reusable

/// Protocol for `UITableViewCell` and `UICollectionViewCell` subclasses when they are code-based
protocol Reusable: class {
    
    static var reuseIdentifier: String { get }
    
}

extension Reusable {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
}

// MARK: - NIB-based Reusable

/// Protocol for `UITableViewCell` and `UICollectionViewCell` subclasses when they are NIB-based
protocol NibReusable: Reusable, NibLoadable {}

protocol NibLoadable: class {
    
    static var nib: UINib { get }
    
}

extension NibLoadable {
    
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
}
