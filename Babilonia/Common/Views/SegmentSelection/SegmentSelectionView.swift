//
//  SegmentSelectionView.swift
//  Babilonia
//
//  Created by Denis on 6/4/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class SegmentSelectionView: UIView {
    
    var currentIndexUpdated: Driver<Int> { return currentIndex.asDriver() }
    var isEnabled = true {
        didSet {
            updateEnabled(isEnabled)
        }
    }
    
    private var segmentViews = [SegmentView]()
    private var segmentsDisposeBag = DisposeBag()
    
    private let currentIndex = BehaviorRelay(value: 0)
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with segments: [String], initialIndex: Int = 0) {
        segmentsDisposeBag = DisposeBag()
        segmentViews.forEach { $0.removeFromSuperview() }
        segmentViews = []
        
        var previousView: UIView?
        segments.enumerated().forEach { (index, segment) in
            let segmentView = SegmentView()
            addSubview(segmentView)
            
            segmentView.setup(with: segment)
            segmentView.didSelect.bind(onNext: { [unowned self] in
                self.updateCurrentIndex(index)
            }).disposed(by: segmentsDisposeBag)
            
            segmentView.layout {
                if let previousView = previousView {
                    $0.leading == previousView.trailingAnchor + 22.0
                    $0.width == previousView.widthAnchor
                } else {
                    $0.leading == leadingAnchor
                }
                $0.top == topAnchor
                $0.bottom == bottomAnchor
            }
            previousView = segmentView
            segmentViews.append(segmentView)
        }
        previousView?.layout {
            $0.trailing == trailingAnchor
        }
        
        updateCurrentIndex(initialIndex)
    }
    
    // MARK: - private
    
    private func updateCurrentIndex(_ index: Int) {
        currentIndex.accept(index)
        segmentViews.enumerated().forEach {
            $0.element.isSelectedState.accept($0.offset == index)
        }
    }
    
    private func updateEnabled(_ isEnabled: Bool) {
        isUserInteractionEnabled = isEnabled
        alpha = isEnabled ? 1.0 : 0.5
    }
    
}
