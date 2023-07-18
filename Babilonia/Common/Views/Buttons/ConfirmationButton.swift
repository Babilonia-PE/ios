//
//  ConfirmationButton.swift
//  Babilonia
//
//  Created by Denis on 6/18/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ConfirmationButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            updateColors()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            updateColors()
        }
    }
    
    private var shadowLayer: CALayer!
    
    // MARK: - lifecycle
    
    init() {
        super.init(frame: .zero)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2.0
        addShadows()
    }
    
    // MARK: - private
    
    private func setupViews() {
        backgroundColor = Asset.Colors.mandy.color
        layer.cornerRadius = frame.height / 2.0
    }
    
    private func addShadows() {
        guard shadowLayer == nil else { return }
        shadowLayer = layer.addShadowLayer(
            color: Asset.Colors.brickRed.color.withAlphaComponent(0.3).cgColor,
            offset: CGSize(width: 0.0, height: 4.0),
            radius: 6.0,
            cornerRadius: frame.height / 2.0
        )
        shadowLayer.isHidden = !isEnabled || isHighlighted
    }
    
    private func updateColors() {
        switch (isHighlighted, isEnabled) {
        case (true, _):
            backgroundColor = Asset.Colors.brickRed.color
            shadowLayer?.isHidden = true
        case (false, true):
            backgroundColor = Asset.Colors.mandy.color
            shadowLayer?.isHidden = false
        case (false, false):
            backgroundColor = Asset.Colors.lightMandy.color
            shadowLayer?.isHidden = true
        }
    }
    
}
