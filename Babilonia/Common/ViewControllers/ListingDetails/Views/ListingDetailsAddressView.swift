//
//  ListingDetailsAddressView.swift
//  Babilonia
//
//  Created by Denis on 7/12/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import GoogleMaps
import Core

struct ListingDetailsAddressInfo {
    
    let title: String
    let coordinate: CLLocationCoordinate2D
    let propertyType: PropertyType?
    
}

private let defaultMapZoom: Float = 15.0

final class ListingDetailsAddressView: UIView {

    var toggleMapViewTap: (() -> Void)?
    
    private var mapPinImageView: UIImageView!
    private var addressLabel: UILabel!
    private var mapContainerView: UIView!
    private var mapView: GMSMapView!
    private var listingPinImageView: UIImageView!
    
    // MARK: - lifecycle
    
    init() {
        super.init(frame: .zero)
        
        layout()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with info: ListingDetailsAddressInfo) {
        addressLabel.text = info.title
        showCoordinateOnMap(info.coordinate)
        updatePin(with: info.propertyType)
    }
    
    // MARK: - private
    
    private func layout() {
        mapPinImageView = UIImageView()
        addSubview(mapPinImageView)
        mapPinImageView.layout {
            $0.top == topAnchor + 16.0
            $0.leading == leadingAnchor + 16.0
            $0.width == 16.0
            $0.height == 16.0
        }
        
        addressLabel = UILabel()
        addSubview(addressLabel)
        addressLabel.layout {
            $0.top == topAnchor + 14.0
            $0.leading == mapPinImageView.trailingAnchor + 8.0
            $0.trailing == trailingAnchor - 16.0
            $0.height == 21.0
        }
        
        mapContainerView = UIView()
        addSubview(mapContainerView)
        mapContainerView.layout {
            $0.top == mapPinImageView.bottomAnchor + 16.0
            $0.leading == leadingAnchor + 16.0
            $0.trailing == trailingAnchor - 16.0
            $0.bottom == bottomAnchor - 16.0
            $0.height == 96.0
        }
        
        let coordinate = Constants.Location.defaultLocation
        let camera = GMSCameraPosition.camera(
            withLatitude: coordinate.latitude,
            longitude: coordinate.longitude,
            zoom: defaultMapZoom
        )
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapContainerView.addSubview(mapView)
        mapView.layout {
            $0.top == mapContainerView.topAnchor
            $0.leading == mapContainerView.leadingAnchor
            $0.trailing == mapContainerView.trailingAnchor
            $0.bottom == mapContainerView.bottomAnchor
        }
        
        listingPinImageView = UIImageView()
        mapContainerView.addSubview(listingPinImageView)
        listingPinImageView.layout {
            $0.centerX == mapView.centerXAnchor
            $0.centerY == mapView.centerYAnchor
            $0.width == 27.0
            $0.height == 27.0
        }

        let mapButton = UIButton()
        mapContainerView.addSubview(mapButton)
        mapButton.pinEdges(to: mapContainerView)

        mapButton.addTarget(self, action: #selector(mapViewTap), for: .touchUpInside)
    }
    
    private func setupViews() {
        mapPinImageView.image = Asset.ListingDetails.mapPinSmall.image
        
        addressLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 14.0)
        addressLabel.textColor = Asset.Colors.vulcan.color
        
        mapContainerView.layer.cornerRadius = 6.0
        mapContainerView.clipsToBounds = true
        
        mapView.isMyLocationEnabled = false
        mapView.settings.myLocationButton = false
        mapView.isUserInteractionEnabled = false
        
        listingPinImageView.contentMode = .scaleAspectFill
    }
    
    private func showCoordinateOnMap(_ coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(
            withLatitude: coordinate.latitude,
            longitude: coordinate.longitude,
            zoom: defaultMapZoom
        )
        mapView.camera = camera
    }
    
    private func updatePin(with type: PropertyType?) {
        listingPinImageView.image = type?.pinIconImage
    }

    @objc
    private func mapViewTap() {
        toggleMapViewTap?()
    }
    
}

extension PropertyType {
    
    var pinIconImage: UIImage {
        switch self {
        case .apartment:
            return Asset.ListingDetails.pinApartment.image
        case .house:
            return Asset.ListingDetails.pinHouse.image
        case .office:
            return Asset.ListingDetails.pinOffice.image
        case .commercial:
            return Asset.ListingDetails.pinCommercial.image
        case .land:
            return Asset.ListingDetails.pinLand.image
        case .room:
            return Asset.ListingDetails.pinRoom.image
        }
    }
    
}
