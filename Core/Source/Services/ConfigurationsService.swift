//
//  ConfigurationsService.swift
//  Core
//
//  Created by Anna Sahaidak on 7/18/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import YALAPIClient
import DBClient

public protocol CurrencyObserver: class {
    func currencyChanged(_ currency: Currency)
}

public final class ConfigurationsService {
    
    public private(set) var appConfigs: AppConfig?
    public private(set) var currency: Currency
    
    private let observers = NSHashTable<AnyObject>(options: NSPointerFunctions.Options.weakMemory)
    
    private var rate: Double = 0.0

    private let client: NetworkClient
    private let storage: DBClient
    private let newClient: NetworkClient
    
    // MARK: - lifecycle
    
    public init(client: NetworkClient, storage: DBClient, currency: Currency, newClient: NetworkClient) {
        self.client = client
        self.storage = storage
        self.newClient = newClient
        
        appConfigs = storage.execute(FetchRequest<AppConfig>()).value?.first
        self.currency = currency
    }
    
    // MARK: - app configs
    
    public func updateAppConfigs() {
        let request = AppConfigRequest()
        newClient.execute(request: request, parser: DecodableParser<AppConfig>(keyPath: "data")) { [weak self] result in
            guard let config = result.value else { return }
            self?.storage.deleteAllObjects(of: AppConfig.self, completion: { _ in
                self?.appConfigs = config
                self?.storage.upsert(config)
            })
        }
    }
    
    // MARK: - currency
    
    public func updateCurrency(_ currency: Currency) {
        storage.deleteAllObjects(of: Currency.self) { [weak self] _ in
            guard let self = self else { return }
            
            self.currency = currency
            self.currency.rate = self.rate
            self.storage.upsert(self.currency)
            self.notifyObservers()
        }
    }
    
    public func getCurrencyRate(fromCurrency: String = "usd", toCurrency: String = "pen") {
        let request = CurrencyRateRequest(fromCurrency: fromCurrency, toCurrency: toCurrency)
        newClient.execute(
            request: request,
            parser: DecodableParser<CurrencyRate>(keyPath: "data")
        ) { [weak self] result in
            guard let currencyRate = result.value, let self = self else { return }
            
            self.rate = currencyRate.tc
            self.currency.rate = currencyRate.tc
            self.storage.upsert(self.currency) { _ in }
        }
    }
    
    public func formatPrice(_ price: Int) -> (code: String, price: Int) {
        var priceValue = Double(price)
        if currency.code != Constants.Currency.defaultCode {
            priceValue *= rate
        }
        
        return (currency.symbol, Int(priceValue))
    }
    
    public func addObserver(_ observer: CurrencyObserver) {
        observers.add(observer)
    }
    
    public func removeObserver(_ observer: CurrencyObserver) {
        observers.remove(observer)
    }
    
    // MARK: - private
    
    private func notifyObservers() {
        observers.allObjects.forEach { ($0 as? CurrencyObserver)?.currencyChanged(currency) }
    }
    
}
