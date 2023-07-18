//
//  LocationSearchViewController.swift
//  Babilonia
//
//  Created by Alya Filon  on 17.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class LocationSearchViewController: NiblessViewController, AlertApplicable, HasCustomView {
    
    typealias CustomView = LocationSearchView
    
    let alert = ApplicationAlert()
    
    private let viewModel: LocationSearchViewModel
    private var viewDidSet = false
    
    init(viewModel: LocationSearchViewModel) {
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

        setupViews()
        setupViewBindings()
        setupViewModelBindings()
        viewModel.fetchRecentSearches()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        customView.animateSearchBar(onAppear: true)
    }

    private func setupViews() {
        customView.tableView.dataSource = self
        customView.tableView.delegate = self

        customView.searchBar.text = viewModel.searchTerm
        customView.searchBar.becomeFirstResponder()

        customView.animationOnDisappearHandler = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Bindings
    
    private func setupViewBindings() {
        customView.cancelButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.customView.animateSearchBar(onAppear: false)
            })
            .disposed(by: disposeBag)

        customView.currentLocationButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.requestCurrentLocation()
            })
            .disposed(by: disposeBag)

        customView.searchBar.rx.text
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                guard let text = text,
                    !text.isEmpty,
                    text.count >= 3 else { return }

                if self?.viewModel.isCurrentLocationSearch == true {
                    self?.viewModel.isCurrentLocationSearch = self?.viewDidSet != true
                }

                self?.viewModel.searchLocations(with: text)
                self?.viewDidSet = true
            })
            .disposed(by: disposeBag)

        customView.searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { [weak self] in
                self?.customView.setNotFoundView(isHidden: true)
            })
            .disposed(by: disposeBag)

        customView.searchButtonSelected = { [weak self] text in
            self?.viewModel.proccedSearch(with: text)
        }
    }

    private func setupViewModelBindings() {
        viewModel.currentLocationObservable
            .subscribe(onNext: { [weak self] address in
                guard let address = address else { return }

                self?.customView.searchBar.text = address
                self?.viewModel.searchLocations(with: address)
            })
            .disposed(by: disposeBag)

        viewModel.locationsObservable
            .skip(1)
            .subscribe(onNext: { [weak self] locations in
                guard self?.viewModel.isCurrentLocationSearch == false else {
                    self?.customView.viewType = .empty

                    return
                }
                if locations.isEmpty {
                    let recentSearchesNotEmpty = self?.viewModel.recentSearches.isEmpty == false
                    self?.customView.viewType = .notFound(recentSearchesNotEmpty: recentSearchesNotEmpty)
                } else {
                    self?.customView.viewType = .locations
                }
                self?.customView.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        viewModel.recentSearchesObservable
            .skip(1)
            .subscribe(onNext: { [weak self] searches in
                guard self?.viewModel.isCurrentLocationSearch == false else { return }
                if !searches.isEmpty {
                    self?.customView.viewType = .recentSearches
                    self?.customView.tableView.reloadData()
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
}

extension LocationSearchViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.resultRowsCount(isRecentSearches: customView.shouldShowRecentSearches)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath) as LocationSearchCell

        cell.locationLabel.text = viewModel.resultName(isRecentSearches: customView.shouldShowRecentSearches,
                                                       index: indexPath.row)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.updateListingsWithAddress(at: indexPath.row, isRecentSearches: customView.shouldShowRecentSearches)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        customView.recentSearchesHeader
    }

}
