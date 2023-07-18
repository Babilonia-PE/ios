//
//  NumberFieldView.swift
//  Babilonia
//
//  Created by Denis on 6/12/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class NumberFieldView: UIView {
    
    private var titleLabel: UILabel!
    private var valueLabel: UILabel!
    private var minusButton: NumberSelectionButton!
    private var plusButton: NumberSelectionButton!
    
    private let viewModel: NumberFieldViewModel
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: NumberFieldViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        layout()
        setupBindings()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private
    
    private func layout() {
        titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.layout {
            $0.leading == leadingAnchor
            $0.top == topAnchor + 9.0
            $0.bottom == bottomAnchor - 10.0
            $0.height >= 21.0
        }
        
        plusButton = NumberSelectionButton()
        addSubview(plusButton)
        plusButton.layout {
            $0.trailing == trailingAnchor
            $0.top == topAnchor
            $0.bottom == bottomAnchor
            $0.width == 48.0
            $0.height == 40.0
        }
        
        valueLabel = UILabel()
        addSubview(valueLabel)
        valueLabel.layout {
            $0.trailing == plusButton.leadingAnchor
            $0.top == topAnchor
            $0.bottom == bottomAnchor
            $0.width == 63.0
        }
        
        minusButton = NumberSelectionButton()
        addSubview(minusButton)
        minusButton.layout {
            $0.trailing == valueLabel.leadingAnchor
            $0.leading == titleLabel.trailingAnchor + 12.0
            $0.top == topAnchor
            $0.bottom == bottomAnchor
            $0.width == 48.0
            $0.height == 40.0
        }
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.textColor = Asset.Colors.vulcan.color
        titleLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 14.0)
        titleLabel.text = viewModel.title
        
        valueLabel.numberOfLines = 1
        valueLabel.textAlignment = .center
        valueLabel.textColor = Asset.Colors.vulcan.color
        valueLabel.font = FontFamily.SamsungSharpSans.regular.font(size: 24.0)
        
        minusButton.setImage(Asset.Common.minusIcon.image, for: .normal)
        
        plusButton.setImage(Asset.Common.plusIcon.image, for: .normal)
    }
    
    private func setupBindings() {
        viewModel.valueUpdated
            .map(String.init)
            .drive(valueLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.isDecreasingAvailable
            .drive(minusButton.rx.isEnabled)
            .disposed(by: disposeBag)
        viewModel.isIncreasingAvailable
            .drive(plusButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        minusButton.rx.tap
            .bind(onNext: viewModel.decreaseValue)
            .disposed(by: disposeBag)
        plusButton.rx.tap
            .bind(onNext: viewModel.increaseValue)
            .disposed(by: disposeBag)
    }
    
}
