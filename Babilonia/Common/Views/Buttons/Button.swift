//
//  Button.swift
//  Babilonia
//
//  Created by Vodolazkyi Anton on 3/10/20.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final public class Button: UIButton {
    
    enum Style {
        case none
    }
    
    public override var isHighlighted: Bool {
        didSet {
            let transform: CGAffineTransform = isHighlighted ? .init(scaleX: 0.95, y: 0.95) : .identity
            animate(transform)
            alpha = isHighlighted ? 0.6 : 1.0
        }
    }
    
    public var touchUpInsideAction: ((Button) -> Void)?
    
    private var style: Style
    
    init(with style: Style) {
        self.style = style
        super.init(frame: .zero)
        
        addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func touchUpInside(_ sender: Button) {
        switch style {
        case .none:
            break
        }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        touchUpInsideAction?(sender)
    }
    
    private func animate(_ transform: CGAffineTransform) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 3,
            options: [.curveEaseInOut],
            animations: {
                self.transform = transform
            }
        )
    }
}
