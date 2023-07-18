//
//  SegmentView.swift
//  Babilonia
//
//  Created by Denis on 6/4/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SegmentView: UIView {
    
    var didSelect: ControlEvent<Void> { return selectButton.rx.tap }
    var isSelectedState = BehaviorRelay(value: false)
    
    private var selectButton: UIButton!
    
    private var disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        
        layout()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with segment: String) {
        selectButton.setTitle(segment, for: .normal)
    }
    
    // MARK: - private
    
    private func layout() {
        selectButton = UIButton()
        selectButton.layer.cornerRadius = 6.0
        selectButton.titleLabel?.font = FontFamily.AvenirLTStd._85Heavy.font(size: 13.0)
        selectButton.titleEdgeInsets = UIEdgeInsets(top: 3.0, left: 0.0, bottom: 0.0, right: 0.0)
        addSubview(selectButton)
        selectButton.layout {
            $0.top == topAnchor
            $0.bottom == bottomAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.height == 32.0
        }
    }
    
    private func setupBindings() {
        isSelectedState
            .bind { [weak self] value in
                self?.updateSelected(value)
            }
            .disposed(by: disposeBag)
    }
    
    private func updateSelected(_ selected: Bool) {
        if selected {
            selectButton.backgroundColor = Asset.Colors.biscay.color
            selectButton.setTitleColor(.white, for: .normal)
        } else {
            selectButton.backgroundColor = Asset.Colors.whiteLilac.color
            selectButton.setTitleColor(Asset.Colors.trout.color, for: .normal)
        }
    }
    
}
