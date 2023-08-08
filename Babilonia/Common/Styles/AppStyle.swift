//
//  AppStyle.swift
//  Babilonia
//
//  Created by Denis on 6/4/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

// MARK: - initials

enum AppStyle {
    case `default`, action, shadowed
}

protocol StyleApplicable {
    
    @discardableResult
    func apply(style: AppStyle) -> Self
    
}

// MARK: - views configurations

extension UINavigationBar: StyleApplicable {
    
    @discardableResult
    func apply(style: AppStyle) -> Self {
        applySettings()
        
        switch style {
        case .default, .action:
            shadowImage = UIImage()
        case .shadowed:
            makeShadow(Asset.Colors.vulcan.color.withAlphaComponent(0.15),
                       offset: CGSize(width: 0.0, height: 2.0),
                       radius: 4,
                       opacity: 0.8)
            layer.masksToBounds = false
        }
        
        return self
    }
    
    private func applySettings() {
        titleTextAttributes = [
            .foregroundColor: Asset.Colors.vulcan.color,
            .font: FontFamily.SamsungSharpSans.bold.font(size: 16.0),
            .kern: 0.5
        ]
//        setBackgroundImage(UIImage(), for: .default)
     //   isTranslucent = false
        tintColor = .black
    }
    
}

extension UIBarButtonItem: StyleApplicable {
    
    @discardableResult
    func apply(style: AppStyle) -> Self {
        switch style {
        case .default, .shadowed:
            tintColor = .black
        case .action:
            tintColor = Asset.Colors.hippieBlue.color
        }
        
        return self
    }
    
}

extension UITextField: StyleApplicable {
    
    @discardableResult
    func apply(style: AppStyle) -> Self {
        switch style {
        case .default, .shadowed, .action:
            defaultTextAttributes = [
                NSAttributedString.Key.foregroundColor: Asset.Colors.vulcan.color,
                NSAttributedString.Key.font: FontFamily.AvenirLTStd._85Heavy.font(size: 14.0) as Any
            ]
        }
        
        return self
    }
    
}

// MARK: - appearance

extension AppStyle {
    
    func applyAppearance() {
        /// apply styles
        let views: [StyleApplicable] = [
            UINavigationBar.appearance(),
            UIBarButtonItem.appearance(),
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        ]
        views.forEach { $0.apply(style: self) }
        
        /// unique behaviors (if any)
        switch self {
        case .default, .action, .shadowed:
            break
        }
    }
    
}
