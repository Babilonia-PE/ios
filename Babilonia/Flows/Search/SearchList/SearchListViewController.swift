//
//  SearchListViewController.swift
//  Babilonia
//
//  Created by Denis on 7/25/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchListViewController: UIViewController, AlertApplicable, SpinnerApplicable {
    
    let alert = ApplicationAlert()
    let spinner = AppSpinner()
    
    private var tableView: UITableView!
    private var emptyStateView: UIView!
    private let topView: SearchListingSortView = .init()
    private let viewModel: SearchListViewModel
    private let topListingsView: TopListingsHeaderView = .init()

    private var sortViewHeightConstraint: NSLayoutConstraint?
    private var tableViewTopConstraint: NSLayoutConstraint?
    
    // MARK: - lifecycle
    
    init(viewModel: SearchListViewModel) {
         self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        setupViews()
        setupBindings()
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if viewModel.shouldReloadOnAppear {
            viewModel.fetchListings() 
        }
        viewModel.shouldReloadOnAppear = true
    }

    // MARK: - private

    private func layout() {
        tableView = UITableView(frame: .zero, style: .grouped)
        view.addSubview(tableView)
        tableView.layout {
            tableViewTopConstraint = $0.top.equal(to: view.safeAreaLayoutGuide.topAnchor)
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
        }

        view.addSubview(topView)
        topView.layout {
            $0.top == view.safeAreaLayoutGuide.topAnchor + 13.0
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            sortViewHeightConstraint = $0.height.equal(to: 0)
        }
        
        emptyStateView = SearchListingEmptyView()
        view.addSubview(emptyStateView)
        emptyStateView.layout {
            $0.top == view.topAnchor + 13.0
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white

        setupTopListingsHeader()
        topView.isHidden = true
        emptyStateView.isHidden = true

        topView.actionButton.rx.tap
            .subscribe(onNext: showSortView)
            .disposed(by: disposeBag)
        
        topListingsView.sortView.actionButton.rx.tap
            .subscribe(onNext: showSortView)
            .disposed(by: disposeBag)
    }
    
    private func setupBindings() {
        setupTopListingsBindings()
        setupListingsBindings()

        bind(requestState: viewModel.requestState)
        viewModel.requestState
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .started:
                    self.spinner.show(on: self.view, text: nil, blockUI: false)
                default:
                    self.hideSpinner()
                    self.tableView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.sortOptionTitle
            .drive(onNext: { [weak self] text in
                self?.topView.sortOptionLabel.text = text
                self?.topListingsView.sortView.sortOptionLabel.text = text
            })
            .disposed(by: disposeBag)

        viewModel.showLocationPromptUpdated
            .filter { $0 }
            .emit(onNext: { [weak self] shouldShow in
                if shouldShow {
                    self?.presentLocationPermissionPopup()
                }
            })
            .disposed(by: disposeBag)

        viewModel.requestForLocationPermissionObservable
            .skip(1)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                SystemAlert.present(on: self,
                                    title: L10n.SearchByLocation.PermissionPopUp.title,
                                    message: L10n.SearchByLocation.PermissionPopUp.message)
            })
            .disposed(by: disposeBag)
    }

    private func setupListingsBindings() {
        viewModel.emptyStateNeeded
            .drive(onNext: { [weak self] isEmpty in
                guard let self = self else { return }

                let isEmptyListings = self.viewModel.topListings.isEmpty
                                    && self.viewModel.listingsCount == 0
                let isEmptyState = isEmpty || isEmptyListings
                self.emptyStateView.isHidden = !isEmptyState
                self.topView.isHidden = isEmptyState
                self.tableView.isHidden = isEmptyState
                self.topListingsView.isHidden = isEmptyState
                self.topListingsView.sortView.isHidden = self.viewModel.listingsCount == 0
            })
            .disposed(by: disposeBag)

        viewModel.listingsUpdated
            .subscribe(onNext: { [weak self] newIndexPathsToReload in
                guard let self = self else { return }

                if let indexPathes = newIndexPathsToReload,
                   let maxRow = indexPathes.map({ $0.row }).max(),
                   maxRow >= self.viewModel.listingsCount {
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath(row: self.viewModel.listingsCount - 1,
                                                             section: 0)],
                                              with: .automatic)
                    self.tableView.endUpdates()
                } else {
                    self.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }

    private func setupTopListingsBindings() {
        viewModel.topListingsViewUpdatable
            .subscribe(onNext: { [weak self] in
                self?.tableView.reloadData()
                self?.updateTopAppearance()
            })
            .disposed(by: disposeBag)

        viewModel.topListingsUpdated
            .subscribe(onNext: { [weak self] in
                self?.topListingsView.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    private func setupTopListingsHeader() {
        topListingsView.collectionView.dataSource = self
        topListingsView.collectionView.delegate = self
    }

    private func updateTopAppearance() {
        if viewModel.shouldShowTopListings {
            sortViewHeightConstraint?.constant = 0
            tableViewTopConstraint?.constant = -20
        } else {
            sortViewHeightConstraint?.constant = 40
            tableViewTopConstraint?.constant = 30
        }

        view.layoutIfNeeded()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerReusableCell(cellType: ListingTableViewCell.self)
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.rowHeight = 272.0
        tableView.backgroundColor = .white
        tableView.isHidden = true
    }
    
    private func showSortView() {
        let picker = SortPickerView()
        let items = SortOption.allCases.map { ($0.rawValue, $0.title) }
        picker.setupItems(items: items)
        picker.select(id: viewModel.sortOptionValue.rawValue)
        present(actionSheetView: picker)
        
        picker.itemSelected = { [weak self] id in
            self?.viewModel.setSortOption(with: id)
        }
    }
    
    private func presentLocationPermissionPopup() {
        guard let window = UIApplication.shared.delegate?.window, let presentingView = window else { return }
        let popupView = LocationPermissionPopupView(popupViewType: .location)
        
        let doneAction = { [unowned viewModel, popupView] in
            viewModel.acceptedLocationRequest()
            popupView.hide()
        }
        let cancelAction = { [unowned viewModel, popupView] in
            viewModel.permissionNotGrantedYet()
            popupView.hide()
        }
        
        popupView.setup(with: doneAction, cancelAction: cancelAction)
        popupView.show(in: presentingView)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SearchListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listingsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath) as ListingTableViewCell
        cell.setup(with: viewModel.listingPreviewViewModel(at: indexPath.row))

        cell.didToggleFavorite = { [weak self] _ in
            self?.viewModel.setListingFavoriteState(at: indexPath.row)
        }
        cell.didToggleDetails = { [weak self] _ in
            self?.viewModel.presentListingDetails(for: indexPath.row)
        }
        cell.didTogglePhotoTap = { [weak self] in
            self?.viewModel.presentListingDetails(for: indexPath.row)
        }

        if indexPath.row == viewModel.listingsCount - 1 {
            viewModel.incrementPage()
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.presentListingDetails(for: indexPath.row)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        viewModel.shouldShowTopListings ? topListingsView : nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        viewModel.shouldShowTopListings ? 373 : 0
    }

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)

        return Array(indexPathsIntersection)
    }

}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension SearchListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.topListings.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(indexPath) as TopListingPreviewCell
        cell.apply(with: viewModel.listingPreviewViewModel(at: indexPath.row, isTopListing: true))
        cell.didToggleFavorite = { [weak self] _ in
            self?.viewModel.setListingFavoriteState(at: indexPath.row, isTopListing: true)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.presentListingDetails(for: indexPath.row, isTopListing: true)
    }

}
