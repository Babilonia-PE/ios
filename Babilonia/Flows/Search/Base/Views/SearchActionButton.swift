//
//  SearchActionButton.swift
//  Babilonia
//
//  Created by Denis on 7/25/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

final class SearchActionButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            updateHighlighted(isHighlighted)
        }
    }
    
    // MARK: - lifecycle
    
    init() {
        super.init(frame: .zero)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupGradient() {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        gradient.colors = [Asset.Colors.watermelon.color.cgColor,
                           Asset.Colors.hippieBlue.color.cgColor,
                           Asset.Colors.orange.color.cgColor]

        let shape = CAShapeLayer()
        shape.lineWidth = 3
        shape.path = UIBezierPath(roundedRect: bounds, cornerRadius: layerCornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape

        layer.addSublayer(gradient)
    }

    func removeGradient() {
        layer.sublayers?.first { $0 is CAGradientLayer }?.removeFromSuperlayer()
    }
    
    // MARK: - private
    
    func setupViews() {
        backgroundColor = .white
    }
    
    private func updateHighlighted(_ isHighlighted: Bool) {
        if isHighlighted {
            backgroundColor = Asset.Colors.antiFlashWhite.color
        } else {
            backgroundColor = .white
        }
    }
    
}
