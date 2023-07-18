//
//  SwitchFieldView.swift
//  Babilonia
//
//  Created by Denis on 6/12/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SwitchFieldView: UIView {
    
    private var titleLabel: UILabel!
    private var imageView: UIImageView!
    private var valueSwitch: UISwitch!
    
    private let viewModel: SwitchFieldViewModel
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: SwitchFieldViewModel) {
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
        imageView = UIImageView()
        addSubview(imageView)
        imageView.layout {
            $0.top == topAnchor + 8.0
            $0.leading == leadingAnchor
        }
        imageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 800.0), for: .horizontal)
        imageView.setContentHuggingPriority(UILayoutPriority(rawValue: 700.0), for: .horizontal)
        
        titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.layout {
            $0.leading == imageView.trailingAnchor + 16.0
            $0.top == topAnchor + 9.0
            $0.bottom == bottomAnchor - 10.0
            $0.height >= 21.0
        }
        
        valueSwitch = UISwitch()
        addSubview(valueSwitch)
        valueSwitch.layout {
            $0.leading == titleLabel.trailingAnchor + 12.0
            $0.trailing == trailingAnchor
            $0.top == topAnchor + 4.5
        }
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        imageView.image = viewModel.image
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.textColor = Asset.Colors.vulcan.color
        titleLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 14.0)
        titleLabel.text = viewModel.title
        
        valueSwitch.onTintColor = Asset.Colors.mandy.color
    }
    
    private func setupBindings() {
        viewModel.valueUpdated
            .drive(valueSwitch.rx.isOn)
            .disposed(by: disposeBag)
        
        valueSwitch.rx.isOn
            .changed
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(onNext: viewModel.updateValue)
            .disposed(by: disposeBag)
    }
    
}
