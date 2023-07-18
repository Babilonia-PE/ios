//
//  MainMenuViewController.swift
//
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ESTabBarController_swift

final class MainMenuViewController: ESTabBarController {
    
    override var selectedIndex: Int {
        didSet {
            guard oldValue != selectedIndex, oldValue != NSNotFound else { return }
            updateEdgeView(with: selectedIndex)
        }
    }
    
    override var viewControllers: [UIViewController]? {
        didSet {
            layoutEdgeViews()
        }
    }
    
    private var viewModel: MainMenuViewModel!
    
    private var desiredTabBarHeight: CGFloat!
    private let desiredTabBarHeightDelta: CGFloat = 7.0
    
    private var backgroundColorView: UIView!
    private var shadowView: UIView!
    private var shadowLayer: CALayer!
    
    private var edgeViews = [UIView]()
    
    init(viewModel: MainMenuViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addShadows()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        backgroundColorView = UIView()
        view.insertSubview(backgroundColorView, belowSubview: tabBar)
        backgroundColorView.layout {
            $0.top == tabBar.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor + 50.0
        }
        
        shadowView = UIView()
        shadowView.layer.cornerRadius = 12.0
        view.insertSubview(shadowView, belowSubview: backgroundColorView)
        shadowView.layout {
            $0.top == backgroundColorView.topAnchor
            $0.leading == backgroundColorView.leadingAnchor
            $0.trailing == backgroundColorView.trailingAnchor
            $0.bottom == backgroundColorView.bottomAnchor
        }
    }
    
    private func setupViews() {
        tabBar.barTintColor = .clear
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        
        backgroundColorView.backgroundColor = .white
        backgroundColorView.layer.cornerRadius = 12.0
    }
        
    private func addShadows() {
        guard shadowLayer == nil else { return }
        shadowLayer = shadowView.layer.addShadowLayer(
            color: Asset.Colors.vulcan.color.withAlphaComponent(0.2).cgColor,
            offset: .zero,
            radius: 8.0,
            cornerRadius: 12.0
        )
    }
    
    private func layoutEdgeViews() {
        edgeViews.forEach { $0.removeFromSuperview() }
        
        var previousView: UIView?
        viewControllers?.enumerated().forEach { (offset, _) in
            let view = UIImageView(image: Asset.Main.tabBarActiveTopEdge.image)
            
            let isSelected = offset == self.selectedIndex
            view.alpha = isSelected ? 1.0 : 0.0
            view.transform = CGAffineTransform(translationX: 0.0, y: isSelected ? -11.0 : 0.0)
            
            self.view.insertSubview(view, belowSubview: backgroundColorView)
            view.layout {
                $0.bottom == backgroundColorView.topAnchor + 21.0
                $0.leading == previousView?.trailingAnchor ?? backgroundColorView.leadingAnchor
                if let previous = previousView {
                    $0.width == previous.widthAnchor
                }
            }
            
            previousView = view
            edgeViews.append(view)
        }
        previousView?.layout {
            $0.trailing == backgroundColorView.trailingAnchor
        }
    }
    
    private func updateEdgeView(with index: Int) {
        edgeViews.enumerated().forEach { (offset, view) in
            let isSelected = offset == self.selectedIndex
            view.alpha = isSelected ? 1.0 : 0.0
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    view.transform = CGAffineTransform(translationX: 0.0, y: isSelected ? -11.0 : 0.0)
                }
            )
        }
    }
    
}
