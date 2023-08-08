//
//  SearchMapViewController.swift
//  Babilonia
//
//  Created by Denis on 7/25/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import GoogleMaps
import Core

final class SearchMapViewController: UIViewController, AlertApplicable, SlidingContainerPresentable {
    
    let alert = ApplicationAlert()
    var zoomBounds = false
    var slidingContainerView: SlidingContainerView! {
        didSet {
            guard slidingContainerView != nil else { return }
            
            slidingContainerClosingDisposeBag = DisposeBag()
            slidingContainerView.closingRequest.doOnNext { [weak self] in
                self?.applyDefaultAnnotationsState()
            }.disposed(by: slidingContainerClosingDisposeBag)
        }
    }
    var isSlidingContainerPresenting = false
    private var searchBar: UISearchBar?
    private var mapView: GMSMapView!
    private var myLocationButton: UIButton!
    private var myLocationShadowView: UIView!
    private var myLocationShadowLayer: CALayer!
    private var emptySearchView: EmptySearchView!
    
    private let viewModel: SearchMapViewModel
    private var bindingsSet = false
    private var markers = [GMSMarker]()
    private var slidingContainerClosingDisposeBag = DisposeBag()

    private var parentView: UIView {
        return parent!.view
    }

    // MARK: - lifecycle
    
