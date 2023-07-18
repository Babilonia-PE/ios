//
//  CreateListingAddressViewController.swift
//  Babilonia
//
//  Created by Denis on 6/11/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import GoogleMaps
import GooglePlaces

final class CreateListingAddressViewController: UIViewController, AlertApplicable {
    
    let alert = ApplicationAlert()
    
    private let viewModel: CreateListingAddressViewModel
    
    private var mapView: GMSMapView!
    private var resultsViewController: GMSAutocompleteResultsViewController!
    private var searchController: UISearchController!
    private var marker: GMSMarker!
    private var doneButton: ConfirmationButton!
    
    private var bindingsSet = false
    
    init(viewModel: CreateListingAddressViewModel) {
         self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        setupNavigationBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.viewLoaded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // doing it here due to issue of Google Map centering/resizing while initialization in
        // case of view isn't layed out yet
        if !bindingsSet {
            setupAddressBindings()
            bindingsSet = true
        }
    }
    
    // MARK: - private
    
    private func setupViews() {
        view.backgroundColor = .white
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController.searchResultsUpdater = resultsViewController
        searchController.searchBar.sizeToFit()
        
        navigationItem.titleView = searchController?.searchBar
        
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
    }
    
    private func setupAddressBindings() {
        viewModel.coordinateShownUpdated
            .drive(onNext: { [weak self] value in
                self?.handleCoordinateUpdate(value)
            })
            .disposed(by: disposeBag)
        viewModel.addressUpdated
            .drive(onNext: { [weak self] value in
                self?.handleAddressUpdate(info: value)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupNavigationBar() {
        let button = UIBarButtonItem(
            image: Asset.Common.closeIcon.image,
            style: .plain,
            target: nil,
            action: nil
        )
        button.rx.tap
            .bind(onNext: viewModel.close)
            .disposed(by: disposeBag)
        navigationItem.leftBarButtonItem = button
    }
    
    private func handleAddressUpdate(info: CreateListingAddressViewModel.PinInfo?) {
        if let info = info {
            if doneButton == nil {
                loadDoneButton()
            }
            
            marker?.map = nil
            addMarker(info: info)
            doneButton?.isHidden = false
        } else {
            marker?.map = nil
            doneButton?.isHidden = true
        }
    }
    
    private func handleCoordinateUpdate(_ coordinate: CLLocationCoordinate2D?) {
        if let coordinate = coordinate {
            if mapView == nil {
                loadMap(with: coordinate)
            } else {
                let camera = GMSCameraPosition.camera(
                    withLatitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    zoom: mapView.camera.zoom
                )
                mapView.camera = camera
            }
        }
    }
    
    private func loadMap(with coordinate: CLLocationCoordinate2D) {
        guard mapView == nil else { return }
        let camera = GMSCameraPosition.camera(
            withLatitude: coordinate.latitude,
            longitude: coordinate.longitude,
            zoom: 15.0
        )
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        view.addSubview(mapView)
        mapView.layout {
            $0.top == view.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
        }
        mapView.delegate = self
    }
    
    private func loadDoneButton() {
        doneButton = ConfirmationButton()
        view.addSubview(doneButton)
        doneButton.layout {
            $0.leading == view.leadingAnchor + 75.0
            $0.trailing == view.trailingAnchor - 75.0
            $0.bottom == view.safeAreaLayoutGuide.bottomAnchor - 18.0
            $0.height == 40.0
        }
        
        doneButton.setAttributedTitle(
            L10n.Buttons.Done.title.uppercased().toAttributed(
                with: FontFamily.SamsungSharpSans.bold.font(size: 12.0),
                lineSpacing: 0.0,
                alignment: .center,
                color: .white,
                kern: 1
            ),
            for: .normal
        )
        
        doneButton.rx.tap
            .bind(onNext: viewModel.done)
            .disposed(by: disposeBag)
    }
    
    private func addMarker(info: CreateListingAddressViewModel.PinInfo) {
        let marker = GMSMarker(position: info.coordinate)
        marker.snippet = info.title
        marker.map = mapView
        mapView.selectedMarker = marker
        self.marker = marker
    }
    
}

extension CreateListingAddressViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(
        _ resultsController: GMSAutocompleteResultsViewController,
        didAutocompleteWith place: GMSPlace
    ) {
        searchController.isActive = false
        viewModel.addressSelected(
            coordinate: place.coordinate,
            name: place.name,
            formattedAddress: place.formattedAddress
        )
    }
    
    func resultsController(
        _ resultsController: GMSAutocompleteResultsViewController,
        didFailAutocompleteWithError error: Error
    ) {
        showDefaultAlert(with: .error, message: error.localizedDescription)
    }
    
}

extension CreateListingAddressViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        marker?.map = nil
        viewModel.coordinateTapped(coordinate)
    }
    
}
