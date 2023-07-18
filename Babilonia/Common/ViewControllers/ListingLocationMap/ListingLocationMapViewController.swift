//
//  ListingLocationMapViewController.swift
//  Babilonia
//
//  Created by Alya Filon  on 09.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingLocationMapViewController: NiblessViewController, AlertApplicable, HasCustomView {
    
    typealias CustomView = ListingLocationMapView
    
    let alert = ApplicationAlert()
    
    private let viewModel: ListingLocationMapViewModel
    
    init(viewModel: ListingLocationMapViewModel) {
         self.viewModel = viewModel
        
        super.init()
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        let customView = CustomView()
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.checkLocation()
        setupViews()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)

        super.viewWillDisappear(animated)
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        customView.backButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        customView.currentLocationButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                self.customView.setCurrentLocation(self.viewModel.currentLocation,
                                                   shouldCenter: true)
            })
            .disposed(by: disposeBag)

        customView.routeButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.presentMapsActions()
            })
            .disposed(by: disposeBag)

        viewModel.requestForLocationPermissionObservable
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                SystemAlert.present(on: self,
                                    title: L10n.SearchByLocation.PermissionPopUp.title,
                                    message: L10n.SearchByLocation.PermissionPopUp.message)
            })
            .disposed(by: disposeBag)
    }

    private func setupViews() {
        if let addressInfo = viewModel.addressInfo {
            customView.setup(with: addressInfo)
        }
        customView.setCurrentLocation(viewModel.currentLocation)
    }

    private func presentMapsActions() {
        let alert = UIAlertController(title: L10n.ListingDetails.Map.Actions.title,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let appleMapAction = UIAlertAction(title: L10n.ListingDetails.Map.Actions.appleMaps,
                                           style: .default, handler: { _ in
            self.viewModel.openAppleMap()
        })
        alert.addAction(appleMapAction)

        if viewModel.isGoogleMapsInstalled {
            let googleMapAction = UIAlertAction(title: L10n.ListingDetails.Map.Actions.googleMaps,
                                                style: .default, handler: { _ in
                self.viewModel.openGoogleMap()
            })
            alert.addAction(googleMapAction)
        }

        if viewModel.isWazeInstalled {
            let googleMapAction = UIAlertAction(title: L10n.ListingDetails.Map.Actions.waze,
                                                style: .default, handler: { _ in
                self.viewModel.openWazeMap()
            })
            alert.addAction(googleMapAction)
        }

        alert.addAction(UIAlertAction(title: L10n.Buttons.Cancel.title, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
