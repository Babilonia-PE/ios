//
//  PaymentsPeriodViewController.swift
//  Babilonia
//
//  Created by Alya Filon  on 27.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PaymentsPeriodViewController: NiblessViewController, AlertApplicable, HasCustomView {
    
    typealias CustomView = PaymentsPeriodView
    
    let alert = ApplicationAlert()
    
    private let viewModel: PaymentsPeriodViewModel
    
    init(viewModel: PaymentsPeriodViewModel) {
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
    }
    
    private func setupBindings() {
        customView.checkoutButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.procceedChechout()
            })
            .disposed(by: disposeBag)
    }

    private func setupViews() {
        title = L10n.Payments.Flow.title
        navigationItem.backButtonTitle = ""

        customView.apply(viewModel.planModel)
        customView.tableView.dataSource = self
        customView.tableView.delegate = self
    }
}

extension PaymentsPeriodViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.periodItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath) as PaymentPeriodCell
        cell.setHighlight(isHighlighted: indexPath.row == 0)
        cell.apply(viewModel.periodItems[indexPath.row])

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedPeriodIndex = indexPath.row
        
        guard let cells = tableView.visibleCells as? [PaymentPeriodCell] else { return }

        cells.forEach {
            let row = tableView.indexPath(for: $0)?.row ?? 0
            $0.setHighlight(isHighlighted: row == indexPath.row)
        }
    }

}
