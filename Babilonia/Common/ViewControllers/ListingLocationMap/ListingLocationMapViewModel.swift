//
//  ListingLocationMapViewModel.swift
//  Babilonia
//
//  Created by Alya Filon  on 09.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import Foundation
import Core
import RxSwift
import RxCocoa

final class ListingLocationMapViewModel {

    var currentLocation: CLLocation? {
        model.currentLocation
    }
    var addressInfo: ListingDetailsAddressInfo? {
        guard let title = model.location.address else { return nil }

        return ListingDetailsAddressInfo(title: title,
                                         coordinate: model.coordinate,
                                         propertyType: model.propertyType)
    }
    var isGoogleMapsInstalled: Bool {
        model.isGoogleMapsInstalled
    }
    var isWazeInstalled: Bool {
        model.isWazeInstalled
    }
    var requestForLocationPermissionObservable: Observable<Void> {
        model.requestForLocationPermission.asObservable()
    }
    
    private let model: ListingLocationMapModel
    
    init(model: ListingLocationMapModel) {
        self.model = model
    }

    func openAppleMap() {
        model.openAppleMap()
    }

    func openGoogleMap() {
        model.openGoogleMap()
    }

    func openWazeMap() {
        model.openWazeMap()
    }

    func checkLocation() {
        model.checkLocation()
    }
    
}
