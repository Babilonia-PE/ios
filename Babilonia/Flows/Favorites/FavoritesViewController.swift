//
//  FavoritesViewController.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class FavoritesViewController: NiblessViewController, HasCustomView, AlertApplicable, SpinnerApplicable {

    typealias CustomView = FavoritesView

    let alert = ApplicationAlert()
    let spinner = AppSpinner()
    private let viewModel: FavoritesViewModel

    override func loadView() {
        let customView = CustomView()
        view = customView
    }
    
    init(viewModel: FavoritesViewModel) {
         self.viewModel = viewModel

        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBindings()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.fetchFavoritesListings()
    }

    private func setupViews() {
        customView.tableView.dataSource = self
        customView.tableView.delegate = self
    }

    private func setupBindings() {
        viewModel.listingsUpdated
            .subscribe(onNext: { [weak self] in
                self?.customView.setupView(isEmpty: self?.viewModel.listings.isEmpty == true)
                self?.customView.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        viewModel.requestState.subscribe(onNext: { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .started:
                self.showSpinner()
            default:
                self.hideSpinner()
            }
        }).disposed(by: disposeBag)
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.listings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath) as ListingTableViewCell
        cell.setup(with: viewModel.listingPreviewViewModel(at: indexPath.row))
        cell.didToggleFavorite = { [weak self] _ in
            self?.viewModel.deleteListingFromFavorite(at: indexPath.row)
        }
        cell.didToggleDetails = { [weak self] _ in
            self?.viewModel.presentListingDetails(for: indexPath.row)
        }
        cell.didTogglePhotoTap = { [weak self] in
            self?.viewModel.presentListingDetails(for: indexPath.row)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.presentListingDetails(for: indexPath.row)
    }

}
