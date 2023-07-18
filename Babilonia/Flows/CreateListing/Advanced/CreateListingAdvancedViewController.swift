//
//  CreateListingAdvancedViewController.swift
//  Babilonia
//
//  Created by Alya Filon  on 22.12.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//swiftlint:disable:next line_length
final class CreateListingAdvancedViewController: NiblessViewController, HasCustomView, SpinnerApplicable, AlertApplicable {
    
    typealias CustomView = CreateListingAdvancedView

    let alert = ApplicationAlert()
    let spinner = AppSpinner()
    
    private let viewModel: CreateListingAdvancedViewModel
    
    init(viewModel: CreateListingAdvancedViewModel) {
         self.viewModel = viewModel
        
        super.init()
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        let customView = CustomView()
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        bind(requestState: viewModel.requestState)

        viewModel.requestState.isLoading
            .bind { [weak self] value in
                self?.updateLoadingState(value)
            }
            .disposed(by: disposeBag)

        viewModel.viewModelsUpdated
            .drive(onNext: { [unowned self] viewModels in
                self.customView.layoutDetails(with: viewModels)
                self.customView.titleLabel.isHidden = viewModels.isEmpty
            })
            .disposed(by: disposeBag)

        viewModel.emptyStateTitle
            .map {
                $0?.toAttributed(
                    with: FontFamily.SamsungSharpSans.bold.font(size: 14.0),
                    lineSpacing: 6.0,
                    alignment: .center,
                    color: Asset.Colors.vulcan.color,
                    kern: 0
                )
            }
            .drive(customView.emptyStateLabel.rx.attributedText)
            .disposed(by: disposeBag)
    }

    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            spinner.show(on: view, text: nil, blockUI: false)
        } else {
            spinner.hide(from: view)
        }
    }
}

extension CreateListingAdvancedViewController: ViewAppearActionApplicable {

    func viewAppeared() {
        viewModel.viewAppeared()
    }

}
