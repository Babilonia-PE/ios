//
//  NumberSelectionButton.swift
//  Babilonia
//
//  Created by Denis on 6/18/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class NumberSelectionButton: UIButton {
    
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
    
    // MARK: - lifecycle
    
    init() {
        super.init(frame: .zero)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private
    
    private func setupViews() {
        backgroundColor = Asset.Colors.aquaSpring.color
        layer.cornerRadius = 4.0
    }
    
    private func updateColors() {
        switch (isHighlighted, isEnabled) {
        case (true, _):
            backgroundColor = Asset.Colors.mabel.color
        case (false, true):
            backgroundColor = Asset.Colors.aquaSpring.color
        case (false, false):
            backgroundColor = Asset.Colors.whiteLilac.color
        }
    }
    
}
