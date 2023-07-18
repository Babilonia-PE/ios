//
//  ARContainerViewController+UISetup.swift
//  Babilonia
//
//  Created by Alya Filon  on 05.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import ARKitLocation
import MapKit
import RxSwift
import GoogleMaps
import GooglePlaces

// MARK: - Computed properties

extension ARContainerViewController {

    var isMapViewShown: Bool {
        return mapView != nil
    }

    var selectedAnnotationView: ARAnnotationView? {
        get {
            return arViewController?.selectedAnnotationView
        }
        set {
            arViewController?.selectedAnnotationView = newValue
        }
    }

}

extension ARContainerViewController {

    func setupMap(_ coordinate: CLLocationCoordinate2D) {
        guard !self.isMapViewShown else { return }

        let mapView = buildMapView()
        self.mapView = mapView
        mapView.alpha = 0.0

        if let selectedAnnotation = selectedAnnotationView?.annotation {
            let mkAnnotation = MKPointAnnotation()
            mkAnnotation.coordinate = selectedAnnotation.location.coordinate
        }

        guard let arView = arViewController?.view else { return }

        arView.addSubview(mapView)

        mapView.fadeIn()

        let visibleDelta: CGFloat = 0.34
        let visibleHeight = UIConstants.screenHeight * visibleDelta
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layout {
            leadingMapConstraint = $0.leading.equal(to: arView.leadingAnchor, offsetBy: -40.0)
            trailingMapConstraint = $0.trailing.equal(to: arView.trailingAnchor, offsetBy: 40.0)
            heightMapConstraint = $0.height.equal(to: visibleHeight)
            topMapConstraint = $0.top.equal(to: arView.topAnchor, offsetBy: UIConstants.screenHeight - visibleHeight)
        }

        let targetMarker = GMSMarker(position: coordinate)
        let iconView = UIImageView(image: Asset.AugmentedReality.housePin.image)
        iconView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)

        targetMarker.iconView = iconView
        targetMarker.map = mapView

        metersView = MetersView(frame: .zero)
        arView.addSubview(metersView)
        let fakeOffset = 93 + UIConstants.safeLayoutBottom
        let bottomOffset: CGFloat = arView.frame.height == UIConstants.screenHeight ? 19 : fakeOffset
        metersView.layout {
            $0.height.equal(to: 48.0)
            $0.width.equal(to: 48.0)
            $0.leading.equal(to: arView.leadingAnchor, offsetBy: 16)
            $0.bottom.equal(to: arView.safeAreaLayoutGuide.bottomAnchor, offsetBy: -bottomOffset)
        }

        setupInitialMapPosition()
        setupMapButton()

