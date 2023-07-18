//
//  SegmentView.swift
//
//  Created by Vodolazkyi Anton on 4/29/19.
//
//

import UIKit

public final class SegmentControlView: UIView {
    
    public struct Config {
        let items: [(id: Int, name: String)]
        
        public init(items: [(id: Int, name: String)]) {
            self.items = items
        }
    }
    
    public var itemSelected: ((Int) -> Void)?
        
    private let itemsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.spacing = 47
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.backgroundColor = Asset.Colors.watermelon.color
        return view
    }()
    
    public init() {
        super.init(frame: .zero)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with config: Config) {
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        config.items.enumerated().forEach { item in
            let itemButton = Button(with: .none)
            itemButton.setTitle(item.element.name, for: .normal)
            itemButton.titleLabel?.font = FontFamily.AvenirLTStd._65Medium.font(size: 18)
            itemButton.setTitleColor(Asset.Colors.almostBlack.color, for: .selected)
            itemButton.setTitleColor(Asset.Colors.gunmetal.color, for: .normal)
            itemsStackView.addArrangedSubview(itemButton)
            
            itemButton.layout {
                $0.height.equal(to: itemsStackView.heightAnchor)
            }
            
            itemButton.touchUpInsideAction = { [weak self] _ in
                self?.selectIndex(item.offset, animated: true)
                self?.itemSelected?(item.element.id)
            }
        }
    }
    
    public func selectIndex(_ index: Int, animated: Bool) {
        guard itemsStackView.arrangedSubviews.isEmpty == false else { return }
        
        itemsStackView.arrangedSubviews.enumerated().forEach {
            ($0.element as? UIButton)?.isSelected = $0.offset == index
        }
        
        let extraInset = CGFloat((index + 1) * 2)
        indicatorView.layout.leading?.constant = itemsStackView.arrangedSubviews[index].frame.minX - extraInset
        indicatorView.layout.width?.constant = itemsStackView.arrangedSubviews[index].bounds.width
        
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.layoutIfNeeded()
        }
    }
    
    private func layout() {
        addSubview(itemsStackView)
        itemsStackView.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 35)
            $0.trailing.lessThanOrEqual(to: trailingAnchor, offsetBy: -16, priority: UILayoutPriority(999))
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
        }
        
        addSubview(indicatorView)
        indicatorView.layout {
            $0.bottom.equal(to: bottomAnchor)
            $0.width.equal(to: 0)
            $0.height.equal(to: 2)
            $0.leading.equal(to: itemsStackView.leadingAnchor)
        }
    }
}
