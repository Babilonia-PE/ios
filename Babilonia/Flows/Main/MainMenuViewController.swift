//
//  MainMenuViewController.swift
//
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class MainMenuViewController: UIViewController, AlertApplicable {
    
    let alert = ApplicationAlert()
    
    private var viewModel: MainMenuViewModel!
    
    private var logoutButton: UIButton!
    private var createListingButton: UIButton!
    private var myListingButton: UIButton!
    
    init(viewModel: MainMenuViewModel) {
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
        
        logoutButton = UIButton(frame: .zero)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.black, for: .normal)
        
        view.addSubview(logoutButton)
        
        logoutButton.layout {
            $0.centerX == view.centerXAnchor
            $0.centerY == view.centerYAnchor
        }
        
        createListingButton = UIButton(frame: .zero)
        createListingButton.setTitle("Create Listing", for: .normal)
        createListingButton.setTitleColor(.black, for: .normal)
        
        view.addSubview(createListingButton)
        
        createListingButton.layout {
            $0.centerX == view.centerXAnchor
            $0.centerY == view.centerYAnchor + 70.0
        }
        
        myListingButton = UIButton(frame: .zero)
        myListingButton.setTitle(L10n.MyListings.title, for: .normal)
        myListingButton.setTitleColor(.black, for: .normal)
        
        view.addSubview(myListingButton)
        
        myListingButton.layout {
            $0.centerX == view.centerXAnchor
            $0.centerY == view.centerYAnchor + 140.0
        }
    }
    
    private func setupBindings() {
        logoutButton.rx.tap
            .bind(onNext: viewModel.logOut)
            .disposed(by: disposeBag)
        createListingButton.rx.tap
            .bind(onNext: viewModel.createListing)
            .disposed(by: disposeBag)
        myListingButton.rx.tap
            .bind(onNext: viewModel.openMyListings)
            .disposed(by: disposeBag)
    }
    
}
