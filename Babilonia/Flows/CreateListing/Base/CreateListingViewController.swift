//
//  CreateListingViewController.swift
//  Babilonia
//
//  Created by Denis on 5/31/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateListingViewController: UIViewController {
    
    private let viewModel: CreateListingViewModel
    
    private var scrollView: UIScrollView!
    private var continueButton: ConfirmationButton!
    private var shadowLayer: CALayer!
    private var pagingView: CreateListingPagingView!
    private var shadowView: UIView!
    private var viewsBottomConstraint: NSLayoutConstraint!
    
    private let keyboardAnimationController = KeyboardAnimationController()
    
    private var viewControllersMap = [Int: UIViewController & ViewAppearActionApplicable]()
    
    init(viewModel: CreateListingViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        layoutContainedViewControllers()
        setupBindings()
        
        setupNavigationBar()
        setupKeyboardAnimationController()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addShadows()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        keyboardAnimationController.beginTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        keyboardAnimationController.endTracking()
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.viewAppeared()
    }
    
    // MARK: - private

    private func layout() {
        view.backgroundColor = .white
        
        scrollView = UIScrollView()
        scrollView.isScrollEnabled = false
        view.addSubview(scrollView)
        scrollView.layout {
            $0.top == view.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
        }
        
        continueButton = ConfirmationButton()
        view.addSubview(continueButton)
        continueButton.layout {
            $0.leading == view.leadingAnchor + 55.0
            $0.trailing == view.trailingAnchor - 55.0
            $0.bottom == view.bottomAnchor - 24.0
            $0.height == 40.0
        }
        
        pagingView = CreateListingPagingView()
        pagingView.backgroundColor = .white
        pagingView.layer.cornerRadius = 20.0
        pagingView.clipsToBounds = true
        view.addSubview(pagingView)
        pagingView.layout {
            $0.top == scrollView.bottomAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == continueButton.topAnchor - 9.0
        }
        pagingView.setup(elements: viewModel.elements)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        view.insertSubview(backgroundView, belowSubview: continueButton)
        backgroundView.layout {
            $0.top == pagingView.topAnchor + 30.0
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
        }
        
        shadowView = UIView()
        shadowView.layer.cornerRadius = 20.0
        view.insertSubview(shadowView, belowSubview: backgroundView)
        shadowView.layout {
            $0.top == pagingView.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor + 50.0
        }
    }
    
    private func layoutContainedViewControllers() {
        var previousView: UIView?
        viewModel.elements.enumerated().forEach {
            let stepViewController = viewController(at: $0.offset)
            
            addChild(stepViewController)
            scrollView.addSubview(stepViewController.view)
            stepViewController.didMove(toParent: self)
            
            stepViewController.view.layout {
                $0.leading == previousView?.trailingAnchor ?? scrollView.leadingAnchor
                $0.top == scrollView.topAnchor
                $0.bottom == scrollView.bottomAnchor
                
                if let previousView = previousView {
                    $0.width == previousView.widthAnchor
                } else {
                    viewsBottomConstraint = $0.bottom == pagingView.topAnchor
                    $0.width == scrollView.widthAnchor
                }
            }
            previousView = stepViewController.view
        }
        previousView?.layout {
            $0.trailing == scrollView.trailingAnchor
        }
    }
    
    private func addShadows() {
        guard shadowLayer == nil else { return }
        shadowLayer = shadowView.layer.addShadowLayer(
            color: Asset.Colors.vulcan.color.withAlphaComponent(0.2).cgColor,
            offset: .zero,
            radius: 5.0,
            cornerRadius: 20.0
        )
    }
    
    private func setupBindings() {
        pagingView.currentIndexUpdated
            .drive(onNext: viewModel.updateCurrentIndex)
            .disposed(by: disposeBag)
        pagingView.allPagesFilled
            .drive(onNext: viewModel.finishCreation)
            .disposed(by: disposeBag)
        
        continueButton.rx.tap
            .bind(onNext: pagingView.proceedWithNextStep)
            .disposed(by: disposeBag)
        
        viewModel.continueTitle
            .drive(onNext: { [weak self] value in
                self?.updateContinueTitle(value)
            })
            .disposed(by: disposeBag)
        viewModel.currentIndexUpdated
            .drive(onNext: { [weak self] value in
                self?.indexUpdated(value)
            })
            .disposed(by: disposeBag)
        viewModel.continueButtonEnabled
            .drive(continueButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    //swiftlint:disable force_cast
    private func viewController(at index: Int) -> UIViewController & ViewAppearActionApplicable {
        if let viewController = viewControllersMap[index] {
            return viewController
        } else {
            let viewController: UIViewController & ViewAppearActionApplicable
            let stepViewModel = viewModel.viewModel(at: index)
            switch stepViewModel {
            case is CreateListingCommonViewModel:
                viewController = CreateListingCommonViewController(
                    viewModel: stepViewModel as! CreateListingCommonViewModel
                )
            case is CreateListingDetailsViewModel:
                viewController = CreateListingDetailsViewController(
                    viewModel: stepViewModel as! CreateListingDetailsViewModel
                )
            case is CreateListingFacilitiesViewModel:
                viewController = CreateListingFacilitiesViewController(
                    viewModel: stepViewModel as! CreateListingFacilitiesViewModel
                )
            case is CreateListingAdvancedViewModel:
                viewController = CreateListingAdvancedViewController(
                    viewModel: stepViewModel as! CreateListingAdvancedViewModel
                )
            case is CreateListingPhotosViewModel:
                viewController = CreateListingPhotosViewController(
                    viewModel: stepViewModel as! CreateListingPhotosViewModel
                )
            default:
                fatalError("undefined type of \(stepViewModel)")
            }
            
            viewControllersMap[index] = viewController
            
            return viewController
        }
    }
    //swiftlint:enable force_cast
    
    private func indexUpdated(_ index: Int) {
        let offset = CGPoint(x: scrollView.frame.width * CGFloat(index), y: scrollView.contentOffset.y)
        scrollView.setContentOffset(offset, animated: true)
        viewController(at: index).viewAppeared()
    }
    
    private func updateContinueTitle(_ text: String) {
        let title = text.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 12.0),
            lineSpacing: 0.0,
            alignment: .center,
            color: .white,
            kern: 1
        )
        continueButton.setAttributedTitle(title, for: .normal)
    }
    
    private func setupKeyboardAnimationController() {
        keyboardAnimationController.willAnimatedKeyboardPresentation = { [unowned self] frame in
            let bottomPartHeight = self.view.bounds.height - self.pagingView.frame.origin.y
            self.viewsBottomConstraint?.constant = -(frame.height - bottomPartHeight)
        }
        keyboardAnimationController.willAnimatedKeyboardFrameChange = { [unowned self] frame in
            let bottomPartHeight = self.view.bounds.height - self.pagingView.frame.origin.y
            self.viewsBottomConstraint?.constant = -(frame.height - bottomPartHeight)
        }
        keyboardAnimationController.willAnimatedKeyboardDismissal = { [unowned self] _ in
            self.viewsBottomConstraint?.constant = 0.0
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = viewModel.title
        
        let button = UIBarButtonItem(
            title: L10n.CreateListing.Finish.Button.title,
            style: .plain,
            target: nil,
            action: nil
        )
        button.apply(style: .action)
        button.rx.tap
            .bind { [weak self] in
                self?.presentExitAlert()
            }
            .disposed(by: disposeBag)
        navigationItem.rightBarButtonItem = button
    }
    
    private func presentExitAlert() {
        let settings = viewModel.exitPopupSettings
        let alert = UIAlertController(
            title: settings.title,
            message: settings.text,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: L10n.CreateListing.Finish.Popup.DontSaveAndExit.title,
            style: .default,
            handler: { [unowned self] _ in
                self.viewModel.close()
            }
        ))
        if settings.canSave {
            alert.addAction(UIAlertAction(
                title: L10n.CreateListing.Finish.Popup.SaveAndExit.title,
                style: .default,
                handler: { [unowned self] _ in
                    self.viewModel.saveAndClose()
                }
            ))
        }
        alert.addAction(UIAlertAction(
            title: settings.continueTitle,
            style: .cancel,
            handler: nil
        ))
        
        present(alert, animated: true, completion: nil)
    }
    
}
