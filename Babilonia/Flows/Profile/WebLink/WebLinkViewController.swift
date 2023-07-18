//
//  WebLinkViewController.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/16/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa

final class WebLinkViewController: UIViewController {
    
    private var webView: WKWebView!
    private var backButton: UIBarButtonItem!
    
    private var shadowApplied: Bool = false
    
    private let viewModel: WebLinkViewModel
    
    // MARK: - lifecycle
    
    init(viewModel: WebLinkViewModel) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = viewModel.url else { return }
        
        webView.load(URLRequest(url: url))
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
        webView = WKWebView()
        view.addSubview(webView)
        webView.layout {
            $0.top == view.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
    }
    
    private func setupBindings() {
        backButton.rx.tap
            .bind { [weak self] in
                self?.viewModel.close()
            }
            .disposed(by: disposeBag)
    }
    
    private func setupNavigationBar() {
        title = viewModel.title
        // TODO: update button on back when resolve Tabbar hidding
        backButton = UIBarButtonItem(
            image: Asset.Common.closeIcon.image,
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.leftBarButtonItem = backButton
    }
    
}
