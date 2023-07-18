//
//  AnnotationContainerView.swift
//  Babilonia
//
//  Created by Vitaly Chernysh on 7/19/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import ARKitLocation

final class AnnotationContainerView: ARAnnotationView {

    var didSelectAnnotation: ((ARAnnotationView) -> Void)?
    var didSetDistanceFromUser: ((Double) -> Void)?

    private var currentAnnotationView: AnnotationView?
    private var viewModel: AnnotationViewModel!
    private var viewType: ViewType?
    private let isNavigationMode: Bool

    override func initialize() {
        super.initialize()
        
        loadUi()
    }

    init(isNavigationMode: Bool = false) {
        self.isNavigationMode = isNavigationMode

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // This method is called whenever distance/azimuth is set
    override func bindUi() {
        guard let annotation = annotation else { return }

        if isNavigationMode {
            didSetDistanceFromUser?(annotation.distanceFromUser)

            return
        }

        let updatedViewType = ViewType(distanceFromUser: annotation.distanceFromUser)
        
        guard viewType != nil, let currentAnnotationView = currentAnnotationView else {
            // For first initialization
            self.viewType = updatedViewType
            performInitialAnnotationViewSetup()

            return
        }
        
        guard viewType != updatedViewType else {
            // For a case when AnnotationView's size should not be changed.
            // Just applying new distance.
            didSetDistanceFromUser?(annotation.distanceFromUser)
            currentAnnotationView.applyDistance(annotation.distanceFromUser)

            return
        }
        
        // For a case when we need to show another AnnotationView (larger or smaller).
        self.viewType = updatedViewType
        setNewAnnotationView()
    }
    
    func apply(_ viewModel: AnnotationViewModel) {
        self.viewModel = viewModel
    }

    private func setNewAnnotationView() {
        guard let viewType = viewType, let annotation = annotation else { return }
        
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1.0,
            options: .curveEaseInOut,
            animations: ({ [weak self] in
                self?.frame.size = viewType.size
            }),
            completion: nil
        )
        
        guard let newAnnotationView = self.annotationViewForCurrentViewType() else { return }
        
        newAnnotationView.applyDistance(annotation.distanceFromUser)
        
        self.performTransition(to: newAnnotationView) { [weak self] in
            guard let self = self else { return }
            
            self.currentAnnotationView = newAnnotationView
            self.didSetDistanceFromUser?(annotation.distanceFromUser)
        }
    }

    private func performInitialAnnotationViewSetup() {
        guard let viewType = viewType, let distanceFromUser = annotation?.distanceFromUser else { return }
        
        frame.size = viewType.size
        
        guard let annotationView = annotationViewForCurrentViewType() else { return }
        
        currentAnnotationView = annotationView
        addSubview(annotationView)
        annotationView.layout {
            $0.bottom == bottomAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.top == topAnchor
        }
        
        currentAnnotationView?.applyDistance(distanceFromUser)
    }

    private func annotationViewForCurrentViewType() -> AnnotationView? {
        guard let viewType = viewType else { return nil }

        switch viewType {
        case.small:
            return SmallAnnotationView(viewModel: viewModel)
            
        case .medium:
            return MediumAnnotationView(viewModel: viewModel)
            
        case .large:
            return LargeAnnotationView(viewModel: viewModel)
        }
    }

    private func loadUi() {
        if isNavigationMode {
            let imageView = UIImageView(image: Asset.AugmentedReality.housePin.image)
            addSubview(imageView)

            imageView.layout {
                $0.height.equal(to: 56)
                $0.width.equal(to: 56)
                $0.centerX.equal(to: centerXAnchor)
                $0.centerY.equal(to: centerYAnchor)
            }

        } else {
            backgroundColor = UIColor.white.withAlphaComponent(0.65)
            addCornerRadius(8.0)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSelection(_:)))
            addGestureRecognizer(tapGesture)

            if annotation != nil {
                bindUi()
            }
        }
    }

    private func performTransition(to newAnnotationView: AnnotationView, completion: (() -> Void)?) {
        guard let currentAnnotationView = currentAnnotationView else { return }
        
        newAnnotationView.isHidden = true
        addSubview(newAnnotationView)
        newAnnotationView.layout {
            $0.bottom == bottomAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.top == topAnchor
        }
        
        UIView.transition(
            from: currentAnnotationView,
            to: newAnnotationView,
            duration: 0.25,
            options: [.transitionCrossDissolve, .showHideTransitionViews],
            completion: { _ in
                currentAnnotationView.removeFromSuperview()
                completion?()
            }
        )
    }
    
    @objc
    private func handleSelection(_ gestureRecognizer: UITapGestureRecognizer) {
        guard annotation != nil else { return }
        
        didSelectAnnotation?(self)
    }

}

extension AnnotationContainerView {
    
    enum ViewType {
        case small, medium, large
        
        init(distanceFromUser: Double) {
            switch distanceFromUser {
            case ...150.0:
                self = .large

            case ...500.0:
                self = .medium

            default:
                self = .small
            }
        }

        var size: CGSize {
            switch self {
            case .small:
                return .init(width: 120.0, height: 40.0)
                
            case .medium:
                return .init(width: 196.0, height: 56.0)
                
            case .large:
                return .init(width: 256.0, height: 80.0)
            }
        }
    }
    
}
