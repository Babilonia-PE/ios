//
//  SlidingContainerView.swift
//  Babilonia
//
//  Created by Vitaly Chernysh on 7/17/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let arrowImageVerticalOffset: CGFloat = 8.0

final class SlidingContainerView: UIView {

    var closingRequest: Signal<Void> { return closingRequestUpdates.asSignal() }

    private let closingRequestUpdates = PublishRelay<Void>()
    private var arrowImageView: UIImageView!
    private var contentView: UIView!
    private var defaultVisibleOriginY: CGFloat!
    
    init() {
        super.init(frame: .zero)

        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API
    
    func slideIn(with view: UIView) {
        guard let superview = superview else { return }

        let initialFrame = CGRect(
            x: 0.0,
            y: superview.frame.height,
            width: superview.frame.width,
            height: view.frame.height + arrowImageView.frame.height + arrowImageVerticalOffset * 2
        )

        frame = initialFrame
        view.frame.size.width = superview.frame.width
        contentView.frame = view.frame
        contentView.addSubview(view)
        
        let newOrigin = superview.frame.height - frame.height
        defaultVisibleOriginY = newOrigin

        changeVerticalPositionAnimatedly(withNewOrigin: newOrigin)
    }
    
    func slideOut(completion: @escaping () -> Void) {
        guard let superview = superview else { return }
        
        changeVerticalPositionAnimatedly(withNewOrigin: superview.frame.height) {
            completion()
        }
    }

    func replaceContentView(with view: UIView) {
        performTransition(to: view, completion: nil)
    }

    // MARK: - Vertical position handling
    
    private func changeVerticalPositionAnimatedly(withNewOrigin origin: CGFloat, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1.0,
            options: .curveEaseInOut,
            animations: ({ [weak self] in
                self?.frame.origin.y = origin
        }), completion: { _ in
            completion?()
        })
    }
    
    private func restoreDefaultOrigin() {
        changeVerticalPositionAnimatedly(withNewOrigin: defaultVisibleOriginY)
    }
    
    private func setupViews() {
        backgroundColor = .white

        arrowImageView = UIImageView(image: Asset.ListingPreview.arrowDown.image)
        addSubview(arrowImageView)
        arrowImageView.layout {
            $0.top == topAnchor + arrowImageVerticalOffset
            $0.centerX == centerXAnchor
            $0.height == 9.0
            $0.width == 29.0
        }
        
        contentView = UIView()
        addSubview(contentView)
        contentView.layout {
            $0.top == arrowImageView.bottomAnchor + arrowImageVerticalOffset
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
        }
        
        addCornerRadius(20.0, corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner])
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didRecognizePanGesture(_:)))
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
    }
    
    private func performTransition(to newContentView: UIView, completion: (() -> Void)?) {
        guard let contentSubview = contentView.subviews.first else { return }

        newContentView.isHidden = true
        contentView.addSubview(newContentView)
        newContentView.layout {
            $0.top == arrowImageView.bottomAnchor + 5.0
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
        }

        UIView.transition(
            from: contentSubview,
            to: newContentView,
            duration: 0.1,
            options: [.transitionCrossDissolve, .showHideTransitionViews],
            completion: { _ in
                contentSubview.removeFromSuperview()
                completion?()
            }
        )
    }

    // MARK: - Actions
    
    @objc
    private func didRecognizePanGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard let superview = superview else { return }

        if panGestureRecognizer.state == .ended {
            if frame.origin.y - defaultVisibleOriginY > 100.0 {
                closingRequestUpdates.accept(())
            } else {
                restoreDefaultOrigin()
            }
            
            return
        }

        let translation = panGestureRecognizer.translation(in: self)
        let superviewRelatedPoint = convert(translation, to: superview)
        
        guard superviewRelatedPoint.y >= defaultVisibleOriginY else { return }
        
        panGestureRecognizer.setTranslation(.zero, in: self)
        changeVerticalPositionAnimatedly(withNewOrigin: superviewRelatedPoint.y)
    }

}

extension SlidingContainerView: UIGestureRecognizerDelegate {

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        
        let velocity = panGestureRecognizer.velocity(in: self)

        return abs(velocity.y) > abs(velocity.x)
    }
    
}
