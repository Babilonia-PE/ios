//
//  ProfileViewController.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileViewController: UIViewController {
    
    private var scrollView: UIScrollView!
    private var aboutLabel: UILabel!
    private var avatarView: ProfileAvatarView!
    private var emailView: ProfileContactsView!
    private var phoneView: ProfileContactsView!
    private var currencyView: ProfileFieldView!
    private var accountView: ProfileFieldView!
    private var termsView: ProfileFieldView!
    private var privacyView: ProfileFieldView!
    
    private var shadowApplied: Bool = false
    
    private let viewModel: ProfileViewModel
    
    // MARK: - lifecycle
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        setupViews()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if viewModel.canRefreshUser {
            viewModel.refreshUser()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupNavigationBar()
    }
    
    func updateUser(_ user: User, avatarImage: UIImage?) {
        viewModel.updateUser(user, avatarImage: avatarImage)
    }
    
    func updateRefreshMode(isOn: Bool) {
        viewModel.canRefreshUser = isOn
    }
    
    // MARK: - private

    //swiftlint:disable:next function_body_length
    private func layout() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.layout {
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
        }
        
        let widthView = UIView()
        scrollView.addSubview(widthView)
        widthView.layout {
            $0.top == scrollView.topAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
            $0.width == scrollView.widthAnchor
            $0.height == 1
        }
        
        avatarView = ProfileAvatarView()
        scrollView.addSubview(avatarView)
        avatarView.layout {
            $0.top == scrollView.topAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
        }
        
        emailView = ProfileContactsView()
        scrollView.addSubview(emailView)
        emailView.layout {
            $0.top == avatarView.bottomAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
        }
        var separator = addSeparatorView(height: 1.0, topAnchor: emailView.bottomAnchor)
        
        phoneView = ProfileContactsView()
        scrollView.addSubview(phoneView)
        phoneView.layout {
            $0.top == separator.bottomAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
        }
        separator = addSeparatorView(height: 8.0, topAnchor: phoneView.bottomAnchor)
        
        currencyView = ProfileFieldView(viewModel: viewModel.currencyViewModel)
        scrollView.addSubview(currencyView)
        currencyView.layout {
            $0.top == separator.bottomAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
        }
        separator = addSeparatorView(height: 1.0, topAnchor: currencyView.bottomAnchor)
        
        accountView = ProfileFieldView(viewModel: viewModel.accountViewModel)
        scrollView.addSubview(accountView)
        accountView.layout {
            $0.top == separator.bottomAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
        }
        separator = addSeparatorView(height: 8.0, topAnchor: accountView.bottomAnchor)
        
        aboutLabel = UILabel()
        scrollView.addSubview(aboutLabel)
        aboutLabel.layout {
            $0.top == separator.bottomAnchor + 24.0
            $0.leading == scrollView.leadingAnchor + 19.0
            $0.trailing <= scrollView.trailingAnchor - 19.0
        }
        
        termsView = ProfileFieldView(viewModel: viewModel.termsViewModel)
        scrollView.addSubview(termsView)
        termsView.layout {
            $0.top == aboutLabel.bottomAnchor + 4.0
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
        }
        separator = addSeparatorView(height: 1.0, topAnchor: termsView.bottomAnchor)
        
        privacyView = ProfileFieldView(viewModel: viewModel.privacyViewModel)
        scrollView.addSubview(privacyView)
        privacyView.layout {
            $0.top == separator.bottomAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
        }
        
        separator = addSeparatorView(height: 1.0, topAnchor: privacyView.bottomAnchor)
        separator.layout {
            $0.bottom == scrollView.bottomAnchor - 20.0
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        aboutLabel.attributedText = L10n.Profile.About.text.toAttributed(
            with: FontFamily.AvenirLTStd._85Heavy.font(size: 12.0),
            color: Asset.Colors.osloGray.color
        )
    }
    
    private func setupBindings() {
        avatarView.editButtonTap
            .bind(onNext: { [weak viewModel] _ in
                viewModel?.editProfile()
            })
            .disposed(by: disposeBag)
        
        emailView.editButtonTap
            .bind(onNext: { [weak viewModel] _ in
                viewModel?.editEmail()
            })
            .disposed(by: disposeBag)
        
        accountView.selectButtonTap
            .bind(onNext: { [weak viewModel] _ in
                viewModel?.openAccount()
            })
            .disposed(by: disposeBag)
        
        termsView.selectButtonTap
            .bind(onNext: { [weak viewModel] _ in
                viewModel?.openTerms()
            })
            .disposed(by: disposeBag)
        
        privacyView.selectButtonTap
            .bind(onNext: { [weak viewModel] _ in
                viewModel?.openPrivacy()
            })
            .disposed(by: disposeBag)
        
        currencyView.selectButtonTap
            .bind(onNext: { [weak viewModel] _ in
                viewModel?.openCurrencies()
            })
            .disposed(by: disposeBag)
        
        viewModel.userUpdated
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.avatarView.setup(
                    with: self.viewModel.avatarURLString,
                    avatarImage: self.viewModel.avatarImage,
                    name: self.viewModel.name
                )
                self.emailView.setup(with: self.viewModel.emailViewModel)
                self.phoneView.setup(with: self.viewModel.phoneViewModel)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupNavigationBar() {
        guard !shadowApplied else { return }
        
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.apply(style: .shadowed)
        shadowApplied = true
    }
    
    private func addSeparatorView(height: CGFloat, topAnchor: NSLayoutYAxisAnchor) -> UIView {
        let separator = UIView()
        separator.backgroundColor = Asset.Colors.whiteLilac.color
        scrollView.addSubview(separator)
        separator.layout {
            $0.top == topAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
            $0.height == height
        }
        
        return separator
    }
}
