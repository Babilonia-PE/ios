//
//  ProfileFieldView.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/10/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ProfileFieldView: UIView {

    var selectButtonTap: ControlEvent<Void> { return selectButton.rx.tap }
    
    private var titleLabel: UILabel!
    private var selectedValueLabel: UILabel!
    private var selectButton: UIButton!
    private var accessoryImageView: UIImageView!
    
    private let disposeBag = DisposeBag()
    private let viewModel: ProfileFieldViewModel
    
    init(viewModel: ProfileFieldViewModel) {
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
        accessoryImageView = UIImageView()
        addSubview(accessoryImageView)
        accessoryImageView.layout {
            $0.centerY == centerYAnchor + 1.0
            $0.trailing == trailingAnchor - 16.0
            $0.width == 16.0
            $0.height == 16.0
        }
        
        selectedValueLabel = UILabel()
        addSubview(selectedValueLabel)
        selectedValueLabel.layout {
            $0.centerY == accessoryImageView.centerYAnchor + 1.0
            $0.trailing == accessoryImageView.leadingAnchor - 8.0
        }
        
        titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.layout {
            $0.top == topAnchor + 21.0
            $0.leading == leadingAnchor + 17.0
            $0.trailing <= selectedValueLabel.leadingAnchor - 8.0
            $0.bottom == bottomAnchor - 18.0
        }
        
        selectButton = UIButton()
        addSubview(selectButton)
        selectButton.layout {
            $0.top == topAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
        }
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        titleLabel.attributedText = viewModel.title.toAttributed(
            with: FontFamily.AvenirLTStd._65Medium.font(size: 16.0),
            color: Asset.Colors.vulcan.color
        )
        accessoryImageView.image = Asset.Profile.accessoryArrow.image
    }
    
    private func setupBindings() {
        viewModel.selectedValueUpdated
            .drive(onNext: { [weak selectedValueLabel] value in
                selectedValueLabel?.attributedText = value?.toAttributed(
                    with: FontFamily.AvenirLTStd._65Medium.font(size: 16.0),
                    color: .black
                )
            }).disposed(by: disposeBag)
    }
    
}
