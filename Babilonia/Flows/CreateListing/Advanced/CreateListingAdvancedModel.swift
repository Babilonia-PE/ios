//
//  CreateListingAdvancedModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 22.12.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import RxCocoa
import RxSwift
import Core

final class CreateListingAdvancedModel: EventNode, CreateListingModelUpdatable {

    let requestState = PublishSubject<RequestState>()

    let propertyType: BehaviorRelay<PropertyType>
    var detailsUpdated: Driver<[Facility]> { return details.asDriver() }
    var detailsAreEmptyUpdated: Driver<Bool> { return detailsAreEmpty.asDriver().distinctUntilChanged() }

    let updateListingCallback: ((UpdateListingBlock, Bool) -> Void)?

    private let facilitiesService: FacilitiesService
    private let details = BehaviorRelay(value: [Facility]())
    private let detailsAreEmpty = BehaviorRelay(value: false)
    private let disposeBag = DisposeBag()
    private var detailsValuesMap = BehaviorRelay(value: [Int: Bool]())

    init(parent: EventNode,
         facilitiesService: FacilitiesService,
         updateListingCallback: ((UpdateListingBlock, Bool) -> Void)?) {
        self.facilitiesService = facilitiesService
        self.updateListingCallback = updateListingCallback
        propertyType = BehaviorRelay(value: .apartment)
        
        super.init(parent: parent)

        setupListingUpdateBindings()
    }

    func fetchDetails() {
        detailsAreEmpty.accept(false)
        requestState.onNext(.started)
        details.accept([])

        facilitiesService.getFacilities(for: propertyType.value, type: .advancedDetail) { [weak self] result in
            switch result {
            case .success(let details):
                self?.requestState.onNext(.finished)
                self?.details.accept(details.sorted { $0.id < $1.id })
                self?.detailsAreEmpty.accept(details.isEmpty)
            case .failure(let error):
                if self?.isUnauthenticated(error) == true {
                    self?.raise(event: MainFlowEvent.logout)
                } else {
                    self?.requestState.onNext(.failed(error))
                }
            }
        }
    }

    func valueForDetail(at index: Int) -> Bool {
        let map = detailsValuesMap.value
        return map[details.value[index].id] ?? false
    }

    func updateDetail(at index: Int, with value: Bool) {
        var map = detailsValuesMap.value
        map[details.value[index].id] = value
        detailsValuesMap.accept(map)
    }
    
    private func isUnauthenticated(_ error: Error?) -> Bool {
        guard let serverError = error as? CompositeServerError,
              let code = serverError.errors.first?.code else { return false }
        
        return code == .unauthenticated
    }
}

extension CreateListingAdvancedModel {

    private func setupListingUpdateBindings() {
        fetchListing { [unowned self] listing in
            self.update(from: listing)
        }

        Driver.combineLatest(detailsValuesMap.asDriver().distinctUntilChanged(), details.asDriver())
            .drive(onNext: { [weak self] map, details in
                let filteredDetails = details.filter {
                    map[$0.id] ?? false
                }
                self?.updateListing { listing in
                    listing.advancedDetails = filteredDetails
                }
            })
            .disposed(by: disposeBag)
    }

    private func update(from listing: Listing) {
        if let details = listing.advancedDetails {
            var map = [Int: Bool]()
            details.forEach {
                map[$0.id] = true
            }
            detailsValuesMap.accept(map)
        }
    }

}
