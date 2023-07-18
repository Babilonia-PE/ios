//
//  CurrencyViewController.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/19/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CurrencyViewController: UIViewController {
    
    private var backButton: UIBarButtonItem!
    private var scrollView: UIScrollView!
    private var widthView: UIView!
    private var currencyViews = [CurrencyItemView]()
    
    private var shadowApplied: Bool = false
    
    private let viewModel: CurrencyViewModel
    
    // MARK: - lifecycle
    
    init(viewModel: CurrencyViewModel) {
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !shadowApplied {
            navigationController?.navigationBar.apply(style: .shadowed)
            shadowApplied = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - private

    private func layout() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.layout {
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
        }
        
        widthView = UIView()
        scrollView.addSubview(widthView)
        widthView.layout {
            $0.top == scrollView.topAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
            $0.width == scrollView.widthAnchor
            $0.height == 16.0
        }
    }
    
    private func layoutCurrencies(with viewModels: [CurrencyItemViewModel]) {
        currencyViews.forEach { $0.removeFromSuperview() }
        
        var lastView: UIView = widthView
        viewModels.forEach {
            let currencyView = CurrencyItemView(viewModel: $0)
            scrollView.addSubview(currencyView)
            currencyView.layout {
                $0.top == lastView.bottomAnchor
                $0.leading == scrollView.leadingAnchor
                $0.trailing == scrollView.trailingAnchor
            }
            
            currencyViews.append(currencyView)
            lastView = currencyView
        }
        
        lastView.layout {
            $0.bottom == scrollView.bottomAnchor - 20.0
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        scrollView.backgroundColor = .white
    }
    
    private func setupBindings() {
        viewModel.viewModelsUpdated
            .drive(onNext: { [weak self] viewModels in
                self?.layoutCurrencies(with: viewModels)
            })
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .bind(onNext: { [weak viewModel] in
                viewModel?.close()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = L10n.Profile.Currency.title
        
        backButton = UIBarButtonItem(
            image: Asset.Common.closeIcon.image,
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.leftBarButtonItem = backButton
    }
}
