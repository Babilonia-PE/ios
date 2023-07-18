//
//  CreateListingFacilitiesViewModel.swift
//  Babilonia
//
//  Created by Denis on 6/3/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Core

final class CreateListingFacilitiesViewModel: FieldsValidationApplicable {
    
    var requestState: Observable<RequestState> {
        return model.requestState.asObservable().observeOn(MainScheduler.instance)
    }
    
    var viewModelsUpdated: Driver<[CreateListingFacilityViewModel]> {
        return model.facilitiesUpdated.map { [unowned self] facilities in
            self.setupViewModels(from: facilities)
        }
    }
    
    var emptyStateTitle: Driver<String?> {
        return Driver.combineLatest(model.propertyType.asDriver(), model.facilitiesAreEmptyUpdated) {
            guard $1 else { return nil }
            
            return L10n.CreateListing.Details.EmptyFacilities.title($0.title)
        }
    }
    
    var fieldsAreValidUpdated: Driver<Bool> { return Driver.just(true) }
    
    private let model: CreateListingFacilitiesModel
    
    private var facilitiesDisposeBag = DisposeBag()
    
    // MARK: - lifecycle
    
    init(model: CreateListingFacilitiesModel) {
        self.model = model
    }
    
    func viewAppeared() {
        model.fetchFacilities()
    }
    
    // MARK: - private
    
    private func setupViewModels(from facilities: [Facility]) -> [CreateListingFacilityViewModel] {
        facilitiesDisposeBag = DisposeBag()
        var facilityViewModels = [CreateListingFacilityViewModel]()
        
        facilities.enumerated().forEach { (index, facility) in
            let facilityValue = BehaviorRelay(value: model.valueForFacility(at: index))
            facilityValue
                .bind(onNext: { [unowned self] value in
                    self.model.updateFacility(at: index, with: value)
                })
                .disposed(by: facilitiesDisposeBag)
            let viewModel = CreateListingFacilityViewModel(
                title: facility.title,
                imageURL: URL(string: facility.icon?.originalURLString ?? ""),
                value: facilityValue
            )
            
            facilityViewModels.append(viewModel)
        }
        
        return facilityViewModels
    }
    
}
