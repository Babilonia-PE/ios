//
//  ListingDetailsViewController.swift
//  Babilonia
//
//  Created by Denis on 7/11/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingDetailsViewController: UIViewController {
    
    private var scrollView: UIScrollView!
    private var photosView: ListingDetailsPhotosView!
    private let paymentPlanView: ListingPaymentPlanView = .init()
    private var commonView: ListingDetailsCommonView!
    private var addressView: ListingDetailsAddressView!
    private var descriptionView: ListingDetailsDescriptionView!
    private var facilitiesView: ListingDetailsFacilitiesView!
    private var advancedDetailsView: ListingDetailsFacilitiesView!

    private var planHeightConstraint: NSLayoutConstraint?
    
    private let viewModel: ListingDetailsViewModel

    var toggleMapViewTap: (() -> Void)?
    var togglePhotoGalleryTap: (() -> Void)?
    
    // MARK: - lifecycle
    
    init(viewModel: ListingDetailsViewModel) {
         self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        setupViews()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        scrollView.contentInset = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: view.safeAreaInsets.bottom + 88.0,
            right: 0.0
        )
    }
    
    // MARK: - private
    
    //swiftlint:disable:next function_body_length
    private func layout() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
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
        
        photosView = ListingDetailsPhotosView()
        photosView.togglePhotoGalleryTap = { [weak self] in
            self?.togglePhotoGalleryTap?()
        }

        scrollView.addSubview(photosView)
        photosView.layout {
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
            $0.top == scrollView.topAnchor
            $0.height == 240.0
        }

        paymentPlanView.isHidden = true
        scrollView.addSubview(paymentPlanView)
        paymentPlanView.layout {
            $0.leading.equal(to: scrollView.leadingAnchor)
            $0.trailing.equal(to: scrollView.trailingAnchor)
            $0.top.equal(to: photosView.bottomAnchor)
            planHeightConstraint = $0.height.equal(to: 0, priority: UILayoutPriority(rawValue: 999))
        }
        
        commonView = ListingDetailsCommonView()
        scrollView.addSubview(commonView)
        commonView.layout {
            $0.top.equal(to: paymentPlanView.bottomAnchor)
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
        }
        
        let separatorView = UIView()
        separatorView.backgroundColor = Asset.Colors.whiteLilac.color
        scrollView.addSubview(separatorView)
        separatorView.layout {
            $0.top == commonView.bottomAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
            $0.height == 8.0
        }
        
        addressView = ListingDetailsAddressView()
        addressView.toggleMapViewTap = { [weak self] in
            self?.toggleMapViewTap?()
        }

        scrollView.addSubview(addressView)
        addressView.layout {
            $0.top == separatorView.bottomAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
        }
        
        descriptionView = ListingDetailsDescriptionView()
        scrollView.addSubview(descriptionView)
        descriptionView.layout {
            $0.top == addressView.bottomAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
        }
        
        facilitiesView = ListingDetailsFacilitiesView()
        scrollView.addSubview(facilitiesView)
        facilitiesView.layout {
            $0.top == descriptionView.bottomAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
        }

        advancedDetailsView = ListingDetailsFacilitiesView()
        scrollView.addSubview(advancedDetailsView)
        advancedDetailsView.layout {
            $0.top == facilitiesView.bottomAnchor
            $0.leading == scrollView.leadingAnchor
            $0.trailing == scrollView.trailingAnchor
            $0.bottom == scrollView.bottomAnchor
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.bounces = false

        if let paymentPlanViewModel = viewModel.paymentPlanViewModel {
            setupPyamentPlan(viewModel: paymentPlanViewModel)
        }
    }

    private func setupPyamentPlan(viewModel: ListingPaymentPlanViewModel) {
        let shouldHidePlan = !viewModel.isPlanPurchased
        paymentPlanView.apply(viewModel)
        planHeightConstraint?.constant = shouldHidePlan ? 0 : 34
        paymentPlanView.isHidden = shouldHidePlan
    }
    
    private func setupBindings() {
        descriptionView
            .showMoreTapAction
            .bind(onNext: viewModel.showDescription)
            .disposed(by: disposeBag)
        
        viewModel.photosUpdated
            .drive(onNext: photosView.setup)
            .disposed(by: disposeBag)
        viewModel.commonInfoUpdated
            .drive(onNext: commonView.setup)
            .disposed(by: disposeBag)
        viewModel.addressInfoUpdated
            .drive(onNext: addressView.setup)
            .disposed(by: disposeBag)
        viewModel.descriptionUpdated
            .drive(onNext: descriptionView.setup)
            .disposed(by: disposeBag)
        viewModel.facilitiesUpdated
            .drive(onNext: { [weak self] infos in
                self?.facilitiesView.setup(with: .facility, infos: infos)
            })
            .disposed(by: disposeBag)
        viewModel.advancedDetailsUpdated
            .drive(onNext: { [weak self] infos in
                self?.advancedDetailsView.setup(with: .advanced, infos: infos)
            })
            .disposed(by: disposeBag)
    }
}
