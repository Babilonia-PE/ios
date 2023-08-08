//
//  FiltersView.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/24/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class FiltersView: UIView {
    
    var removedFilterClosure: ((_ index: Int) -> Void)?
    
    private var scrollView: UIScrollView!
    private var heightView: UIView!
    private var buttons = [UIButton]()
    
    private var disposeBag = DisposeBag()
    
    // MARK: - lifecycle
    
    init() {
        super.init(frame: .zero)
        
        layout()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with info: [FilterInfo]) {
        layout(filters: info)
        setupFiltersView(filters: info)
        setupButtonBindings()
    }

    // MARK: - private
    
    private func layout() {
        scrollView = UIScrollView()
        addSubview(scrollView)
        scrollView.layout {
            $0.top == topAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
        }
        
        heightView = UIView()
        scrollView.addSubview(heightView)
        heightView.layout {
            $0.top == scrollView.topAnchor
            $0.bottom == scrollView.bottomAnchor
            $0.leading == scrollView.leadingAnchor
            $0.width == 0
            $0.height == scrollView.heightAnchor
        }
    }
    
    private func layout(filters: [FilterInfo]) {
        buttons.forEach { $0.removeFromSuperview() }
        buttons = []
        
        let buttons = filters.map { _ in UIButton() }
        self.buttons = buttons
        addButtonsLayout(buttons: buttons)
    }
    
    private func addButtonsLayout(buttons: [UIButton]) {
        var lastView: UIView = heightView
        
        buttons.forEach { button in
            scrollView.addSubview(button)
            button.layout {
                $0.top == scrollView.topAnchor
                $0.leading == lastView.trailingAnchor + (lastView == heightView ? 16.0 : 8.0)
                $0.bottom == scrollView.bottomAnchor
                $0.height == 28.0
            }
            
            lastView = button
        }

        guard buttons.count > 1 else { return }
        lastView.layout {
            $0.trailing == scrollView.trailingAnchor - 16.0
        }
    }
    
    private func setupViews() {
        scrollView.backgroundColor = .white
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    private func setupFiltersView(filters: [FilterInfo]) {
        buttons.enumerated().forEach { (index, button) in
            button.setAttributedTitle(filters[index].attributedTitle, for: .normal)
            button.titleLabel?.font = FontFamily.AvenirLTStd._65Medium.font(size: 14.0)
            button.layer.cornerRadius = 6.0
            switch filters[index].mode {
            case .common:
                button.backgroundColor = Asset.Colors.solitude.color
                button.contentEdgeInsets = UIEdgeInsets(top: 2.0, left: 8.0, bottom: 0.0, right: 9.0)
            case .type(let listingType):
//                button.isEnabled = false
                button.contentEdgeInsets = UIEdgeInsets(top: 2.0, left: 11.0, bottom: 0.0, right: 10.0)
                switch listingType {
                case .sale:
                    button.backgroundColor = Asset.Colors.hippieBlue.color
                case .rent:
                    button.backgroundColor = Asset.Colors.orange.color
                }
            }
        }
    }
    
    private func setupButtonBindings() {
        disposeBag = DisposeBag()
        buttons.forEach { button in
            button.rx.tap
                .bind(onNext: { [weak self] in
                    guard let index = self?.buttons.firstIndex(of: button) else { return }
                    self?.removeFilter(at: index)
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func removeFilter(at index: Int) {
        UIView.animate(withDuration: 0.1, animations: {
            self.buttons[index].alpha = 0.0
        }, completion: { _ in
            self.buttons.forEach { $0.removeFromSuperview() }
            self.buttons.remove(at: index)
            self.addButtonsLayout(buttons: self.buttons)
            
            self.removedFilterClosure?(index)
        })
    }

}
