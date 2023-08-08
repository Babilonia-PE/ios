//
//  CreateListingPhotosModel.swift
//  Babilonia
//
//  Created by Denis on 6/3/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Core
import RxCocoa
import RxSwift
import UIKit.UIImage
import YALAPIClient

struct CreateListingPhoto {
    
    enum Status {
        case uploading, uploaded, alreadyExists(URL)
    }
    
    var id: Int
    var status: BehaviorRelay<Status>
    var image: UIImage?
    var isMainPhoto: Bool
    
}

enum CreateListingPhotosEvent: Event {
    
}

private let maximumAllowedPhotosCount = 50

final class CreateListingPhotosModel: EventNode, CreateListingModelUpdatable {
    
    let requestState = PublishSubject<RequestState>()
    
    let updateListingCallback: ((UpdateListingBlock, Bool) -> Void)?
    var photosValue: [CreateListingPhoto] {
        return photos.value.filter { $0.isMainPhoto == true } + photos.value.filter { $0.isMainPhoto == false }
    }
    
    var photosUpdated: Driver<[CreateListingPhoto]> { return photos.asDriver() }
    
    var maximumPhotosCount: Int { return maximumAllowedPhotosCount }
    var shouldShowCameraAlert: Bool {
        get { appSettingsStore.cameraAlertDidShow }
        set { appSettingsStore.cameraAlertDidShow = newValue }
    }
    
    private let imagesService: ImagesService
    private let mode: ListingFillMode
    private let listing: Listing?
    
    private let photos: BehaviorRelay<[CreateListingPhoto]>
    private var cancellationsMap = [Int: YALAPIClient.Cancelable]()
    private let appSettingsStore: AppSettingsStore = UserDefaults()
    
    // MARK: - lifecycle
    
    init(
        parent: EventNode,
        imagesService: ImagesService,
        mode: ListingFillMode,
        listing: Listing?,
        updateListingCallback: ((UpdateListingBlock, Bool) -> Void)?
    ) {
        self.imagesService = imagesService
        self.mode = mode
        self.listing = listing
        self.updateListingCallback = updateListingCallback
        self.photos = BehaviorRelay(value: listing?.createListingPhotos ?? [])
        
        super.init(parent: parent)
    }
    
    func uploadImage(_ image: UIImage) {
        var photos = self.photos.value
        var photo = CreateListingPhoto.local(image)
        photo.isMainPhoto = photos.isEmpty
        photos.append(photo)
        self.photos.accept(photos)
        
        let uploadCancellable = imagesService.uploadImage(image) { [weak self] result in
            guard let self = self else { return }
            
            self.cancellationsMap.removeValue(forKey: photo.id)
            
            switch result {
            case .success(let images):
                self.processImageUpload(of: photo, with: images[0])
            case .failure(let error):
                if self.isUnauthenticated(error) {
                    self.raise(event: MainFlowEvent.logout)
                } else {
                    self.processImageUpload(of: photo, with: error)
                }
            }
        }
        if let cancellable = uploadCancellable {
            cancellationsMap[photo.id] = cancellable
        }
    }
    
    func setPhotoMain(at index: Int) {
        var photos = self.photos.value
        for photoIndex in photos.indices {
            photos[photoIndex].isMainPhoto = photoIndex == index
        }
        self.photos.accept(photos)
    }
    
    func deletePhoto(at index: Int) {
        var photos = self.photos.value
        let nextMainPhotoIndex = proceedMainPhotoIndex(index)
        let photo = photos.remove(at: index)
        self.photos.accept(photos)
        processPhotoDeletion(photo)

        if let mainIndex = nextMainPhotoIndex, photo.isMainPhoto {
            setPhotoMain(at: mainIndex)
        }
    }

    private func proceedMainPhotoIndex(_ previousIndex: Int) -> Int? {
        var index: Int?
        if previousIndex < photos.value.count - 1 {
            index = previousIndex
        }
        if previousIndex == photos.value.count - 1 {
            index = photos.value.count - 2
        }

        return index
    }
    
    func cleanUpPhotos() {
        photos.value.forEach { self.processPhotoDeletion($0) }
    }
    
    // MARK: - private
    
    private func processImageUpload(of initialPhoto: CreateListingPhoto, with resultingImage: ListingImage) {
        var photos = self.photos.value
        if let index = (photos.firstIndex { $0.id == initialPhoto.id }) {
            photos[index].status.accept(.uploaded)
            photos[index].id = resultingImage.id
            self.photos.accept(photos)
        }
    }
    
    private func processImageUpload(of initialPhoto: CreateListingPhoto, with error: Error) {
        if let error = error as? NetworkError, case .canceled = error { return }
        
        var photos = self.photos.value
        photos.removeAll { $0.id == initialPhoto.id }
        self.photos.accept(photos)
        
        self.requestState.onNext(.failed(error))
    }
    
    private func processPhotoDeletion(_ photo: CreateListingPhoto) {
        switch photo.status.value {
        case .uploading:
            if let cancellable = cancellationsMap[photo.id] {
                cancellable.cancel()
                cancellationsMap.removeValue(forKey: photo.id)
            }
        case .uploaded:
            imagesService.deleteImage(photo.id) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    break
                case .failure(let error):
                    if self.isUnauthenticated(error) {
                        self.raise(event: MainFlowEvent.logout)
                    }
                }
            }
        case .alreadyExists:
            break
        }
    }
    
    private func isUnauthenticated(_ error: Error?) -> Bool {
        guard let serverError = error as? CompositeServerError,
              let code = serverError.errors.first?.code else { return false }
        
        return code == .unauthenticated
    }
}

private extension CreateListingPhoto {
    
    static func local(_ image: UIImage) -> CreateListingPhoto {
        return CreateListingPhoto(
            id: UUID().hashValue,
            status: BehaviorRelay(value: .uploading),
            image: image,
            isMainPhoto: false
        )
    }
    
}

extension Listing {
    
    var createListingPhotos: [CreateListingPhoto] {
        sortedPhotos.compactMap {
            guard let URLString = $0.photo.renderURLString, let URL = URL(string: URLString) else { return nil }
            return CreateListingPhoto(
                id: $0.id,
                status: BehaviorRelay(value: .alreadyExists(URL)),
                image: nil,
                isMainPhoto: primaryImageId == $0.id
            )
        }
    }

    var sortedPhotos: [ListingImage] {
        sortPhotosByPrimary()
    }

    private func sortPhotosByPrimary() -> [ListingImage] {
        var sortedPhotos = [ListingImage]()

        if let primaryImage = primaryImage {
            sortedPhotos.append(primaryImage)
        }

        images?.sorted { $0.id < $1.id }.forEach { image in
            guard image.id != primaryImage?.id else { return }
            sortedPhotos.append(image)
        }

        return sortedPhotos
    }
    
}
