//
//  UIView+CornerRadius.swift
//  Babilonia
//
//  Created by Vitaly Chernysh on 7/16/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

extension UIView {

    var layerBorderWidth: CGFloat {
        get {
            layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    var layerBorderColor: UIColor? {
        get {
            guard let layerBorderColor = layer.borderColor else { return nil }
            return UIColor(cgColor: layerBorderColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    var layerCornerRadius: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    func makeShadow(_ color: UIColor = .lightGray,
                    offset: CGSize = CGSize(width: 0, height: 4),
                    radius: CGFloat = 6,
                    opacity: Float = 0.3) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }
    
    func makeViewRound() {
        addCornerRadius(min(bounds.height, bounds.width) / 2)
    }
    
    func addCornerRadius(
        _ radius: CGFloat,
        corners: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        ) {
        layer.cornerRadius = radius
        layer.maskedCorners = corners
        layer.masksToBounds = true
    }
    
}
