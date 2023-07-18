//
//  PaymentsPlanViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 27.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Core

final class PaymentsPlanViewModel {

    var requestState: Observable<RequestState> {
        model.requestState.asObservable().observeOn(MainScheduler.instance)
    }
    var reloadContentView = PublishRelay<Void>()
    var planContentModels = [PaymentPlanContentModel]()
    var currentPlanIndex = 1
    
    private let model: PaymentsPlanModel
    private let bag = DisposeBag()
    
    init(model: PaymentsPlanModel) {
        self.model = model

        setupBindings()
    }

    func selectPlan() {
        guard !planContentModels.isEmpty,
              currentPlanIndex < planContentModels.count else { return }

        model.selectPlan(planContentModels[currentPlanIndex])
    }

    func getPaymentPlan() {
        model.getPaymentPlan()
    }

    func planItems() -> [String] {
        guard !planContentModels.isEmpty,
              currentPlanIndex < planContentModels.count else { return [] }

        if currentPlanIndex < planContentModels.count {
            return planContentModels[currentPlanIndex].planItems
        } else {
            return planContentModels[planContentModels.count - 1].planItems
        }
    }

    private func setupBindings() {
        model.plans
            .subscribe(onNext: { [weak self] plans in
                let models = plans.map { PaymentPlanContentModel(paymentPlan: $0) }

                self?.planContentModels = self?.sortModelsIfNeeded(models) ?? []
                self?.reloadContentView.accept(())
            })
            .disposed(by: bag)
    }

    private func sortModelsIfNeeded(_ models: [PaymentPlanContentModel]) -> [PaymentPlanContentModel] {
        if let premium = models.first(where: { $0.key == .premium }),
           let plus = models.first(where: { $0.key == .plus }),
           let standard = models.first(where: { $0.key == .standard }) {
            return [premium, plus, standard]
        }

        return models
    }

}
