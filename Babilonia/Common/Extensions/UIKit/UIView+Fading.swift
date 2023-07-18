//
//  UIView+Fading.swift
//
//  Created by Vitaly Chernysh on 7/15/19.
//  Copyright © 2019 Vodolazkyi. All rights reserved.
//

import UIKit

private let fadingDuration: Double = 0.3

extension UIView {
    
    func fadeIn(completion: (() -> Void)? = nil) {
        fade(by: 1.0) {
            completion?()
        }
    }
    
    func fadeOut(completion: (() -> Void)? = nil) {
        fade(by: 0.0) {
            completion?()
        }
    }

    func fade(by newAlpha: CGFloat, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: fadingDuration, animations: {
            self.alpha = newAlpha
        }, completion: { _ in
            completion?()
        })
    }
    
}