        if let sourceCoordinate = viewModel.currentLocation?.coordinate,
           let destinationCoordinate = viewModel.navigationDistinationLocation?.coordinate {
            viewModel.getDirections(sourceCoordinate: sourceCoordinate,
                                    destinationCoordinate: destinationCoordinate)
        }
    }

    func buildRoute(points: String) {
        guard let path = GMSPath(fromEncodedPath: points), let mapView = mapView else { return }

        clearRoute()

        let intervalDistanceIncrement: CGFloat = 3.3
        var previousCircle: GMSCircle?
        for coordinateIndex in 0 ..< path.count() - 1 {
            let startCoordinate = path.coordinate(at: coordinateIndex)
            let endCoordinate = path.coordinate(at: coordinateIndex + 1)
            let startLocation = CLLocation(latitude: startCoordinate.latitude, longitude: startCoordinate.longitude)
            let endLocation = CLLocation(latitude: endCoordinate.latitude, longitude: endCoordinate.longitude)
            let pathDistance = endLocation.distance(from: startLocation)
            let intervalLatIncr = (endLocation.coordinate.latitude - startLocation.coordinate.latitude) / pathDistance
            let intervalLngIncr = (endLocation.coordinate.longitude - startLocation.coordinate.longitude) / pathDistance
            for intervalDistance in 0 ..< Int(pathDistance) {
                let intervalLat = startLocation.coordinate.latitude + (intervalLatIncr * Double(intervalDistance))
                let intervalLng = startLocation.coordinate.longitude + (intervalLngIncr * Double(intervalDistance))
                let circleCoordinate = CLLocationCoordinate2D(latitude: intervalLat, longitude: intervalLng)
                if let previousCircle = previousCircle {
                    let circleLocation = CLLocation(latitude: circleCoordinate.latitude,
                                                    longitude: circleCoordinate.longitude)
                    let previousCircleLocation = CLLocation(latitude: previousCircle.position.latitude,
                                                            longitude: previousCircle.position.longitude)
                    if mapView.projection.points(forMeters: circleLocation.distance(from: previousCircleLocation),
                                                 at: mapView.camera.target) < intervalDistanceIncrement {
                        continue
                    }
                }
                let circle = GMSCircle(position: circleCoordinate, radius: 3)
                circle.fillColor = Asset.Colors.hippieBlue.color
                circle.strokeColor = Asset.Colors.hippieBlue.color
                circle.map = mapView
                previousCircle = circle
                routePolyline.append(circle)
            }
        }

    }

    private func setupInitialMapPosition() {
        guard let currentLocation = viewModel.currentLocation else { return }

        let camera = GMSCameraPosition.camera(
            withLatitude: currentLocation.coordinate.latitude,
            longitude: currentLocation.coordinate.longitude,
            zoom: self.mapView?.camera.zoom ?? 0
        )

        self.mapView?.animate(to: camera)

        currentMarker = GMSMarker(position: currentLocation.coordinate)
        currentMarker?.icon = Asset.AugmentedReality.navigationArrow.image
        currentMarker?.map = mapView

        setupLocationUpdatingTimer()
        viewModel.startHeadingUpdates()
    }

    private func setupLocationUpdatingTimer() {
        updateUserLocationTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateMapPosition),
            userInfo: nil,
            repeats: true
        )
    }

    private func buildMapView() -> GMSMapView {
        let sideOffset: CGFloat = 40.0
        let camera = GMSCameraPosition.camera(withLatitude: 0,
                                              longitude: 0,
                                              zoom: 15.0)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.settings.consumesGesturesInView = false
        mapView.addCornerRadius((UIConstants.screenWidth + sideOffset * 2) / 2,
                                corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner])

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(setPriviewVisibility))
        mapView.addGestureRecognizer(tapRecognizer)

        return mapView
    }

    @objc
    private func setPriviewVisibility() {
        let hiddenValue = 128 + UIConstants.safeLayoutTop
        guard let constraint = topListingPreviewConstraint,
              (isFullscreenMap || (!isFullscreenMap && constraint.constant == -hiddenValue)) else { return }

        let constant = constraint.constant == 0 ? -hiddenValue : 0
        constraint.constant = constant
        UIView.animate(withDuration: 0.2, animations: { self.view.layoutIfNeeded() })
    }

    private func setupMapButton() {
        guard let arView = arViewController?.view else { return }

        mapButton.backgroundColor = .white
        mapButton.layerCornerRadius = 24
        mapButton.setImage(Asset.AugmentedReality.mapFullscreenButton.image, for: .normal)
        mapButton.makeShadow(.black, offset: CGSize(width: 0, height: 3), radius: 5, opacity: 0.12)

        arView.addSubview(mapButton)
        let fakeOffset = 93 + UIConstants.safeLayoutBottom
        let bottomOffset: CGFloat = arView.frame.height == UIConstants.screenHeight ? 19 : fakeOffset
        mapButton.layout {
            $0.height.equal(to: 48)
            $0.width.equal(to: 48)
            $0.bottom.equal(to: arView.safeAreaLayoutGuide.bottomAnchor, offsetBy: -bottomOffset)
            $0.trailing.equal(to: arView.trailingAnchor, offsetBy: -16)
        }
    }

    @objc
    private func updateMapPosition() {
        guard let currentLocation = viewModel.currentLocation else { return }

        DispatchQueue.main.async {
            let updateMeters: Double = 7
            var shouldUpdate = true

            if let previousCurrentLocation = self.previousCurrentLocation {
                let distance = currentLocation.distance(from: previousCurrentLocation)

                shouldUpdate = distance > updateMeters
            }

            self.previousCurrentLocation = currentLocation
            if shouldUpdate {
                let camera = GMSCameraPosition.camera(
                    withLatitude: currentLocation.coordinate.latitude,
                    longitude: currentLocation.coordinate.longitude,
                    zoom: self.mapView?.camera.zoom ?? 0
                )
                self.mapView?.animate(to: camera)

                if let destinationCoordinate = self.viewModel.navigationDistinationLocation?.coordinate {
                    self.viewModel.getDirections(sourceCoordinate: currentLocation.coordinate,
                                                 destinationCoordinate: destinationCoordinate)
                }
            }

            self.currentMarker?.position = currentLocation.coordinate

            if let distinationLocation = self.viewModel.navigationDistinationLocation {
                let distance = currentLocation.distance(from: distinationLocation)
                self.metersView?.applyDistance(Double(distance))
            }
        }
    }

    private func clearRoute() {
        routePolyline.forEach { $0.map = nil }
        routePolyline.removeAll()
    }
    
    func animateMapViewFrame() {
        let visibleDelta: CGFloat = 0.34
        let visibleHeight = UIConstants.screenHeight * visibleDelta
        let sideOffset: CGFloat = 40.0

        animateMapAlpha(isShow: false) { [weak self] in
            guard let self = self else { return }

            self.leadingMapConstraint?.constant = self.isFullscreenMap ? 0 : -40.0
            self.trailingMapConstraint?.constant = self.isFullscreenMap ? 0 : 40.0
            self.heightMapConstraint?.constant = self.isFullscreenMap ? UIConstants.screenHeight : visibleHeight
            self.topMapConstraint?.constant = self.isFullscreenMap ? 0 : UIConstants.screenHeight - visibleHeight

            if self.isFullscreenMap {
                self.mapView?.layerCornerRadius = 0
            } else {
                self.mapView?.addCornerRadius((UIConstants.screenWidth + sideOffset * 2) / 2,
                                              corners: [.layerMaxXMinYCorner, .layerMinXMinYCorner])
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: { [weak self] in
                self?.animateMapAlpha(isShow: true)
            })
        }

        if !isFullscreenMap {
            setPriviewVisibility()
        }
    }

    private func animateMapAlpha(isShow: Bool, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.1, animations: {
            self.mapView?.alpha = isShow ? 1 : 0
        }, completion: { _ in completion?() })
    }

}
