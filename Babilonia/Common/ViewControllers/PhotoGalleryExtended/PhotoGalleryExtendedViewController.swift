//
//  PhotoGalleryExtendedViewController.swift
//  Babilonia
//
//  Created by Alya Filon  on 12.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PhotoGalleryExtendedViewController: NiblessViewController, HasCustomView {
    
    typealias CustomView = PhotoGalleryExtendedView
    
    private let viewModel: PhotoGalleryExtendedViewModel
    
    init(viewModel: PhotoGalleryExtendedViewModel) {
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

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)

        super.viewWillDisappear(animated)
    }
    
    // MARK: - Bindings

    private func setupView() {
        customView.photoCountLabel.text = viewModel.initialCurrentPhotoTitle
        customView.apply(photos: viewModel.photos,
                         initialIndex: viewModel.initialIndex)
    }
    
    private func setupBindings() {
        customView.backButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
