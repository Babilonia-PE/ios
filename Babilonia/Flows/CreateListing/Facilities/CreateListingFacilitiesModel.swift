//
//  CreateListingFacilitiesModel.swift
//  Babilonia
//
//  Created by Denis on 6/3/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import RxCocoa
import RxSwift
import Core
import DBClient

final class CreateListingFacilitiesModel: EventNode, CreateListingModelUpdatable {
    
    let requestState = PublishSubject<RequestState>()
    
    let propertyType: BehaviorRelay<PropertyType>
    let updateListingCallback: ((UpdateListingBlock, Bool) -> Void)?
    
    var facilitiesUpdated: Driver<[Facility]> { return facilities.asDriver() }
    var facilitiesAreEmptyUpdated: Driver<Bool> { return facilitiesAreEmpty.asDriver().distinctUntilChanged() }
    
    private let facilitiesService: FacilitiesService
    private let facilities = BehaviorRelay(value: [Facility]())
    private let facilitiesAreEmpty = BehaviorRelay(value: false)
    
    private var facilityValuesMap = BehaviorRelay(value: [Int: Bool]())
    
    private let disposeBag = DisposeBag()
    
    // MARK: - lifecycle
    
    init(
        parent: EventNode,
        facilitiesService: FacilitiesService,
        updateListingCallback: ((UpdateListingBlock, Bool) -> Void)?
    ) {
        self.facilitiesService = facilitiesService
        self.updateListingCallback = updateListingCallback
        propertyType = BehaviorRelay(value: .apartment)
        
        super.init(parent: parent)
        
        setupListingUpdateBindings()
    }
    
    func fetchFacilities() {
        facilitiesAreEmpty.accept(false)
        requestState.onNext(.started)
        facilities.accept([])

        facilitiesService.getFacilities(for: propertyType.value) { [weak self] result in
            switch result {
            case .success(let facilities):
                self?.requestState.onNext(.finished)
                self?.facilities.accept(facilities.sorted { $0.id < $1.id })
                self?.facilitiesAreEmpty.accept(facilities.isEmpty)
            case .failure(let error):
                if self?.isUnauthenticated(error) == true {
                    self?.raise(event: MainFlowEvent.logout)
                } else {
                    self?.requestState.onNext(.failed(error))
                }
            }
        }
    }
    
    func valueForFacility(at index: Int) -> Bool {
        let map = facilityValuesMap.value
        return map[facilities.value[index].id] ?? false
    }
    
    func updateFacility(at index: Int, with value: Bool) {
        var map = facilityValuesMap.value
        map[facilities.value[index].id] = value
        facilityValuesMap.accept(map)
    }
    
    private func isUnauthenticated(_ error: Error?) -> Bool {
        guard let serverError = error as? CompositeServerError,
              let code = serverError.errors.first?.code else { return false }
        
        return code == .unauthenticated
    }
    
    // MARK: - private
    
    private func setupListingUpdateBindings() {
        fetchListing { [unowned self] listing in
            self.update(from: listing)
        }
        
        Driver.combineLatest(facilityValuesMap.asDriver().distinctUntilChanged(), facilities.asDriver())
            .drive(onNext: { [weak self] map, facilities in
                let filteredFacilities = facilities.filter {
                    map[$0.id] ?? false
                }
                self?.updateListing { listing in
                    listing.facilities = filteredFacilities
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func update(from listing: Listing) {
        if let facilities = listing.facilities {
            var map = [Int: Bool]()
            facilities.forEach {
                map[$0.id] = true
            }
            facilityValuesMap.accept(map)
        }
    }
    
}
