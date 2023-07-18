//
//  MainTabBarItemContentView.swift
//  Babilonia
//
//  Created by Denis on 6/26/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import ESTabBarController_swift

final class MainTabBarItemContentView: ESTabBarItemContentView {
    
    private let backgroundView: UIView
    
    init() {
        backgroundView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
        
        super.init(frame: .zero)
        
        textColor = Asset.Colors.mandy.color
        highlightTextColor = Asset.Colors.mandy.color
        iconColor = Asset.Colors.osloGray.color
        highlightIconColor = Asset.Colors.osloGray.color
        backdropColor = .clear
        highlightBackdropColor = .clear
        
        titleLabel.alpha = 0.0
        backgroundView.backgroundColor = Asset.Colors.mandy.color
        backgroundView.layer.cornerRadius = 20.0
        backgroundView.alpha = 0.0
        insertSubview(backgroundView, belowSubview: imageView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateLayout() {
        super.updateLayout()
        titleLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 10.0)
        imageView.sizeToFit()
        let centerPoint = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        imageView.center = centerPoint
        backgroundView.center = centerPoint
    }
    
    public override func selectAnimation(animated: Bool, completion: (() -> Void)?) {
        UIView.animate(
            withDuration: animated ? 0.3 : 0.0,
            animations: {
                let translate = CGAffineTransform(translationX: 0.0, y: -12.0)
                self.imageView.transform = translate
                self.backgroundView.transform = translate
                self.backgroundView.alpha = 1.0
                self.titleLabel.alpha = 1.0
                self.imageView.tintColor = .white
            },
            completion: { _ in
                completion?()
            }
        )
    }
    
    public override func reselectAnimation(animated: Bool, completion: (() -> Void)?) {
        completion?()
    }
    
    public override func deselectAnimation(animated: Bool, completion: (() -> Void)?) {
        UIView.animate(
            withDuration: animated ? 0.3 : 0.0,
            animations: {
                self.imageView.transform = .identity
                self.backgroundView.transform = .identity
                self.backgroundView.alpha = 0.0
                self.titleLabel.alpha = 0.0
                self.imageView.tintColor = Asset.Colors.osloGray.color
            },
            completion: { _ in
                completion?()
            }
        )
    }
    
    public override func highlightAnimation(animated: Bool, completion: (() -> Void)?) {
        completion?()
    }
    
    public override func dehighlightAnimation(animated: Bool, completion: (() -> Void)?) {
        completion?()
    }
    
}
