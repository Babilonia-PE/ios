//
//  PaymentsPlanViewController.swift
//  Babilonia
//
//  Created by Alya Filon  on 27.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PaymentsPlanViewController: NiblessViewController, AlertApplicable, HasCustomView {
    
    typealias CustomView = PaymentsPlanView
    
    let alert = ApplicationAlert()
    
    private let viewModel: PaymentsPlanViewModel
    private let bag = DisposeBag()
    
    init(viewModel: PaymentsPlanViewModel) {
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
        setupBindings()
        viewModel.getPaymentPlan()
    }
    
    private func setupBindings() {
        bind(requestState: viewModel.requestState)
        customView.selectProfileButton.rx.tap
            .bind(onNext: { [weak self] in self?.viewModel.selectPlan() })
            .disposed(by: disposeBag)

        viewModel.reloadContentView
            .bind(onNext: { [weak self] in
                self?.customView.planCollectionView.reloadData()
                self?.customView.itemsTableView.reloadData()
                self?.setSelectedPlan()
            })
            .disposed(by: bag)
    }

    private func setupViews() {
        title = L10n.Payments.Flow.title
        navigationItem.backButtonTitle = ""

        customView.planCollectionView.delegate = self
        customView.planCollectionView.dataSource = self
        customView.itemsTableView.dataSource = self
    }

    private func setSelectedPlan() {
        customView.planCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0),
                                                   at: .centeredHorizontally,
                                                   animated: false)
    }

}

extension PaymentsPlanViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.planItems().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath) as PaymentPlanItemCell
        let item = viewModel.planItems()[indexPath.row]
        cell.apply(item)

        return cell
    }

}

extension PaymentsPlanViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.planContentModels.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(indexPath) as PaymentPlanCell
        cell.apply(viewModel.planContentModels[indexPath.row])
        cell.setHighlight(isHighlighted: indexPath.row == 0)

        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let deltaWidth = customView.planCollectionView.frame.width / 2
        let index = Int(scrollView.contentOffset.x / deltaWidth)

        viewModel.currentPlanIndex = index
        customView.itemsTableView.reloadData()
        customView.setCurrentPlanDot(at: index)

        guard let cells = customView.planCollectionView.visibleCells as? [PaymentPlanCell] else { return }

        cells.forEach {
            let row = self.customView.planCollectionView.indexPath(for: $0)?.row ?? 0
            $0.setHighlight(isHighlighted: row == index)
        }
    }

}
