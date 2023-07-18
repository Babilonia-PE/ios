//
//  CreateListingAddressViewModel.swift
//  Babilonia
//
//  Created by Denis on 6/11/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation.CLLocation

final class CreateListingAddressViewModel {
    
    struct PinInfo {
        let title: String
        let coordinate: CLLocationCoordinate2D
    }
    
    var addressUpdated: Driver<PinInfo?> { return model.addressUpdated.map { PinInfo(mapAddress: $0) } }
    var coordinateShownUpdated: Driver<CLLocationCoordinate2D?> { return model.coordinateShownUpdated }
    
    private let model: CreateListingAddressModel
    
    init(model: CreateListingAddressModel) {
        self.model = model
    }
    
    func viewLoaded() {
        model.checkLocation()
    }
    
    func coordinateTapped(_ coordinate: CLLocationCoordinate2D) {
        model.updateLocation(coordinate)
    }
    
    func addressSelected(coordinate: CLLocationCoordinate2D, name: String?, formattedAddress: String?) {
        model.updateMapAddress(coordinate, title: formattedAddress, showCoordinate: true)
    }
    
    func close() {
        model.close()
    }
    
    func done() {
        model.done()
    }
    
}

private extension CreateListingAddressViewModel.PinInfo {
    
    init?(mapAddress: MapAddress?) {
        guard let mapAddress = mapAddress else { return nil }
        title = mapAddress.title ?? L10n.CreateListing.Common.Address.UnknowLocation.text
        coordinate = mapAddress.coordinate
    }
    
}
