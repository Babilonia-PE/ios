//
//  CurrencyModel.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 7/19/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import RxCocoa
import RxSwift
import Core

typealias Currency = Core.Currency

enum CurrencyEvent: Event {
    case close
}

final class CurrencyModel: EventNode {
    
    var currenciesUpdated: Driver<[Currency]> { return currencies.asDriver() }
    
    private var currencyValuesMap = BehaviorRelay(value: [Bool]())
    
    private let currencies: BehaviorRelay<[Currency]>
    
    private let configService: ConfigurationsService
    
    init(parent: EventNode, configService: ConfigurationsService) {
        self.configService = configService
        let items = [
            Currency(title: L10n.Currency.Usd.title, symbol: L10n.Currency.Usd.symbol, code: L10n.Currency.Usd.code),
            Currency(title: L10n.Currency.Sol.title, symbol: L10n.Currency.Sol.symbol, code: L10n.Currency.Sol.code)
        ]
        currencies = BehaviorRelay(value: items)
        
        super.init(parent: parent)
        
        var map = [Bool]()
        currencies.value.forEach { currency in
            if currency.symbol == configService.currency.symbol {
                map.append(true)
            } else {
                map.append(false)
            }
        }
        currencyValuesMap.accept(map)
    }
    
    func valueForCurrency(at index: Int) -> Bool {
        return currencyValuesMap.value[index]
    }
    
    func selectCurrency(at index: Int) {
        var map = currencyValuesMap.value.map { _ in false }
        map[index] = true
        currencyValuesMap.accept(map)
    }
    
    func close() {
        guard let selectedIndex = currencyValuesMap.value.firstIndex(of: true) else { return }
        let currency = currencies.value[selectedIndex]
        updateCurrentCurrency(currency)
        raise(event: CurrencyEvent.close)
    }
    
    // MARK: - private
    
    private func updateCurrentCurrency(_ currency: Currency) {
        configService.updateCurrency(currency)
    }
    
}
