//
//  AccountViewController.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/15/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class AccountViewController: UIViewController {
    
    private var signOutView: ProfileFieldView!
    private var deleteAccountView: ProfileFieldView!
    //private var separatorView: UIView!
    private var backButton: UIBarButtonItem!
    
    private var shadowApplied: Bool = false
    
    private let viewModel: AccountViewModel
    
    init(viewModel: AccountViewModel) {
         self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        setupNavigationBar()
        
        layout()
        setupViews()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !shadowApplied {
            navigationController?.navigationBar.apply(style: .shadowed)
            shadowApplied = true
        }
    }
    
    // MARK: - private

    private func layout() {
        signOutView = ProfileFieldView(viewModel: viewModel.signOutViewModel)
        view.addSubview(signOutView)
        signOutView.layout {
            $0.top == view.topAnchor + 16.0
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
        }
        
        var separatorView = UIView()
        separatorView.backgroundColor = Asset.Colors.whiteLilac.color
        view.addSubview(separatorView)
        separatorView.layout {
            $0.top == signOutView.bottomAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.height == 1.0
        }
        
        deleteAccountView = ProfileFieldView(viewModel: viewModel.deleteAccountViewModel)
        view.addSubview(deleteAccountView)
        deleteAccountView.layout {
            $0.top == separatorView.bottomAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
        }
        
        separatorView = UIView()
        separatorView.backgroundColor = Asset.Colors.whiteLilac.color
        view.addSubview(separatorView)
        separatorView.layout {
            $0.top == deleteAccountView.bottomAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.height == 1.0
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        //separatorView.backgroundColor = Asset.Colors.whiteLilac.color
    }
    
    private func setupNavigationBar() {
        navigationItem.title = L10n.Profile.Account.title
        
        // TODO: update button on back when resolve Tabbar hidding
        backButton = UIBarButtonItem(
            image: Asset.Common.closeIcon.image,
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupBindings() {
        signOutView.selectButtonTap
            .bind { [weak self] in
                self?.presentSignOut()
            }
            .disposed(by: disposeBag)
        
        deleteAccountView.selectButtonTap
            .bind { [weak self] in
                self?.presentDeleteAccount()
            }
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.close()
            }
            .disposed(by: disposeBag)
    }
    
    private func presentSignOut() {
        SystemAlert.present(on: self,
                            title: L10n.Popups.SignOut.title,
                            message: L10n.Popups.SignOut.text,
                            confirmTitle: L10n.Popups.SignOut.SignOut.title,
                            confirm: { [weak self] in
                                self?.viewModel.logout()
                            })
    }
    
    private func presentDeleteAccount() {
        SystemAlert.present(on: self,
                            title: L10n.Popups.DeleteAccount.title,
                            message: L10n.Popups.DeleteAccount.text,
                            confirmTitle: L10n.Popups.DeleteAccount.DeleteAccount.title,
                            confirm: { [weak self] in
                                self?.viewModel.deleteAccount()
                            })
    }
}
