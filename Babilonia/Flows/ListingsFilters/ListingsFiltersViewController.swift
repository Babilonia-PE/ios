//
//  ListingsFiltersViewController.swift
//  Babilonia
//
//  Created by Alya Filon  on 29.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingsFiltersViewController: NiblessViewController, AlertApplicable, HasCustomView, SpinnerApplicable {

    typealias CustomView = ListingsFiltersView
    
    let alert = ApplicationAlert()
    let spinner = AppSpinner()

    private var closeButtonItem: UIBarButtonItem!
    private var resetButtonItem: UIBarButtonItem!

    private let viewModel: ListingsFiltersViewModel
    private var shadowApplied: Bool = false
    
    init(viewModel: ListingsFiltersViewModel) {
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

        title = L10n.Filters.title

        setupViews()
        setupBindings()
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

        navigationController?.isNavigationBarHidden = false
    }

}

extension ListingsFiltersViewController {

    private func setupBindings() {
        closeButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        resetButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.resetFilters()
            })
            .disposed(by: disposeBag)

        viewModel.listingsCountObservable
            .subscribe(onNext: { [weak self] count in
                self?.customView.applyButton.descriptionText = L10n.Filters.listingsFound(count ?? 0)
            })
            .disposed(by: disposeBag)

        viewModel.facilitiesViewModels
            .subscribe(onNext: { [weak self] viewModels in
                self?.customView.updateFacilities(with: viewModels)
            })
            .disposed(by: disposeBag)

        viewModel.viewDidChange
            .subscribe(onNext: { [weak self] viewTypes in
                guard let self = self else { return }

                self.customView.setupView(with: viewTypes)
                self.customView.updateCheckmarks(with: self.viewModel.checkmarkFileldViewModels)
                self.customView.updateCounters(with: self.viewModel.counterViewModels)
                self.viewModel.reloadFilters()
            })
            .disposed(by: disposeBag)

        viewModel.histogramSlotsObservable
            .subscribe(onNext: { [weak self] slots in
                let values = slots.map { HistogramValue(index: $0.number, count: $0.listingsCount) }
                self?.customView.setupHistogram(with: values)
            })
            .disposed(by: disposeBag)

        viewModel.requestState
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .started:
                    self?.showSpinner()
                default:
                    self?.hideSpinner()
                }
            })
            .disposed(by: disposeBag)
    }

    private func setupViews() {
        setupNavigationBar()
        customView.listingTypeView.viewModel = viewModel.listingTypeViewModel
        customView.yearRangeView.viewModel = viewModel.yearViewModel
        customView.histogramView.viewModel = viewModel.histogramViewModel
        customView.totalAreaRangeView.viewModel = viewModel.totalAreaViewModel
        customView.builtAreaRangeView.viewModel = viewModel.builtAreaViewModel

        customView.applyButton.button.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.apply()
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }

    private func setupNavigationBar() {
        closeButtonItem = UIBarButtonItem(image: Asset.Common.closeIcon.image, style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = closeButtonItem
        resetButtonItem = UIBarButtonItem(title: L10n.Filters.reset, style: .plain, target: nil, action: nil)

        navigationItem.rightBarButtonItem = resetButtonItem
        navigationItem.rightBarButtonItem?.tintColor = Asset.Colors.hippieBlue.color
    }

}