    init(viewModel: SearchMapViewModel) {
         self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        layout()
        setupViews()
        setupBindings()
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if viewModel.shouldReloadOnAppear {
            loadMapFromList()
            viewModel.fetchListings()
        }
        viewModel.shouldReloadOnAppear = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isSlidingContainerPresenting {
            applyDefaultAnnotationsState()
            hideSlidingContainer()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addShadows()
    }
    
    // MARK: - private

    private func layout() {
        myLocationButton = SearchActionButton()
        view.addSubview(myLocationButton)
        myLocationButton.layout {
            $0.leading == view.leadingAnchor + 10.0
            $0.bottom == view.safeAreaLayoutGuide.bottomAnchor - 40.0
            $0.width == 48.0
            $0.height == 48.0
        }
        
        myLocationShadowView = UIView()
        view.insertSubview(myLocationShadowView, belowSubview: myLocationButton)
        myLocationShadowView.layout {
            $0.top == myLocationButton.topAnchor
            $0.leading == myLocationButton.leadingAnchor
            $0.trailing == myLocationButton.trailingAnchor
            $0.bottom == myLocationButton.bottomAnchor
        }
        
        emptySearchView = EmptySearchView()
        emptySearchView.isHidden = true
        view.addSubview(emptySearchView)
        emptySearchView.layout {
            $0.top == view.topAnchor + 29.0
            $0.leading == view.leadingAnchor + 16.0
            $0.trailing == view.trailingAnchor - 16.0
        }
    }
    
    public func setSearchBar(searchBar: UISearchBar) {
        self.searchBar = searchBar
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        myLocationButton.setImage(Asset.Search.myLocationIcon.image, for: .normal)
    }
    
    private func setupBindings() {
        bind(requestState: viewModel.requestState)
        
        myLocationButton.rx.tap
            .bind { [weak self] in
                guard let self = self, let location = self.mapView.myLocation else { return }
                let camera = GMSCameraPosition.camera(
                    withLatitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    zoom: self.mapView.camera.zoom
                )
                self.mapView.animate(to: camera)
            }
            .disposed(by: disposeBag)
        
        viewModel.markerInfosUpdated
            .skip(1)
            .drive(onNext: { [weak self] infos in
                self?.updateMarkers(with: infos)
                self?.emptySearchView.isHidden = !infos.isEmpty
            })
            .disposed(by: disposeBag)
    }
    
    private func addShadows() {
        if myLocationShadowLayer == nil {
            myLocationButton.makeViewRound()
            myLocationShadowLayer = myLocationShadowView.layer.addShadowLayer(
                color: Asset.Colors.vulcan.color.cgColor,
                offset: CGSize(width: 0.0, height: 4.0),
                radius: 6.0,
                opacity: 0.25,
                cornerRadius: myLocationShadowView.frame.width / 2.0
            )
        }
    }
    
    private func setupAddressBindings() {
        viewModel.coordinateShownUpdated
            .drive(onNext: { [weak self] value in
                self?.handleCoordinateUpdate(value)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleCoordinateUpdate(_ coordinate: CLLocationCoordinate2D?) {
        if let coordinate = coordinate {
            if mapView == nil {
                let initialCoordinate = viewModel.searchResultCoordinate ?? coordinate
                loadMap(with: initialCoordinate)
            } else {
                let camera = GMSCameraPosition.camera(
                    withLatitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    zoom: mapView.camera.zoom
                )
                mapView.camera = camera
            }
            myLocationButton.isHidden = false
            myLocationShadowView.isHidden = false
        } else {
            myLocationButton.isHidden = true
            myLocationShadowView.isHidden = true
        }
    }
    
    private func loadMapFromList() {
        
        if let location = viewModel.currentListingByList?.location {
            
            let coordinate = CLLocationCoordinate2D(latitude: Double(location.latitude),
                                                       longitude: Double(location.longitude))
            let camera = GMSCameraPosition.camera(
                withLatitude: coordinate.latitude,
                longitude: coordinate.longitude,
                zoom: mapView.camera.zoom
            )
            
            if mapView != nil {
                mapView.camera = camera
            }
        }
    }
    private func loadMap(with coordinate: CLLocationCoordinate2D) {
        guard mapView == nil else { return }
        var camera = GMSCameraPosition.camera(
            withLatitude: coordinate.latitude,
            longitude: coordinate.longitude,
            zoom: 15.0
        )
        if let location = viewModel.currentListingByList?.location {
            let coordinate = CLLocationCoordinate2D(latitude: Double(location.latitude),
                                                       longitude: Double(location.longitude))
            camera = GMSCameraPosition.camera(
                withLatitude: coordinate.latitude,
                longitude: coordinate.longitude,
                zoom: 15.0
            )
        }
        
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.padding = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 20.0, right: 0.0)
        view.insertSubview(mapView, at: 0)
        mapView.layout {
            $0.top == view.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
        }
        mapView.delegate = self
    }
    
    private func updateMarkers(with infos: [(SearchMapMarkerInfo, CLLocationCoordinate2D)]) {
        var indexesToRemove = [Int]()
        let existingInfos = markers
            .enumerated()
            .compactMap { (index, marker) -> ((SearchMapMarkerInfo, CLLocationCoordinate2D))? in
                guard let iconView = marker.iconView as? SearchMapMarker else { return nil }
                if let info = infos.first(where: { $0.0.listingId == iconView.listingId }) {
                    iconView.setup(with: info.0)
                    return info
                } else {
                    marker.map = nil
                    indexesToRemove.append(index)
                    return nil
                }
            }
        
        indexesToRemove.reversed().forEach {
            markers.remove(at: $0)
        }
        
        let existingIDs = existingInfos.map { $0.0.listingId }
        var existingCoordinates = existingInfos.map { $0.1 }
        let coordinateBounds = GMSCoordinateBounds()
        infos
            .filter { !existingIDs.contains($0.0.listingId) }
            .forEach { info in
                // preventing of showing pins with same coordinate
                coordinateBounds.contains(info.1)
                guard !existingCoordinates
                    .contains(where: { $0.latitude == info.1.latitude && $0.longitude == info.1.longitude }) else {
                        return
                }
                existingCoordinates.append(info.1)
                let marker = GMSMarker(position: info.1)
                
                let view = SearchMapMarker()
                marker.iconView = view
                
                view.setup(with: info.0)
                marker.map = mapView
                
                markers.append(marker)
            }
    
        if let info = infos.first, RecentLocation.shared.currentLocation != nil, !RecentLocation.shared.mapCenter {
            //searchBar?.text = ""
            //RecentLocation.shared.currentLocation = nil
            RecentLocation.shared.mapCenter = true
            viewModel.updateListingByList(listing: viewModel.firstListing())
            let camera = GMSCameraPosition.camera(
                withLatitude: info.1.latitude,
                longitude: info.1.longitude,
                zoom: self.mapView.camera.zoom
            )
            self.mapView.animate(to: camera)
        }
        
        if !zoomBounds {
            let cameraUpdate = GMSCameraUpdate.fit(coordinateBounds)
            self.mapView.animate(with: cameraUpdate)
            zoomBounds = true
        }
    }
    
    private func handleMarkerSelection(_ marker: GMSMarker) {
        guard let view = marker.iconView as? SearchMapMarker else { return }
        guard let listing = viewModel.listing(with: view.listingId) else { return }
        
        guard !isSlidingContainerPresenting else {
            if view.isSelected {
                applyDefaultAnnotationsState()
                hideSlidingContainer()
            } else {
                applyDefaultAnnotationsState(view)
                let listingPreviewView = buildListingPreviewContentView(with: listing)
                slidingContainerView.replaceContentView(with: listingPreviewView)
            }
            
            return
        }
        
        applyDefaultAnnotationsState(view)
        let listingPreviewView = buildListingPreviewContentView(with: listing)
        
        //
        // Note: - We present a SlidingContainer over parent's view, because we want SlidingContainer to cover all
        // of parent view's subviews. E.g. - if we present sliding container over current VC's view, AR and Menu buttons
        // would be still visible though.
        // Please, also read the note above listingPreviewView's frame setup in `buildListingPreviewContentView` method.
        //
        self.presentSlidingContainer(with: listingPreviewView, showingOn: parentView)
    }
    
    private func buildListingPreviewContentView(with listing: Listing) -> ListingPreviewContentView {
        let userID = listing.user.id
        let listingTypeViewModel = ListingTypeViewModel(labelsAlignment: .vertical)
        let listingViewModel = ListingViewModel(listing: listing,
                                                configsService: viewModel.configsService,
                                                isUserOwnedListing: viewModel.isUserOwnedListing(with: userID))
        
        let listingPreviewViewModel = ListingPreviewViewModel(
            listingTypeViewModel: listingTypeViewModel,
            listingViewModel: listingViewModel,
            isBottomButtonsHidden: true,
            photos: listing.sortedPhotos.map { ListingDetailsImage.remote($0) }
        )
        
        let listingPreviewView = ListingPreviewContentView()
        listingPreviewView.setup(with: listingPreviewViewModel)
        //
        // Note: - We add `parentView.safeAreaInsets.bottom`, because we want slidingContainer to located over
        // the Tab bar. The `safeAreaInsets` of current VC's view does not include the size of tab bar, while
        // parent's view does.
        //
        listingPreviewView.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: view.frame.width,
            height: 243.0 + view.safeAreaInsets.bottom + parentView.safeAreaInsets.bottom
        )
                
        listingPreviewView.didToggleFavorite = { [weak self] _ in
            self?.viewModel.setListingFavoriteState(for: listing.id)
        }
        listingPreviewView.didToggleDetails = { [weak self] _ in
            self?.viewModel.presentListingDetails(for: listingPreviewView.listingID)
        }
        listingPreviewView.didTogglePhotoTap = { [weak self] in
            self?.viewModel.presentListingDetails(for: listingPreviewView.listingID)
        }

        return listingPreviewView
    }
    
    private func applyDefaultAnnotationsState(_ selectedView: SearchMapMarker? = nil) {
        markers.forEach { ($0.iconView as? SearchMapMarker)?.isSelected = false }
        selectedView?.isSelected = true
    }
    
}

extension SearchMapViewController: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let coordinate = position.target
        let radius = mapView.getRadius()
        
        if let location = viewModel.currentListingByList?.location {
           if location.latitude != Float(coordinate.latitude)
               || location.longitude != Float(coordinate.longitude) {
                searchBar?.text = ""
            RecentLocation.shared.currentLocation = nil            
           }
        } else {
            searchBar?.text = ""
            RecentLocation.shared.currentLocation = nil  
        }
        viewModel.updateListingByList(listing: nil)
        viewModel.updateCoordinate(coordinate)
        viewModel.updateRadius(radius)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        handleMarkerSelection(marker)
        
        return true
    }
    
}
