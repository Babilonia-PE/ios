//
//  CreateListingPreviewViewController.swift
//  Babilonia
//
//  Created by Denis on 7/11/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateListingPreviewViewController: UIViewController, AlertApplicable, SpinnerApplicable {
    
    let alert = ApplicationAlert()
    let spinner = AppSpinner()
    
    private var containerView: UIView!
    
    private var exitButton: UIButton!
    private var backButton: UIButton!
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    private var gradientView: UIView!
    private var gradientLayer: CALayer!
    private var publishButton: UIButton!
    
    private let viewModel: CreateListingPreviewViewModel
    
    private var litingDetailsViewController: ListingDetailsViewController {
        return ListingDetailsViewController(viewModel: viewModel.listingDetailsViewModel)
    }
    
    // MARK: - lifecycle
    
    init(viewModel: CreateListingPreviewViewModel) {
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
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard gradientLayer == nil, gradientView.frame != .zero else { return }
        gradientLayer = gradientView.layer.addGradientLayer(
            colors: [
                Asset.Colors.vulcan.color.withAlphaComponent(0.8).cgColor,
                UIColor.clear.cgColor
            ],
            locations: [0.0, 1.0]
        )
    }
    
    // MARK: - private
    
    //swiftlint:disable:next function_body_length
    private func layout() {
        containerView = UIView()
        view.addSubview(containerView)
        containerView.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
        }
        
        let detailsController = litingDetailsViewController
        addChild(detailsController)
        containerView.addSubview(detailsController.view)
        detailsController.didMove(toParent: self)
        detailsController.view.layout {
            $0.leading == containerView.leadingAnchor
            $0.trailing == containerView.trailingAnchor
            $0.top == containerView.topAnchor
            $0.bottom == containerView.bottomAnchor
        }
        
        backButton = UIButton()
        view.addSubview(backButton)
        backButton.layout {
            $0.top == view.safeAreaLayoutGuide.topAnchor
            $0.leading == view.leadingAnchor
        }
        
        exitButton = UIButton()
        view.addSubview(exitButton)
        exitButton.layout {
            $0.top == view.safeAreaLayoutGuide.topAnchor
            $0.trailing == view.trailingAnchor
        }
        
        titleLabel = UILabel()
        view.addSubview(titleLabel)
        titleLabel.layout {
            $0.leading >= backButton.trailingAnchor
            $0.trailing <= exitButton.leadingAnchor
            $0.top == view.safeAreaLayoutGuide.topAnchor + 11.0
            $0.height == 22.0
            $0.centerX == view.centerXAnchor
        }
        
        subtitleLabel = UILabel()
        view.addSubview(subtitleLabel)
        subtitleLabel.layout {
            $0.leading >= backButton.trailingAnchor
            $0.trailing <= exitButton.leadingAnchor
            $0.top == titleLabel.bottomAnchor - 1.0
            $0.height == 16.0
            $0.centerX == view.centerXAnchor
        }
        
        gradientView = UIView()
        view.insertSubview(gradientView, belowSubview: backButton)
        gradientView.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.top == view.topAnchor
            $0.bottom == backButton.bottomAnchor
        }
        
        publishButton = ConfirmationButton()
        view.addSubview(publishButton)
        publishButton.layout {
            $0.leading == view.leadingAnchor + 16.0
            $0.trailing == view.trailingAnchor - 16.0
            $0.bottom == view.safeAreaLayoutGuide.bottomAnchor - 24.0
            $0.height == 56.0
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.backButtonTitle = ""
        
        let image = Asset.Common.backIcon.image.withRenderingMode(.alwaysTemplate)
        backButton.setImage(image, for: .normal)
        backButton.setImage(image, for: .highlighted)
        backButton.tintColor = .white
        backButton.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 12.0, bottom: 10.0, right: 12.0)
        
        exitButton.setAttributedTitle(
            viewModel.finishButtonTitle.toAttributed(
                with: FontFamily.AvenirLTStd._85Heavy.font(size: 17.0),
                lineSpacing: 0.0,
                alignment: .center,
                color: .white,
                kern: -0.4
            ),
            for: .normal
        )
        exitButton.contentEdgeInsets = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 12.0, right: 16.0)
        
        publishButton.titleLabel?.font = FontFamily.SamsungSharpSans.bold.font(size: 16.0)
        publishButton.setTitleColor(.white, for: .normal)

        titleLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 16.0)
        titleLabel.textColor = .white
        titleLabel.text = L10n.CreateListing.ListingPreview.title
        
        subtitleLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 12.0)
        subtitleLabel.textColor = .white
    }
    
    private func setupBindings() {
        bind(requestState: viewModel.requestState)
        
        exitButton.rx.tap
            .bind(onNext: viewModel.exit)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .bind(onNext: viewModel.back)
            .disposed(by: disposeBag)
        
        publishButton.rx.tap
            .bind(onNext: viewModel.publishListing)
            .disposed(by: disposeBag)
        
        viewModel.requestState.isLoading
            .bind { [weak self] value in
                self?.updateLoadingState(value)
            }
            .disposed(by: disposeBag)

        viewModel.buttonActionUpdated
            .map { $0.title }
            .bind(onNext: { [weak self] text in self?.publishButton.setTitle(text, for: .normal) })
            .disposed(by: disposeBag)

        viewModel.listingStatus.bind(to: subtitleLabel.rx.text).disposed(by: disposeBag)
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            spinner.show(on: view, text: nil, blockUI: true)
        } else {
            spinner.hide(from: view)
        }
    }
    
}
