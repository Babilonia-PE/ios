//
//  CreateListingModel.swift
//  Babilonia
//
//  Created by Denis on 5/31/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import RxCocoa
import RxSwift
import Core

enum CreateListingEvent: Event {
    case finishCreation(listing: Listing, photos: [CreateListingPhoto])
    case close(alertMessage: String?)
}

final class CreateListingModel: EventNode {
    
    enum Step: String, CaseIterable {
        case common, details, facilities, advanced, photos
    }
    
    class StepWrapper {
        let step: Step
        init(step: Step) { self.step = step }
    }
    
    var currentIndexUpdated: Driver<Int> { return currentIndex.asDriver().distinctUntilChanged() }
    
    let steps: [Step]
    let stepWrappers: [StepWrapper]
    
    let mode: ListingFillMode
    
    private var draftListing: Listing?
    private var initialListing: Listing?
    
    private let facilitiesService: FacilitiesService
    private let listingsService: ListingsService
    private let imagesService: ImagesService
    private let geoService: GeoService
    private let currentIndex = BehaviorRelay(value: 0)
    private var stepModelsMap = [String: AnyObject]()
    private var draftUpdatesAvailable = true
    private let userSession: UserSession
    
    private let disposeBag = DisposeBag()
    
    // MARK: - lifecycle
    
    init(
        parent: EventNode,
        steps: [Step],
        draftListing: Listing?,
        facilitiesService: FacilitiesService,
        listingsService: ListingsService,
        imagesService: ImagesService,
        geoService: GeoService,
        mode: ListingFillMode,
        userSession: UserSession
    ) {
        self.steps = steps
        self.stepWrappers = steps.map { StepWrapper(step: $0) }
        self.draftListing = draftListing
        self.initialListing = draftListing
        self.facilitiesService = facilitiesService
        self.listingsService = listingsService
        self.imagesService = imagesService
        self.geoService = geoService
        self.userSession = userSession
        self.mode = mode
        super.init(parent: parent)
        
        setupBindings()
    }
    
    func updateCurrentIndex(_ index: Int) {
        currentIndex.accept(index)
    }
    
    func decreaseCurrentIndex() {
        guard currentIndex.value > 0 else { return }
        currentIndex.accept(currentIndex.value - 1)
    }
    
    func finishCreation() {
        draftUpdatesAvailable = false
        guard let photosModel = model(for: .photos) as? CreateListingPhotosModel else {
            fatalError("Failed to cast to \(CreateListingPhotosModel.self) type")
        }
        guard let draftListing = draftListing else { return }

        raise(event: CreateListingEvent.finishCreation(listing: draftListing, photos: photosModel.photosValue))
    }
    
    func close() {
        if let listing = draftListing, case .create = mode {
            if let initialListing = initialListing {
                listingsService.updateDraftListing(initialListing)
            } else {
                listingsService.removeDraftListing(listing)
            }
        }
        cleanUpOnExit()
        raise(event: CreateListingEvent.close(alertMessage: nil))
    }
    
    func saveAndClose() {
        cleanUpOnExit()
        raise(event: CreateListingEvent.close(alertMessage: L10n.CreateListing.Created.alert))
    }
    
    func model(at index: Int) -> Any {
        let step = steps[index]
        return model(for: step)
    }
    
    func enableDraftUpdates() {
        draftUpdatesAvailable = true
        let contact = draftListing?.contacts?.first
        if contact == nil || contact?.contactName == nil ||
            contact?.contactPhone == nil || contact?.contactEmail == nil {
//            draftListing?.contact = Contact(contactEmail: userSession.user.email,
//                                            contactName: "\(userSession.user.firstName ?? "") \(userSession.user.lastName ?? "")",
//                                            contactPhone: userSession.user.phoneNumber)
            draftListing?.contacts = [Contact(contactEmail: userSession.user.email,
                                             contactName: userSession.user.fullName ?? "",
                                             contactPhone: userSession.user.phoneNumber)]
        }
    }
    
    // MARK: - private
    
    private func model(for step: Step) -> Any {
        let wrapper = stepWrappers.first { $0.step == step }!
        if let model = stepModelsMap[wrapper.step.rawValue] {
            return model
        } else {
            let updateListingCallback: ((UpdateListingBlock, Bool) -> Void)? = { [unowned self] block, shouldSave in
                self.updateListing(block, shouldSave: shouldSave)
            }
            
            var model: AnyObject
            switch step {
            case .common:
                model = CreateListingCommonModel(parent: self, mode: mode,
                                                 geoService: geoService,
                                                 updateListingCallback: updateListingCallback)
            case .details:
                model = CreateListingDetailsModel(parent: self, updateListingCallback: updateListingCallback)
            case .facilities:
                model = CreateListingFacilitiesModel(
                    parent: self,
                    facilitiesService: facilitiesService,
                    updateListingCallback: updateListingCallback
                )
            case .advanced:
                model = CreateListingAdvancedModel(parent: self,
                                                   facilitiesService: facilitiesService,
                                                   updateListingCallback: updateListingCallback)
            case .photos:
                let listing: Listing?
                switch mode {
                case .create: listing = nil
                case .edit: listing = draftListing
                }
                model = CreateListingPhotosModel(
                    parent: self,
                    imagesService: imagesService,
                    mode: mode,
                    listing: listing,
                    updateListingCallback: updateListingCallback
                )
            }

            stepModelsMap[step.rawValue] = model

            return model
        }
    }
    
    private func setupBindings() {
        guard let commonModel = model(for: .common) as? CreateListingCommonModel else {
            fatalError("Failed to cast to \(CreateListingCommonModel.self) type")
        }

        commonModel.currentPropertyType
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                guard let detailsModel = self.model(for: .details) as? CreateListingDetailsModel else {
                    fatalError("Failed to cast to \(CreateListingDetailsModel.self) type")
                }
                detailsModel.propertyType.accept($0)
            })
            .disposed(by: disposeBag)
        commonModel.currentPropertyType
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                guard let facilitiesModel = self.model(for: .facilities) as? CreateListingFacilitiesModel else {
                    fatalError("Failed to cast to \(CreateListingFacilitiesModel.self) type")
                }
                facilitiesModel.propertyType.accept($0)
            })
            .disposed(by: disposeBag)
        commonModel.currentPropertyType
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                guard let advancedModel = self.model(for: .advanced) as? CreateListingAdvancedModel else {
                    fatalError("Failed to cast to \(CreateListingAdvancedModel.self) type")
                }
                advancedModel.propertyType.accept($0)
            })
            .disposed(by: disposeBag)
        commonModel.currentListingType
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                guard let detailsModel = self.model(for: .details) as? CreateListingDetailsModel else {
                    fatalError("Failed to cast to \(CreateListingDetailsModel.self) type")
                }
                detailsModel.listingType.accept($0)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateListing(_ update: UpdateListingBlock, shouldSave: Bool) {
        guard draftUpdatesAvailable else { return }
        if draftListing == nil {
            draftListing = listingsService.newDraftListing()
        }
        update(&draftListing!)
        guard shouldSave && mode == .create else { return }
        listingsService.updateDraftListing(draftListing!) { [weak self] result in
            guard let self = self else { return }
            if case .success(let listing) = result {
                self.draftListing = listing
            }
            // we don't need to show error here
        }
    }
    
    private func cleanUpOnExit() {
        guard let photosModel = model(for: .photos) as? CreateListingPhotosModel else {
            fatalError("Failed to cast to \(CreateListingPhotosModel.self) type")
        }
        photosModel.cleanUpPhotos()
    }
    
}
