//
//  TempMyListingsViewController.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TempMyListingsViewController: UIViewController {
    
    private let viewModel: TempMyListingsViewModel
    
    private var createListingButton: UIButton!
    
    init(viewModel: TempMyListingsViewModel) {
         self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layout() {
        view.backgroundColor = .white
        createListingButton = UIButton()
        createListingButton.setTitle("Create Listing", for: .normal)
        createListingButton.setTitleColor(.black, for: .normal)
        createListingButton.layer.borderColor = UIColor.black.cgColor
        createListingButton.layer.borderWidth = 1.0
        createListingButton.titleEdgeInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        view.addSubview(createListingButton)
        createListingButton.layout {
            $0.leading == view.leadingAnchor + 40.0
            $0.trailing == view.trailingAnchor - 40.0
            $0.centerY == view.centerYAnchor
        }
    }
    
    private func setupBindings() {
        createListingButton.rx.tap
            .bind(onNext: viewModel.createListing)
            .disposed(by: disposeBag)
    }
}
