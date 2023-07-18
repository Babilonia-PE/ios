//
//  CreateListingAdvancedViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 22.12.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import RxCocoa
import RxSwift
import Core

final class CreateListingAdvancedViewModel: FieldsValidationApplicable {

    var requestState: Observable<RequestState> { model.requestState.asObservable() }
    var viewModelsUpdated: Driver<[CreateListingFacilityViewModel]> {
        model.detailsUpdated.map { [unowned self] details in
            self.setupViewModels(from: details)
        }
    }

    var emptyStateTitle: Driver<String?> {
        Driver.combineLatest(model.propertyType.asDriver(), model.detailsAreEmptyUpdated) {
            guard $1 else { return nil }

            return L10n.CreateListing.Details.EmptyAdvanced.title($0.title)
        }
    }

    var fieldsAreValidUpdated: Driver<Bool> { return Driver.just(true) }
    
    private let model: CreateListingAdvancedModel
    private let disposeBag = DisposeBag()
    
    init(model: CreateListingAdvancedModel) {
        self.model = model
    }

    func viewAppeared() {
        model.fetchDetails()
    }
    
}

extension CreateListingAdvancedViewModel {

    private func setupViewModels(from details: [Facility]) -> [CreateListingFacilityViewModel] {
        var detailsViewModels = [CreateListingFacilityViewModel]()

        details.enumerated().forEach { (index, detail) in
            let detailValue = BehaviorRelay(value: model.valueForDetail(at: index))
            detailValue
                .bind(onNext: { [unowned self] value in
                    self.model.updateDetail(at: index, with: value)
                })
                .disposed(by: disposeBag)
            let viewModel = CreateListingFacilityViewModel(
                title: detail.title,
                imageURL: URL(string: detail.icon?.originalURLString ?? ""),
                value: detailValue
            )

            detailsViewModels.append(viewModel)
        }

        return detailsViewModels
    }

}
