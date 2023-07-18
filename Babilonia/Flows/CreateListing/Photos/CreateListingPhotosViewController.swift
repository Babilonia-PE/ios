//
//  CreateListingPhotosViewController.swift
//  Babilonia
//
//  Created by Denis on 6/3/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

final class CreateListingPhotosViewController: UIViewController, AlertApplicable {
    
    let alert = ApplicationAlert()
    
    private var emptyStateView: UploadPhotosEmptyStateView!
    private var topView: UploadPhotosTopView!
    private var topViewHeightConstraint: NSLayoutConstraint!
    private var collectionView: UICollectionView!
    
    private var imagePicker: ImagePicker!
    
    private let viewModel: CreateListingPhotosViewModel
    
    private var cellDisposeBag = DisposeBag()
    
    // MARK: - lifecycle
    
    init(viewModel: CreateListingPhotosViewModel) {
         self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        setupViews()
        setupBindings()
        
        imagePicker = ImagePicker(presentationController: self) { [weak self] image in
            if let image = image {
                self?.viewModel.uploadImage(image)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private

    private func layout() {
        topView = UploadPhotosTopView(countUpdated: viewModel.photosCountUpdated)
        view.addSubview(topView)
        topView.layout {
            $0.top == view.topAnchor + 8.0
            $0.leading == view.leadingAnchor + 16.0
            $0.trailing == view.trailingAnchor - 16.0
            topViewHeightConstraint = $0.height == 0.0
        }
        
        let layout = GridFlowLayout()
        layout.numberOfLines = 2.0
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        layout.sectionInset = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.layout {
            $0.top == topView.bottomAnchor + 16.0
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
        }
        
        emptyStateView = UploadPhotosEmptyStateView()
        view.addSubview(emptyStateView)
        emptyStateView.layout {
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
        }
    }
    
    private func setupViews() {
        collectionView.backgroundColor = .white
        collectionView.registerReusableCell(cellType: CreateListingPhotoCell.self)
        collectionView.dataSource = self
    }
    
    private func setupBindings() {
        bind(requestState: viewModel.requestState)
        
        emptyStateView.uploadButtonTap
            .bind { [weak self] in
                self?.uploadPhoto()
            }
            .disposed(by: disposeBag)
        topView.uploadButtonTap
            .bind { [weak self] in
                self?.uploadPhoto()
            }
            .disposed(by: disposeBag)
        
        viewModel.shouldShowEmptyState
            .map { !$0 }
            .drive(emptyStateView.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.shouldShowTopView
            .drive(onNext: { [weak self] value in
                self?.updateTopView(value)
            })
            .disposed(by: disposeBag)
        viewModel.shouldReload
            .drive(onNext: { [unowned self] in
                self.cellDisposeBag = DisposeBag()
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func uploadPhoto() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(
            title: L10n.ImagePicker.Camera.title,
            style: .default,
            handler: { [unowned self] _ in
                if viewModel.shouldShowCameraAlert &&
                    AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
                    self.presentCameraAccessAlert()

                    return
                }
                
                self.imagePicker.sourceType = .camera
                self.imagePicker.present()
                viewModel.shouldShowCameraAlert = true
            }
        ))
        alert.addAction(UIAlertAction(
            title: L10n.ImagePicker.Gallery.title,
            style: .default,
            handler: { [unowned self] _ in
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.present()
            }
        ))
        alert.addAction(UIAlertAction(
            title: L10n.Buttons.Cancel.title,
            style: .cancel,
            handler: nil
        ))
        
        present(alert, animated: true, completion: nil)
    }

    private func presentCameraAccessAlert() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsURL) else { return }

        SystemAlert.present(on: self,
                            message: L10n.Popups.CameraAccess.text,
                            confirmTitle: L10n.Buttons.Settings.title,
                            declineTitle: L10n.Buttons.Cancel.title,
                            confirm: {
                                UIApplication.shared.open(settingsURL)
                            })
    }
    
    private func updateTopView(_ shouldShow: Bool) {
        topViewHeightConstraint.constant = shouldShow ? 56.0 : 0.0
        UIView.animate(withDuration: 0.2) {
            self.topView.superview?.layoutIfNeeded()
        }
    }
    
    private func showOptionsForCell(at index: Int) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if !viewModel.photo(at: index).isMainPhoto {
            alert.addAction(UIAlertAction(
                title: L10n.CreateListing.Photos.Options.SetAsMain.title,
                style: .default,
                handler: { [unowned self] _ in
                    self.viewModel.setPhotoMain(at: index)
                }
            ))
        }
        alert.addAction(UIAlertAction(
            title: L10n.CreateListing.Photos.Options.Delete.title,
            style: .destructive,
            handler: { [unowned self] _ in
                self.viewModel.deletePhoto(at: index)
            }
        ))
        alert.addAction(UIAlertAction(
            title: L10n.Buttons.Cancel.title,
            style: .cancel,
            handler: nil
        ))
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension CreateListingPhotosViewController: ViewAppearActionApplicable {
    
    func viewAppeared() {}
    
}

extension CreateListingPhotosViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photosCount
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: CreateListingPhotoCell = collectionView.dequeueReusableCell(indexPath)
        cell.setup(with: viewModel.photo(at: indexPath.row))
        cell.buttomDidTap = { [weak self] in
            self?.showOptionsForCell(at: indexPath.row)
        }
        
        return cell
    }
    
}
