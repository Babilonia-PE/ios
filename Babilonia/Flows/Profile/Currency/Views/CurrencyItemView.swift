//
//  CurrencyItemView.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/19/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class CurrencyItemView: UIView {
    
    private var titleLabel: UILabel!
    private var selectionButton: UIButton!
    private var selectedImageView: UIImageView!
    private var separatorView: UIView!
    
    private let viewModel: CurrencyItemViewModel
    
    private let disposeBag = DisposeBag()
    
    // MARK: - lifecycle
    
    init(viewModel: CurrencyItemViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        layout()
        setupViews()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private
    
    private func layout() {
        selectedImageView = UIImageView()
        addSubview(selectedImageView)
        selectedImageView.layout {
            $0.centerY == centerYAnchor
            $0.trailing == trailingAnchor - 17.0
            $0.width == 16.0
            $0.height == 16.0
        }
        
        titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.layout {
            $0.top == topAnchor + 20.0
            $0.leading == leadingAnchor + 17.0
            $0.trailing <= selectedImageView.leadingAnchor - 17.0
            $0.bottom == bottomAnchor - 20.0
        }
        
        selectionButton = UIButton()
        addSubview(selectionButton)
        selectionButton.layout {
            $0.top == topAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
        }
        
        separatorView = UIView()
        addSubview(separatorView)
        separatorView.layout {
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
            $0.height == 1.0
        }
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        titleLabel.attributedText = viewModel.title.toAttributed(
            with: FontFamily.AvenirLTStd._65Medium.font(size: 16.0),
            color: Asset.Colors.vulcan.color
        )
        
        selectedImageView.image = Asset.Profile.radiobtn.image
        separatorView.backgroundColor = Asset.Colors.whiteLilac.color
    }
    
    private func setupBindings() {
        viewModel.valueUpdated
            .drive(onNext: { [weak self] value in
                self?.updateRadioButton(value)
            })
            .disposed(by: disposeBag)
        
        selectionButton.rx.tap
            .bind(onNext: { [weak viewModel] in
                viewModel?.changeValue()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateRadioButton(_ isSelected: Bool) {
        UIView.animate(withDuration: 0.1) { [weak selectedImageView] in
            selectedImageView?.alpha = isSelected ? 1.0 : 0.0
        }
    }
}
