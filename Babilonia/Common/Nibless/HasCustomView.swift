//
//  HasCustomView.swift
//
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation

import UIKit

/// The HasCustomView protocol defines a customView property for UIViewControllers to be used in exchange of the regular
/// view property. In order for this to work, you have to provide a custom view to your UIViewController
/// at the loadView() method.
public protocol HasCustomView {

    associatedtype CustomView: UIView

    func popController(animated: Bool)
}

extension HasCustomView where Self: UIViewController {
    /// The UIViewController's custom view.
    public var customView: CustomView {
        guard let customView = view as? CustomView else {
            fatalError("Expected view to be of type \(CustomView.self) but got \(type(of: view)) instead")
        }
        return customView
    }

    func popController(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }

}
