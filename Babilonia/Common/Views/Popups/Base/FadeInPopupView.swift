//
//  FadeInPopupView.swift
//  Babilonia
//
//  Created by Denis on 6/6/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let fadeAnimationDuration: TimeInterval = 0.2

class FadeInPopupView: UIView {
    
    var didHideHandler: (() -> Void)?
    
    var containerView: UIView!
    
    private var dimView: UIView!
    private var dimTapRecognizer: UITapGestureRecognizer!
    
    private let disposeBag = DisposeBag()
    
    // MARK: - lifecycle
    
    init() {
        super.init(frame: .zero)
        
        layout()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(in view: UIView, completion: (() -> Void)? = nil) {
        if !(view.subviews.last is FadeInPopupView) {
            frame = view.bounds
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
            translatesAutoresizingMaskIntoConstraints = true
            view.addSubview(self)
            
            animateDimView(isFadeIn: true)
            self.animateContainerView(isShowing: true, withDelay: true) {
                completion?()
            }
        }
    }
    
    func hide(completion: (() -> Void)? = nil) {
        animateContainerView(isShowing: false)
        self.animateDimView(isFadeIn: false, withDelay: true) {
            self.removeFromSuperview()
            completion?()
        }
    }
    
    func animateContainerView(isShowing: Bool, withDelay: Bool = false, completion: (() -> Void)? = nil) {
        containerView.animateFade(
            isShowing,
            duration: fadeAnimationDuration,
            delay: withDelay ? fadeAnimationDuration : 0.0,
            completion: completion
        )
    }
    
    // MARK: - private
    
    private func layout() {
        dimView = UIView(frame: .zero)
        dimView.backgroundColor = Asset.Colors.vulcan.color.withAlphaComponent(0.5)
        insertSubview(dimView, at: 0)
        dimView.layout {
            $0.centerX == centerXAnchor
            $0.centerY == centerYAnchor
            $0.width == widthAnchor
            $0.height == heightAnchor
        }
        
        dimTapRecognizer = UITapGestureRecognizer(target: nil, action: nil)
        dimView.addGestureRecognizer(dimTapRecognizer)
    }
    
    private func setupBindings() {
        dimTapRecognizer.rx.event.bind(onNext: { [weak self] _ in
            self?.hide(completion: self?.didHideHandler)
        }).disposed(by: disposeBag)
    }
    
}

private extension FadeInPopupView {
    
    func animateDimView(isFadeIn: Bool, withDelay: Bool = false, completion: (() -> Void)? = nil) {
        dimView.animateFade(
            isFadeIn,
            duration: fadeAnimationDuration,
            delay: withDelay ? fadeAnimationDuration : 0.0,
            completion: completion
        )
    }
    
}

private extension UIView {
    
    func animateFade(_ isFadeIn: Bool, duration: TimeInterval, delay: TimeInterval = 0.0, completion: (() -> Void)?) {
        alpha = isFadeIn ? 0.0 : 1.0
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            animations: {
                self.alpha = isFadeIn ? 1.0 : 0.0
            },
            completion: { _ in
                completion?()
            }
        )
    }
    
}
