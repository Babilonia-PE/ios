//
//  ActionSheetView.swift
//

import UIKit

public class ActionSheetView: UIView {
    
    private struct Constants {
        static let animationDuration: TimeInterval = 0.3
    }
    
    var containerHeight: CGFloat { return 308 }
    
    private let overlay = UIView()
    private let container = UIView()
    
    public init() {
        super.init(frame: .zero)
        
        layout()
        container.backgroundColor = UIColor.clear
        overlay.backgroundColor = Asset.Colors.almostBlack.color.withAlphaComponent(0.5)
        overlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        overlay.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(overlay)
        container.addSubview(self)
    }
    
    public func show(in window: UIWindow) {
        window.endEditing(true)
        container.removeFromSuperview()
        container.frame = window.bounds
        overlay.frame = container.bounds
        frame = CGRect(
            origin: CGPoint(x: 0, y: container.frame.height),
            size: CGSize(width: container.frame.width, height: containerHeight)
        )
        
        window.addSubview(container)
        
        overlay.alpha = 0
        UIView.animate(withDuration: Constants.animationDuration) {
            self.overlay.alpha = 1
            self.frame = CGRect(
                origin: CGPoint(x: 0, y: self.container.frame.height - self.containerHeight),
                size: CGSize(width: self.container.frame.width, height: self.containerHeight)
            )
            self.setNeedsDisplay()
        }
    }
    
    @objc
    public func hide() {
        UIView.animate(
            withDuration: Constants.animationDuration,
            animations: {
                self.overlay.alpha = 0
                self.frame = CGRect(
                    origin: CGPoint(x: 0, y: self.container.frame.height),
                    size: CGSize(width: self.container.frame.width, height: self.containerHeight)
                )
            },
            completion: { _ in self.container.removeFromSuperview() }
        )
    }
}

public extension UIViewController {
    
    func present(actionSheetView: ActionSheetView) {
        guard let window = view.window else { return }
        actionSheetView.show(in: window)
    }
}
