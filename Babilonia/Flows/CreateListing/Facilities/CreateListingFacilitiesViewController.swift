//
//  CreateListingFacilitiesViewController.swift
//  Babilonia
//
//  Created by Denis on 6/3/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateListingFacilitiesViewController: UIViewController, AlertApplicable, SpinnerApplicable {
    
    let alert = ApplicationAlert()
    let spinner = AppSpinner()
    
    private let viewModel: CreateListingFacilitiesViewModel
    
    private var scrollView: UIScrollView!
    private var facilitiesLabel: UILabel!
    private var facilityViews = [CreateListingFacilityView]()
    private var emptyStateLabel: UILabel!
    
    // MARK: - lifecycle
    
    init(viewModel: CreateListingFacilitiesViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        setupViews()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private
    
    private func layout() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
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
        
        emptyStateLabel = UILabel()
        view.addSubview(emptyStateLabel)
        emptyStateLabel.layout {
            $0.leading == view.leadingAnchor + 62.0
            $0.trailing == view.trailingAnchor - 62.0
            $0.centerY == view.centerYAnchor - 15.0
        }
    }
    
    private func setupViews() {
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textAlignment = .center
    }
    
    private func layoutFacilities(with viewModels: [CreateListingFacilityViewModel]) {
        facilitiesLabel?.removeFromSuperview()
        facilitiesLabel = UILabel()
        scrollView.addSubview(facilitiesLabel)
        facilitiesLabel.layout {
            $0.top == scrollView.topAnchor + 8.0
            $0.leading == scrollView.leadingAnchor + 16.0
            $0.trailing == scrollView.trailingAnchor - 16.0
            $0.height >= 24.0
        }
        
        var lastView: UIView = facilitiesLabel
        
        facilityViews.forEach { $0.removeFromSuperview() }
        facilityViews = [CreateListingFacilityView]()
        
        viewModels.forEach {
            let facilityView = CreateListingFacilityView(viewModel: $0)
            scrollView.addSubview(facilityView)
            facilityView.layout {
                $0.top == lastView.bottomAnchor
                $0.leading == scrollView.leadingAnchor
                $0.trailing == scrollView.trailingAnchor
            }
            
            facilityViews.append(facilityView)
            lastView = facilityView
        }
        
        lastView.layout {
            $0.bottom == scrollView.bottomAnchor - 28.0
        }
    }
    
    private func setupFacilitiesViews() {
        facilitiesLabel.numberOfLines = 0
        facilitiesLabel.textAlignment = .left
        facilitiesLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12.0)
        facilitiesLabel.textColor = Asset.Colors.osloGray.color
        facilitiesLabel.text = L10n.CreateListing.Facilities.title
    }
    
    private func setupBindings() {
        bind(requestState: viewModel.requestState)
        
        viewModel.requestState.isLoading
            .bind { [weak self] value in
                self?.updateLoadingState(value)
            }
            .disposed(by: disposeBag)
        
        viewModel.viewModelsUpdated
            .drive(onNext: { [unowned self] viewModels in
                self.layoutFacilities(with: viewModels)
                self.setupFacilitiesViews()
                self.facilitiesLabel.isHidden = viewModels.isEmpty
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
            .drive(emptyStateLabel.rx.attributedText)
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

extension CreateListingFacilitiesViewController: ViewAppearActionApplicable {
    
    func viewAppeared() {
        viewModel.viewAppeared()
    }
    
}
