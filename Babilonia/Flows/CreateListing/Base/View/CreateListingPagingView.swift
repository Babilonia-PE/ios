//
//  CreateListingPagingView.swift
//  Babilonia
//
//  Created by Denis on 5/31/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class CreateListingPagingView: UIView {
    
    var currentIndexUpdated: Driver<Int> {
        return currentIndex.asDriver().filter { [unowned self] in
            $0 < self.pageViews.count
        }
    }
    
    var allPagesFilled: Driver<Void> {
        return currentIndex.asDriver().filter { [unowned self] in
            $0 >= self.pageViews.count
        }.map { _ in }
    }
    
    private var pageViews = [CreateListingPageView]()
    private var currentIndex = BehaviorRelay(value: 0)
    
    private var pagesDisposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(elements: [(String, UIImage)]) {
        pagesDisposeBag = DisposeBag()
        pageViews.forEach { $0.removeFromSuperview() }
        pageViews = []
        
        var previousView: UIView?
        var previousSeparatorView: UIView?
        elements.forEach { title, image in
            let separatorView = UIView()
            addSubview(separatorView)
            separatorView.layout {
                $0.leading == previousView?.trailingAnchor ?? leadingAnchor
                $0.top == topAnchor
                $0.bottom == bottomAnchor
                
                if let previousSeparatorView = previousSeparatorView {
                    $0.width == previousSeparatorView.widthAnchor
                }
            }
            previousSeparatorView = separatorView
            
            let pageView = CreateListingPageView()
            pageView.setup(state: previousView == nil ? .current : .empty, title: title, image: image)
            bindPageViewSelection(pageView)
            
            addSubview(pageView)
            
            pageView.layout {
                $0.leading == separatorView.trailingAnchor
                $0.top == topAnchor
                $0.bottom == bottomAnchor
                
                if let previousView = previousView {
                    $0.width.equal(
                        to: previousView.widthAnchor,
                        multiplier: 1.0,
                        priority: UILayoutPriority(rawValue: 200.0)
                    )
                }
            }
            previousView = pageView
            pageViews.append(pageView)
        }
        
        if let previousView = previousView, let previousSeparatorView = previousSeparatorView {
            let separatorView = UIView()
            addSubview(separatorView)
            separatorView.layout {
                $0.leading == previousView.trailingAnchor
                $0.top == topAnchor
                $0.bottom == bottomAnchor
                $0.width == previousSeparatorView.widthAnchor
                $0.trailing == trailingAnchor
            }
        }
        
        currentIndex.accept(0)
    }
    
    func proceedWithNextStep() {
        selectPage(at: currentIndex.value + 1)
    }
    
    // MARK: - private
    
    private func bindPageViewSelection(_ pageView: CreateListingPageView) {
        pageView.didSelect
            .filter { [unowned pageView] in
                return (pageView.state != .empty)
            }
            .bind { [unowned self, pageView] in
                self.selectPage(at: self.pageViews.firstIndex(of: pageView) ?? 0)
            }
            .disposed(by: pagesDisposeBag)
    }
    
    private func selectPage(at index: Int) {
        currentIndex.accept(index)
        updateStates()
    }
    
    private func updateStates() {
        let index = min(currentIndex.value, pageViews.count - 1)
        pageViews.enumerated().forEach {
            switch $0.offset {
            case ..<index:
                $0.element.setup(state: .filled, title: $0.element.title, image: $0.element.image)
            case index:
                $0.element.setup(state: .current, title: $0.element.title, image: $0.element.image)
            default:
                $0.element.setup(state: .empty, title: $0.element.title, image: $0.element.image)
            }
        }
    }
    
}
