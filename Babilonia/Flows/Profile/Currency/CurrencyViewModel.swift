//
//  CurrencyViewModel.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/19/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class CurrencyViewModel {
    
    var viewModelsUpdated: Driver<[CurrencyItemViewModel]> {
        return model.currenciesUpdated.map { [unowned self] currencies in
            self.setupViewModels(from: currencies)
        }
    }
    
    private var currenciesDisposeBag = DisposeBag()
    private var currencyViewModels = [CurrencyItemViewModel]()
    
    private let model: CurrencyModel
    
    init(model: CurrencyModel) {
        self.model = model
    }
    
    func close() {
        model.close()
    }
    
    // MARK: - private
    
    private func setupViewModels(from currencies: [Currency]) -> [CurrencyItemViewModel] {
        currencyViewModels = [CurrencyItemViewModel]()
        
        currencies.enumerated().forEach { (index, currency) in
            let currencyValue = BehaviorRelay(value: model.valueForCurrency(at: index))
            currencyValue
                .bind(onNext: { [weak self] value in
                    if value {
                        self?.updateViewModels(selectedIndex: index)
                        self?.model.selectCurrency(at: index)
                    }
                    
                })
                .disposed(by: currenciesDisposeBag)
            let viewModel = CurrencyItemViewModel(title: currency.title, value: currencyValue)
            currencyViewModels.append(viewModel)
        }
        
        return currencyViewModels
    }
    
    private func updateViewModels(selectedIndex: Int) {
        currencyViewModels.enumerated().forEach { (index, viewModel) in
            guard index != selectedIndex else { return }
            
            viewModel.resetValue()
        }
    }
    
}
