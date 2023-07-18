//
//  CreateListingDetailsViewController.swift
//  Babilonia
//
//  Created by Denis on 6/3/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateListingDetailsViewController: UIViewController {
    
    private let viewModel: CreateListingDetailsViewModel
    
    private var scrollView: UIScrollView!
    private var numberFieldViews = [NumberFieldView]()
    private var checkboxFieldViews = [SwitchFieldView]()
    private let emptyStateLabel: UILabel = .init()
    
    // MARK: - lifecycle
    
    init(viewModel: CreateListingDetailsViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private
    
    //swiftlint:disable:next function_body_length
    private func layout() {
        scrollView?.removeFromSuperview()
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
        }

        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)
        emptyStateLabel.layout {
            $0.leading == view.leadingAnchor + 62.0
            $0.trailing == view.trailingAnchor - 62.0
            $0.centerY == view.centerYAnchor - 15.0
        }
        
        let scrollViewWidthView = UIView()
        scrollView.addSubview(scrollViewWidthView)
        scrollViewWidthView.layout {
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
            $0.top == scrollView.topAnchor
            $0.height == 1.0
            $0.width == scrollView.widthAnchor
        }
        
        numberFieldViews.forEach { $0.removeFromSuperview() }
        numberFieldViews = []

        var lastBottomView: UIView!
        var topAnchor = scrollView.topAnchor
        viewModel.numberControlTypesViewModels.enumerated().forEach { index, viewModel in
            let fieldView = NumberFieldView(viewModel: viewModel)
            scrollView.addSubview(fieldView)
            fieldView.layout {
                $0.top == topAnchor + (index == 0 ? 24.0 : 32.0)
                $0.leading == scrollView.leadingAnchor + 16.0
                $0.trailing == scrollView.trailingAnchor - 24.0
            }
            topAnchor = fieldView.bottomAnchor
            lastBottomView = fieldView
            numberFieldViews.append(fieldView)
        }

        checkboxFieldViews.forEach { $0.removeFromSuperview() }
        checkboxFieldViews = []
        viewModel.ckeckboxControlTypesViewModels.forEach {
            let inputFieldView = CreateListingFacilityView(viewModel: $0)
            scrollView.addSubview(inputFieldView)

            let topOffset: CGFloat = lastBottomView is NumberFieldView ? 24 : 0
            inputFieldView.layout {
                $0.top == lastBottomView.bottomAnchor + topOffset
                $0.leading == scrollView.leadingAnchor
                $0.trailing == scrollView.trailingAnchor
            }
            lastBottomView = inputFieldView
        }

        if numberFieldViews.isEmpty && checkboxFieldViews.isEmpty {
            scrollView.isHidden = true
            emptyStateLabel.isHidden = false
        } else {
            lastBottomView.layout {
                $0.bottom == scrollView.bottomAnchor - 32.0
            }
        }
    }
    
    private func setupBindings() {
        viewModel.endEditingUpdated
            .emit(onNext: { [unowned self] in
                self.view.endEditing(false)
            })
            .disposed(by: disposeBag)

        viewModel.emptyStateTitle
            .map { $0.toAttributed( with: FontFamily.SamsungSharpSans.bold.font(size: 14.0),
                                    lineSpacing: 6.0,
                                    alignment: .center,
                                    color: Asset.Colors.vulcan.color,
                                    kern: 0)
            }
            .bind(to: emptyStateLabel.rx.attributedText)
            .disposed(by: disposeBag)
    }
    
}

extension CreateListingDetailsViewController: ViewAppearActionApplicable {
    
    func viewAppeared() {
        viewModel.viewAppeared()
        
        layout()
    }
    
}
