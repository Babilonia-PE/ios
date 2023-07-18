//
//  CAAnimationDelegateProxy.swift
//  Babilonia
//
//  Created by Denis on 6/26/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import QuartzCore

final class CAAnimationDelegateProxy: NSObject, CAAnimationDelegate {
    
    var didStart: (() -> Void)?
    var didStop: ((Bool) -> Void)?
    
    func animationDidStart(_ anim: CAAnimation) {
        didStart?()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        didStop?(flag)
    }
    
}
