//
//  PaymentsProfileViewController.swift
//  Babilonia
//
//  Created by Alya Filon  on 27.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PaymentsProfileViewController: NiblessViewController, AlertApplicable, HasCustomView {
    
    typealias CustomView = PaymentsProfileView
    
    let alert = ApplicationAlert()
    
    private let viewModel: PaymentsProfileViewModel
    private let isPresented: Bool
    private let disposeBag = DisposeBag()
    
    init(viewModel: PaymentsProfileViewModel, isPresented: Bool) {
        self.viewModel = viewModel
        self.isPresented = isPresented
        
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
    
    // MARK: - Bindings
    
    private func setupBindings() {
        customView.selectProfileButton.rx.tap
            .bind(onNext: { [weak self] in self?.viewModel.selectProfile() })
            .disposed(by: disposeBag)

        customView.linkButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let url = self?.viewModel.siteURL,
                      UIApplication.shared.canOpenURL(url) else { return }

                UIApplication.shared.open(url)
            })
            .disposed(by: disposeBag)
    }

    private func setupViews() {
        title = L10n.Payments.Flow.title
        navigationItem.backButtonTitle = ""

        customView.collectionView.dataSource = self
        customView.collectionView.delegate = self

        if isPresented {
            let button = UIBarButtonItem(image: Asset.Common.closeIcon.image,
                                         style: .plain,
                                         target: self,
                                         action: #selector(dismissPayments))
            navigationItem.leftBarButtonItem = button
        }
    }

    @objc
    private func dismissPayments() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension PaymentsProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.profileTypes.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(indexPath) as PaymentsProfileTypeCell
        cell.iconImageView.image = viewModel.profileTypes[indexPath.row].icon
        cell.titleLabel.text = viewModel.profileTypes[indexPath.row].title
        cell.titleLabel.textColor = viewModel.profileTypes[indexPath.row].titleColor
        cell.setHighlight(isHighlighted: indexPath.row == 0)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row == 0,
              let cells = collectionView.visibleCells as? [PaymentsProfileTypeCell] else { return }

        viewModel.selectedProfileIndex = indexPath.row
        cells.forEach {
            let row = collectionView.indexPath(for: $0)?.row ?? 0
            $0.setHighlight(isHighlighted: row == indexPath.row)
        }
    }

}
