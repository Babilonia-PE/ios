//
//  ListingLocationMapView.swift
//  Babilonia
//
//  Created by Alya Filon  on 09.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import GoogleMaps
import Core

final class ListingLocationMapView: NiblessView {

    let backButton: UIButton = .init()
    let titlaLabel: UILabel = .init()
    let currentLocationButton: UIButton = .init()
    let routeButton: UIButton = .init()
    private let navigationBarView: UIView = .init()
    private var mapView: GMSMapView!

    private var listingMarker: GMSMarker?
    private var currentLocationMarker: GMSMarker?

    override init() {
        super.init()
        
        setupView()
    }

    func setup(with info: ListingDetailsAddressInfo) {
        titlaLabel.text = info.title
        showCoordinateOnMap(info.coordinate)
        updatePin(with: info.propertyType, coordinate: info.coordinate)
    }

    func setCurrentLocation(_ location: CLLocation?, shouldCenter: Bool = false) {
        guard let location = location else { return }
        
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                longitude: location.coordinate.longitude)

        let marker = GMSMarker(position: coordinate)
        marker.icon = Asset.ListingDetails.currentLocationIcon.image

        marker.map = mapView
        currentLocationMarker = marker

        if shouldCenter {
            showCoordinateOnMap(coordinate)
        }
    }

}

extension ListingLocationMapView {

    private func showCoordinateOnMap(_ coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(
            withLatitude: coordinate.latitude,
            longitude: coordinate.longitude,
            zoom: 15
        )
        mapView.camera = camera
    }

    private func updatePin(with propertyType: PropertyType?, coordinate: CLLocationCoordinate2D) {
        let markerView = ListingMapMarker()
        markerView.frame.size = CGSize(width: 32, height: 32)
        markerView.propertyTypeImageView.image = propertyType?.pinIconImage

        let marker = GMSMarker(position: coordinate)
        marker.iconView = markerView

        marker.map = mapView
        listingMarker = marker
    }

    private func setupView() {
        backgroundColor = .white

        setupMap()
        setupNavigationBar()
        setupMapButtons()
    }

    private func setupMap() {
        let coordinate = Constants.Location.defaultLocation
        let camera = GMSCameraPosition.camera(
            withLatitude: coordinate.latitude,
            longitude: coordinate.longitude,
            zoom: 15.0
        )
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)

        addSubview(mapView)
        mapView.pinEdges(to: self)
    }

    private func setupNavigationBar() {
        let fakeView = UIView()
        fakeView.backgroundColor = .white

        addSubview(fakeView)
        fakeView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.top.equal(to: topAnchor)
            $0.height.equal(to: 13)
        }

        navigationBarView.backgroundColor = .white
        navigationBarView.layerCornerRadius = 13
        navigationBarView.makeShadow(Asset.Colors.almostBlack.color,
                                     offset: CGSize(width: 0, height: 2), radius: 4, opacity: 0.15)

        addSubview(navigationBarView)
        navigationBarView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.top.equal(to: topAnchor)
        }

        backButton.setImage(Asset.Common.backIcon.image.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.tintColor = Asset.Colors.almostBlack.color

        navigationBarView.addSubview(backButton)
        backButton.layout {
            $0.top.equal(to: safeAreaLayoutGuide.topAnchor, offsetBy: 10)
            $0.leading.equal(to: navigationBarView.leadingAnchor, offsetBy: 12)
            $0.height.equal(to: 24)
            $0.width.equal(to: 24)
        }

        titlaLabel.textColor = Asset.Colors.almostBlack.color
        titlaLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 16)
        titlaLabel.textAlignment = .center
        titlaLabel.minimumScaleFactor = 0.7
        titlaLabel.adjustsFontSizeToFitWidth = true

        navigationBarView.addSubview(titlaLabel)
        titlaLabel.layout {
            $0.top.equal(to: safeAreaLayoutGuide.topAnchor, offsetBy: 12)
            $0.leading.equal(to: backButton.trailingAnchor, offsetBy: 6)
            $0.trailing.equal(to: navigationBarView.trailingAnchor, offsetBy: -10)
            $0.bottom.equal(to: navigationBarView.bottomAnchor, offsetBy: -12)
        }
    }

    private func setupMapButtons() {
        currentLocationButton.backgroundColor = .white
        currentLocationButton.setImage(Asset.Search.myLocationIcon.image, for: .normal)
        currentLocationButton.layerCornerRadius = 24
        currentLocationButton.makeShadow(.black, offset: .zero, radius: 5, opacity: 0.16)

        addSubview(currentLocationButton)
        currentLocationButton.layout {
            $0.height.equal(to: 48)
            $0.width.equal(to: 48)
            $0.leading.equal(to: leadingAnchor, offsetBy: 10)
            $0.bottom.equal(to: bottomAnchor, offsetBy: -48)
        }

        routeButton.backgroundColor = .white
        routeButton.setImage(Asset.ListingDetails.mapRoute.image, for: .normal)
        routeButton.layerCornerRadius = 28
        routeButton.makeShadow(.black, offset: CGSize(width: 0, height: 4), radius: 6, opacity: 0.25)

        addSubview(routeButton)
        routeButton.layout {
            $0.height.equal(to: 56)
            $0.width.equal(to: 56)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -10)
            $0.bottom.equal(to: bottomAnchor, offsetBy: -48)
        }
    }

}

final class ListingMapMarker: NiblessView {

    let propertyTypeImageView: UIImageView = .init()

    override init() {
        super.init()

        setupView()
    }

}

extension ListingMapMarker {

    private func setupView() {
        propertyTypeImageView.contentMode = .scaleAspectFit

        addSubview(propertyTypeImageView)
        propertyTypeImageView.layout {
            $0.height.equal(to: 32)
            $0.width.equal(to: 32)
            $0.centerY.equal(to: centerYAnchor)
            $0.centerX.equal(to: centerXAnchor)
        }
    }

}
