//
//  PhotoGalleryViewController.swift
//  Babilonia
//
//  Created by Alya Filon  on 12.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PhotoGalleryViewController: NiblessViewController, HasCustomView, SpinnerApplicable {
    
    typealias CustomView = PhotoGalleryView
    
    let spinner = AppSpinner()
    
    private let viewModel: PhotoGalleryViewModel

    init(viewModel: PhotoGalleryViewModel) {
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

        setupView()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        stopSpinnerIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)

        super.viewWillDisappear(animated)
    }
    
    // MARK: - Bindings

    private func setupView() {
        showSpinner()
        customView.collectionView.dataSource = self
        customView.collectionView.delegate = self
        customView.photoCountLabel.text = L10n.PhotoGallery.photosCount(viewModel.photos.count)
    }
    
    private func setupBindings() {
        customView.backButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func stopSpinnerIfNeeded() {
        guard !customView.collectionView.visibleCells.isEmpty else { return }

        let isImageLoaded = customView.collectionView.visibleCells
            .compactMap { $0 as? PhotoGalleryCell }
            .map { $0.photoImageView.image }
            .filter { $0 != nil }
            .isEmpty == false

        if isImageLoaded { hideSpinner() }
    }

}

extension PhotoGalleryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.photos.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(indexPath) as PhotoGalleryCell
        cell.imageLoadingHandler = { [weak self] in
            self?.hideSpinner()
        }
        cell.apply(photo: viewModel.photos[indexPath.row])
        stopSpinnerIfNeeded()

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        if Double(indexPath.row).truncatingRemainder(dividingBy: 3) == 0 {
            let ratio: CGFloat = 0.58
            let width: CGFloat = UIConstants.screenWidth - 16

            return CGSize(width: width, height: width * ratio)

        } else {
            let side: CGFloat = (UIConstants.screenWidth - 24) / 2

            return CGSize(width: side, height: side)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.showDetailedGallery(at: indexPath.row)
    }

}
