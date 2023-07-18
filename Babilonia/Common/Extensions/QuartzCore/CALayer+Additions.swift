//
//  CALayer+Additions.swift
//  Babilonia
//
//  Created by Denis on 6/3/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import QuartzCore

extension CALayer {
    
    @discardableResult
    func addShadowLayer(
        color: CGColor = UIColor.black.cgColor,
        offset: CGSize = .zero,
        radius: CGFloat = 30.0,
        opacity: Float = 1.0,
        cornerRadius: CGFloat = 0.0,
        atIndex: UInt32 = 0
    ) -> CALayer {
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shadowLayer.fillColor = UIColor.clear.cgColor
        
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowColor = color
        shadowLayer.shadowOffset = offset
        shadowLayer.shadowRadius = radius
        shadowLayer.shadowOpacity = opacity
        
        insertSublayer(shadowLayer, at: atIndex)
        
        return shadowLayer
    }
    
    @discardableResult
    func addGradientLayer(
        colors: [CGColor],
        locations: [CGFloat],
        isVertical: Bool = true,
        atIndex: UInt32 = 0
    ) -> CALayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.locations = locations.map { $0 as NSNumber }
        
        gradientLayer.startPoint = isVertical ? CGPoint(x: 0.5, y: 0.0) : CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = isVertical ? CGPoint(x: 0.5, y: 1.0) : CGPoint(x: 1.0, y: 0.5)
        
        gradientLayer.frame = bounds
        
        insertSublayer(gradientLayer, at: atIndex)
        
        return gradientLayer
    }
    
    @discardableResult
    func addDashBorderLayer(
        strokeLength: CGFloat,
        fillLength: CGFloat,
        lineWidth: CGFloat = 1.0,
        strokeColor: CGColor = UIColor.black.cgColor,
        fillColor: CGColor = UIColor.clear.cgColor,
        cornerRadius: CGFloat = 0.0
    ) -> CALayer {
        let shapeLayer = CAShapeLayer()
        
        guard bounds.height > 2.0, bounds.width > 2.0 else { return shapeLayer }
        
        let drawRect = CGRect(
            x: bounds.origin.x + 1.0,
            y: bounds.origin.y + 1.0,
            width: bounds.width - 2.0,
            height: bounds.height - 2.0
        )
        
        shapeLayer.fillColor = fillColor
        shapeLayer.strokeColor = strokeColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPattern = [fillLength, strokeLength] as [NSNumber]
        shapeLayer.path = UIBezierPath(roundedRect: drawRect, cornerRadius: cornerRadius).cgPath
        
        addSublayer(shapeLayer)
        
        return shapeLayer
    }
    
    func round(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        mask = shape
    }
    
}
