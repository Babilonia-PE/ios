//
//  ScrollableView.swift
//  UI
//
//  Created by Vodolazkyi Anton on 12/7/18.
//

import UIKit

public class ScrollableView: UIView {
    
    public enum Direction {
        case vertical, horizontal
    }
    
    public let contentView = UIView()
    
    public let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .onDrag
        scrollView.backgroundColor = UIColor.gray
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let direction: Direction
    
    public init(direction: Direction = .vertical) {
        self.direction = direction
        super.init(frame: .zero)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        scrollView.layout(in: self)
        
        scrollView.addSubview(contentView)
        contentView.layout {
            $0.leading.equal(to: scrollView.leadingAnchor)
            $0.trailing.equal(to: scrollView.trailingAnchor)
            $0.top.equal(to: scrollView.topAnchor)
            $0.bottom.equal(to: scrollView.bottomAnchor)
            
            switch direction {
            case .vertical:
                $0.width.equal(to: scrollView.widthAnchor, priority: UILayoutPriority(rawValue: 999))
                $0.height.equal(to: scrollView.heightAnchor, priority: UILayoutPriority.defaultLow)
                
            case .horizontal:
                $0.height.equal(to: scrollView.heightAnchor, priority: UILayoutPriority(rawValue: 999))
                $0.width.equal(to: scrollView.widthAnchor, priority: UILayoutPriority.defaultLow)
            }
        }
    }
    
    func scrollToEnd(animated: Bool) {
        switch direction {
        case .vertical:
            let bottomOffset = CGPoint(
                x: 0,
                y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom
            )
            scrollView.setContentOffset(bottomOffset, animated: animated)
            
        case .horizontal:
            let leftOffset = CGPoint(
                x: scrollView.contentSize.width - scrollView.bounds.size.width + scrollView.contentInset.left,
                y: 0
            )
            scrollView.setContentOffset(leftOffset, animated: animated)
        }
    }
}
