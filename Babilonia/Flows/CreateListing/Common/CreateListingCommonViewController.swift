//
//  CreateListingCommonViewController.swift
//  Babilonia
//
//  Created by Denis on 6/3/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateListingCommonViewController: UIViewController, AlertApplicable, SpinnerApplicable {
    let alert = ApplicationAlert()
    let spinner = AppSpinner()
    private let viewModel: CreateListingCommonViewModel
    private var scrollView: UIScrollView!
    private var typeTitleLabel: UILabel!
    private var segmentSelectionView: SegmentSelectionView!
    
    init(viewModel: CreateListingCommonViewModel) {
         self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        setupBindings()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
            $0.width == scrollView.widthAnchor
            $0.height == 1.0
            $0.top == scrollView.topAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
        }
        
        typeTitleLabel = UILabel()
        typeTitleLabel.text = L10n.CreateListing.Common.ListingType.title
        typeTitleLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12.0)
        typeTitleLabel.textColor = Asset.Colors.osloGray.color
        scrollView.addSubview(typeTitleLabel)
        typeTitleLabel.layout {
            $0.top == scrollView.topAnchor + 12.0
            $0.leading == scrollView.leadingAnchor + 16.0
            $0.trailing == scrollView.trailingAnchor - 16.0
            $0.height == 16.0
        }
        
        segmentSelectionView = SegmentSelectionView()
        scrollView.addSubview(segmentSelectionView)
        segmentSelectionView.layout {
            $0.top == typeTitleLabel.bottomAnchor + 12.0
            $0.leading == scrollView.leadingAnchor + 16.0
            $0.trailing == scrollView.trailingAnchor - 16.0
        }
        segmentSelectionView.setup(with: viewModel.listingTypeTitles, initialIndex: viewModel.listingTypeIndex)
    }

    private func layoutFields(for viewModels: [PropertyCommonType: InputFieldViewModel]) {
        scrollView.subviews.forEach { if $0 is InputFieldView { $0.removeFromSuperview() } }

        var lastInputView: UIView = segmentSelectionView
        var bottomViewConstraint: NSLayoutConstraint?
        var topConstraint: NSLayoutConstraint?
        viewModels.sorted { $0.key.rawValue < $1.key.rawValue }.enumerated().forEach { [weak self] model in
            guard let self = self else { return }

            let viewModel = model.element
            let index = model.offset
            let inputFieldView = InputFieldView(viewModel: viewModel.value)

            self.scrollView.addSubview(inputFieldView)
            inputFieldView.layout {
                topConstraint = $0.top.equal(to: lastInputView.bottomAnchor, offsetBy: 24.0)
                $0.leading.equal(to: scrollView.leadingAnchor, offsetBy: 16)
                $0.trailing.equal(to: scrollView.trailingAnchor, offsetBy: -16)
                bottomViewConstraint = $0.bottom.equal(to: scrollView.bottomAnchor, offsetBy: -24.0)
            }
            bottomViewConstraint?.isActive = index == viewModels.count - 1
            inputFieldView.topConstraint = topConstraint
            inputFieldView.updateConstraintsIfVisible()
            lastInputView = inputFieldView
        }
        
    }
    
    private func setupBindings() {
        viewModel.requestState
            .subscribe(onNext: { [weak self] state in
                self?.handle(state)
                switch state {
                case .started:
                    self?.showSpinner()
                default:
                    self?.hideSpinner()
                }
            })
            .disposed(by: disposeBag)
        
        segmentSelectionView.currentIndexUpdated
            .drive(onNext: viewModel.selectListingType)
            .disposed(by: disposeBag)
        viewModel.endEditingUpdated
            .emit(onNext: { [unowned self] in
                self.view.endEditing(false)
            })
            .disposed(by: disposeBag)

        viewModel.commonTypes
            .subscribe(onNext: { [weak self] models in
                guard let self = self else { return }

                let viewModels = [PropertyCommonType: InputFieldViewModel](
                    uniqueKeysWithValues: self.viewModel.inputFieldViewModels
                    .filter { models.contains($0.key) }
                )
                self.layoutFields(for: viewModels)
            })
            .disposed(by: disposeBag)
    }

    private func setupViews() {
        segmentSelectionView.isEnabled = viewModel.typeFieldsAvailable
    }
}

extension CreateListingCommonViewController: ViewAppearActionApplicable {
    
    func viewAppeared() {}
    
}
