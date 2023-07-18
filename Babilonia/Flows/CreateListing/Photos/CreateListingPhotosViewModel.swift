//
//  CreateListingPhotosViewModel.swift
//  Babilonia
//
//  Created by Denis on 6/3/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class CreateListingPhotosViewModel: FieldsValidationApplicable {
    
    var requestState: Observable<RequestState> {
        return model.requestState.asObservable().observeOn(MainScheduler.instance)
    }
    
    var fieldsAreValidUpdated: Driver<Bool> {
        return model.photosUpdated.map { photos in
            // swiftlint:disable contains_over_first_not_nil
            return !photos.isEmpty && photos.first {
                // swiftlint:enable contains_over_first_not_nil
                switch $0.status.value {
                case .uploading: return true
                case .uploaded, .alreadyExists: return false
                }
            } == nil
        }
    }
    var photosCountUpdated: Driver<(Int, Int)> {
        return model.photosUpdated.map { [unowned self] photos in
            (photos.count, self.model.maximumPhotosCount)
        }
    }
    var shouldShowTopView: Driver<Bool> {
        return model.photosUpdated.map { [unowned self] photos in
            photos.count < self.model.maximumPhotosCount
        }.distinctUntilChanged()
    }
    var shouldShowCameraAlert: Bool {
        get { model.shouldShowCameraAlert }
        set { model.shouldShowCameraAlert = newValue }
    }
    var shouldShowEmptyState: Driver<Bool> { return model.photosUpdated.map { $0.isEmpty } }
    var shouldReload: Driver<Void> { return model.photosUpdated.map { _ in } }
    var photosCount: Int { return photos.count }
    
    private let model: CreateListingPhotosModel
    
    private var photos = [CreateListingPhoto]()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - lifecycle
    
    init(model: CreateListingPhotosModel) {
        self.model = model
        setupBindings()
    }
    
    func uploadImage(_ image: UIImage) {
        model.uploadImage(image)
    }
    
    func photo(at index: Int) -> CreateListingPhoto {
        return photos[index]
    }
    
    func setPhotoMain(at index: Int) {
        model.setPhotoMain(at: index)
    }
    
    func deletePhoto(at index: Int) {
        model.deletePhoto(at: index)
    }
    
    // MARK: - private
    
    private func setupBindings() {
        model.photosUpdated
            .drive(onNext: { [weak self] value in
                self?.photosUpdated(value)
            })
            .disposed(by: disposeBag)
    }
    
    private func photosUpdated(_ photos: [CreateListingPhoto]) {
        self.photos = photos
    }
    
}
