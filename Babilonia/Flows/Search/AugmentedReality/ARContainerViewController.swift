//
//  ARContainerViewController.swift
//  Babilonia
//
//  Created by Vitaly Chernysh on 7/17/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import ARKitLocation
import MapKit
import RxSwift
import GoogleMaps
import GooglePlaces
import AVFoundation

//swiftlint:disable line_length
final class ARContainerViewController: UIViewController, SlidingContainerPresentable, AlertApplicable, SpinnerApplicable {
    //swiftlint:enable line_length
    
    let alert = ApplicationAlert()
    let spinner = AppSpinner()

    var slidingContainerView: SlidingContainerView! {
        didSet {
            guard slidingContainerView != nil else { return }
            
            slidingContainerClosingDisposeBag = DisposeBag()
            slidingContainerView.closingRequest.doOnNext { [weak self] in
                self?.applyDefaultAnnotationsState()
                self?.extendedListingPreview = nil
            }.disposed(by: slidingContainerClosingDisposeBag)
        }
    }
    var isSlidingContainerPresenting = false

    let viewModel: ARContainerViewModel
    var arViewController: ARViewController?
    var mapView: GMSMapView?
    var updateUserLocationTimer: Timer?
    var metersView: MetersView!
    var currentMarker: GMSMarker?
    var listingPreview: TopNavigationListingPreview?
    let mapButton: UIButton = .init()
    var previousCurrentLocation: CLLocation?
    var routePolyline = [GMSCircle]()

    private var exitButton: UIButton!
    private var arrowImageView = UIImageView(image: Asset.AugmentedReality.navigationArrow.image)
    private var slidingContainerClosingDisposeBag = DisposeBag()
    private var distinationLocation: CLLocation?
    private var extendedListingPreview: ListingPreviewContentView?
    private let gradientView: UIView = .init()
    private var gradientLayer: CALayer!
    private let closeARButton: UIButton = .init()
    private let titleLabel: UILabel = .init()
    private var isNavigationMode = false
    private var shouldLoadARViewController = true
    private var shouldShowListingOnAppear = false
    private var composerManager: ExternalDataComposerManager!
    private var selectedAnnotation: ARAnnotation?
    private var arAnnotations = [ARAnnotation]()
    var isFullscreenMap = false

    var topMapConstraint: NSLayoutConstraint?
    var heightMapConstraint: NSLayoutConstraint?
    var leadingMapConstraint: NSLayoutConstraint?
    var trailingMapConstraint: NSLayoutConstraint?
    var topListingPreviewConstraint: NSLayoutConstraint?
    var timer: Timer?

    // MARK: - Lifecycle
    
    deinit {
        invalidateLocationUpdatingTimer()
    }
    
    init(viewModel: ARContainerViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBindings()
        setupUIBinding()
        composerManager = ExternalDataComposerManager(controller: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
        guard shouldLoadARViewController else { return }

        configureARViewController()
        viewModel.fetchListings()
        setupView()

        if viewModel.shouldShowCameraAlert &&
            AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            presentCameraAccessAlert()

            return
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showListingPreviewIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isSlidingContainerPresenting {
            hideSlidingContainer()
        }
        viewModel.shouldShowCameraAlert = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard gradientLayer == nil, gradientView.frame != .zero else { return }
        let colors = [Asset.Colors.vulcan.color.withAlphaComponent(0.8).cgColor,
                      UIColor.clear.cgColor]
        gradientLayer = gradientView.layer.addGradientLayer(colors: colors,
                                                            locations: [0.0, 1.0]
        )
    }
    
    private func setupBindings() {
        viewModel.requestState
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .started:
                    self?.showSpinner()
                default:
                    self?.hideSpinner()
                }
            })
            .disposed(by: disposeBag)

        viewModel.listings.skip(1).doOnNext { [weak self] listings in
            // Note: - We do not reload annotations while user is in navigation mode, because user should only see one
            // target annotation in navigation mode.
            // Such reload happens each time when model fires `requestFetchingUpdates` (works like paginated requests).
            // Also reload happens on initial screen setup.
            // Please, kindly note that even if annotations reload is not called due to navigation mode, the reload
            // will still happen when user closes navigation mode and goes back to all annotations.
            guard let self = self, !self.isMapViewShown else { return }

            self.arViewController?.presenter.clear()
            self.arViewController?.setAnnotations(self.annotations(from: listings))
        }.disposed(by: disposeBag)

        viewModel.arrivalToDestinationUpdates.doOnNext { [weak self] in
            guard let self = self else { return }
            guard let visibleAnnotationViews = self.arViewController?.presenter.visibleAnnotationViews else { return }
            
            let isDestinationVisible = !visibleAnnotationViews.isEmpty
            
            guard isDestinationVisible else { return }
            
            self.quitFromNavigationMode()
            self.extendedListingPreview?.showContactButton()
            self.showDefaultAlert(with: .success, message: self.viewModel.destinationReachedTitle)
        }.disposed(by: disposeBag)
        
        viewModel.requestFetchingUpdates.doOnNext { [weak self] in
            self?.viewModel.fetchListings()
        }.disposed(by: disposeBag)

        viewModel.headingUpdates
            .subscribe(onNext: { [weak self] heading in
                guard let heading = heading else { return }

                self?.currentMarker?.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                self?.currentMarker?.rotation = heading.trueHeading
            })
            .disposed(by: disposeBag)

        viewModel.routePoints
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] points in
                guard let points = points else { return }

                self?.buildRoute(points: points)
            })
            .disposed(by: disposeBag)
    }

    private func setupUIBinding() {
        closeARButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.shouldLoadARViewController = false
                self?.arViewController?.dismiss(animated: true) {
                    self?.viewModel.close()
                }
            })
        .disposed(by: disposeBag)

        mapButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.isFullscreenMap = !self.isFullscreenMap
                let image = self.isFullscreenMap ? Asset.AugmentedReality.mapCloseButton.image
                                                 : Asset.AugmentedReality.mapFullscreenButton.image
                self.mapButton.setImage(image, for: .normal)
                self.animateMapViewFrame()
            })
            .disposed(by: disposeBag)
    }

    private func removeMap(completion: (() -> Void)?) {
        mapView?.fadeOut { [weak self] in
            guard let self = self else { return }
            
            self.mapView?.removeFromSuperview()
            self.mapView = nil
            self.invalidateLocationUpdatingTimer()
            completion?()
        }
    }

    private func invalidateLocationUpdatingTimer() {
        updateUserLocationTimer?.invalidate()
        updateUserLocationTimer = nil
    }
    
    // MARK: - ARViewController configuration

    private func configureARViewController() {
        let arViewController = ARViewController()
        
        arViewController.dataSource = self
        arViewController.presenter.distanceOffsetMode = .manual
        arViewController.presenter.distanceOffsetMultiplier = 0.1 // Pixels per meter
        arViewController.presenter.distanceOffsetMinThreshold = 500.0
        arViewController.presenter.maxDistance = 1000.0
        arViewController.presenter.maxVisibleAnnotations = 500
        arViewController.presenter.presenterTransform = ARPresenterStackTransform()
        arViewController.trackingManager.userDistanceFilter = kCLDistanceFilterNone
        arViewController.trackingManager.reloadDistanceFilter = 25.0
        arViewController.uiOptions.closeButtonEnabled = false
        arViewController.uiOptions.simulatorDebugging = false
        arViewController.uiOptions.setUserLocationToCenterOfAnnotations = false
        arViewController.interfaceOrientationMask = .portrait

        arViewController.setAnnotations([])
        self.arViewController = arViewController

        addChild(arViewController)
        arViewController.view.frame = UIScreen.main.bounds
        view.addSubview(arViewController.view)
        arViewController.didMove(toParent: self)
    }

    private func buildListingPreviewContentView(
        by listing: Listing,
        for selectedAnnotation: ARAnnotation
    ) -> ListingPreviewContentView {
        let userID = listing.user.id
        let listingTypeViewModel = ListingTypeViewModel(labelsAlignment: .vertical)
        let listingViewModel = ListingViewModel(listing: listing,
                                                configsService: viewModel.configsService,
                                                isUserOwnedListing: viewModel.isUserOwnedListing(with: userID))

        let listingPreviewViewModel = ListingPreviewViewModel(
            listingTypeViewModel: listingTypeViewModel,
            listingViewModel: listingViewModel,
            isBottomButtonsHidden: false,
            photos: listing.sortedPhotos.map { ListingDetailsImage.remote($0) }
        )

        let listingPreviewView = ListingPreviewContentView()
        listingPreviewView.setup(with: listingPreviewViewModel)
        listingPreviewView.frame = CGRect(x: 0.0,
                                          y: 0.0,
                                          width: view.frame.width,
                                          height: 304.0 + view.safeAreaInsets.bottom)
        
        listingPreviewView.didToggleDetails = { [weak self] _ in
            self?.shouldShowListingOnAppear = true
            self?.viewModel.presentListingDetails(for: listing)
        }
        listingPreviewView.didTogglePhotoTap = { [weak self] in
            self?.shouldShowListingOnAppear = true
            self?.viewModel.presentListingDetails(for: listing)
        }
        listingPreviewView.didToggleFavorite = { [weak self] isSelected in
            if !isSelected {
                self?.viewModel.removeListingFromFavorites(listingID: String(listing.id))
            } else {
                self?.viewModel.addListingToFavorites(listingID: String(listing.id))
            }
        }
        listingPreviewView.didToggleNavigation = { [weak self] _ in
            guard let self = self, let arViewController = self.arViewController else { return }
            
            DispatchQueue.main.async {
                guard let listingLocation = listing.location else { return }
                self.isNavigationMode = true

                let destinationCoordinate = CLLocationCoordinate2D(latitude: Double(listingLocation.latitude),
                                                                   longitude: Double(listingLocation.longitude))
                self.viewModel.setDestination(with: destinationCoordinate)
                self.slidingContainerView.fadeOut()
                arViewController.presenter.clear()

                let distinationAnnotation = self.annotations(from: [listing])
                arViewController.setAnnotations(distinationAnnotation)

                self.setupMap(destinationCoordinate)
                self.metersView?.applyDistance(selectedAnnotation.distanceFromUser)
                self.setupListingPreview(for: listingViewModel)
            }
        }

        listingPreviewView.didToggleContact = { [weak self] _ in
            guard let self = self else { return }

            let phone = listing.user.phoneNumber
            self.composerManager.proceedPhone(phone)
        }

        extendedListingPreview = listingPreviewView
        if viewModel.shouldShowContact(for: listing) {
            listingPreviewView.showContactButton()
        }
        
        return listingPreviewView
    }

    @objc
    private func close(_ sender: UIButton) {
        if !isMapViewShown {
            self.shouldLoadARViewController = false
            arViewController?.dismiss(animated: true) {
                self.viewModel.close()
            }
        }

        quitFromNavigationMode()
    }
    
    private func quitFromNavigationMode() {
        UIView.animate(withDuration: 0.3,
                       animations: { self.listingPreview?.alpha = 0 },
                       completion: { _ in self.listingPreview = nil })
        isNavigationMode = false
        metersView?.removeFromSuperview()
        mapButton.removeFromSuperview()
        metersView = nil
        slidingContainerView?.fadeIn()
        removeMap {
            self.viewModel.setDestination(with: nil)
            self.arViewController?.presenter.clear()
            self.arViewController?.setAnnotations(self.annotations(from: self.viewModel.listings.value))
            self.applyLowerAlphaForUnselectedAnnotations()
        }
    }

    // MARK: - Helper functions
    
    private func annotations(from listings: [Listing]) -> [ARAnnotation] {
        var annotations = [ARAnnotation]()
        
        for listingIndex in 0..<listings.count {
            guard let listingLocation = listings[listingIndex].location else { continue }

            let coreLocation = CLLocation(
                latitude: Double(listingLocation.latitude),
                longitude: Double(listingLocation.longitude)
            )

            if let annotation = ARAnnotation(identifier: String(listingIndex), title: nil, location: coreLocation) {
                annotation.listingId = listings[listingIndex].id
                annotations.append(annotation)
            }
        }

        return annotations
    }

    /// Sets alpha of all AnnotationViews on the screen to 1.0. Also sets selectedAnnotationView to nil.
    private func applyDefaultAnnotationsState() {
        arViewController?.presenter.annotationViews.forEach { $0.fadeIn() }
        selectedAnnotationView = nil
    }

    /// Sets alpha = 0.7 for all AnnotationViews on the screen, EXCEPT the selected one (it is set to 1.0).
    private func applyLowerAlphaForUnselectedAnnotations() {
        guard let selectedAnnotationView = selectedAnnotationView,
            let annotationViews = arViewController?.presenter.annotationViews else {
                return
        }

        let notSelectedAnnotationViews =
            annotationViews.filter { $0.annotation?.identifier != selectedAnnotationView.annotation?.identifier }
        notSelectedAnnotationViews.forEach { $0.fade(by: 0.7) }
        selectedAnnotationView.fadeIn()
    }

    private func listing(by listingId: ListingId) -> Listing? {
        return viewModel.listings.value.first { $0.id == listingId }
    }

}

// MARK: - Views Setup

extension ARContainerViewController {

    private func setupView() {
        guard let arView = arViewController?.view else { return }

        arView.addSubview(gradientView)
        gradientView.layout {
            $0.leading == arView.leadingAnchor
            $0.trailing == arView.trailingAnchor
            $0.top == arView.topAnchor
            $0.height.equal(to: 70)
        }

        closeARButton.setImage(Asset.Common.closeIcon.image.withRenderingMode(.alwaysTemplate),
                               for: .normal)
        closeARButton.tintColor = .white

        arView.addSubview(closeARButton)
        closeARButton.layout {
            $0.width.equal(to: 24)
            $0.height.equal(to: 24)
            $0.leading.equal(to: arView.leadingAnchor, offsetBy: 14)
            $0.top.equal(to: arView.topAnchor, offsetBy: 60)
        }

        titleLabel.text = L10n.Ar.Main.title
        titleLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 16)
        titleLabel.textColor = .white

        arView.addSubview(titleLabel)
        titleLabel.layout {
            $0.centerX.equal(to: arView.centerXAnchor)
            $0.top.equal(to: arView.topAnchor, offsetBy: 60)
        }
    }

    private func setupListingPreview(for listingViewModel: ListingViewModel) {
        guard let arView = arViewController?.view else { return }

        let previewView = TopNavigationListingPreview()
        previewView.apply(listingViewModel)
        previewView.alpha = 0

        arView.addSubview(previewView)
        previewView.layout {
            $0.leading.equal(to: arView.leadingAnchor)
            $0.trailing.equal(to: arView.trailingAnchor)
            topListingPreviewConstraint = $0.top.equal(to: arView.topAnchor)
            $0.height.equal(to: 128 + UIConstants.safeLayoutTop)
        }

        listingPreview = previewView
        addExitButton()

        UIView.animate(withDuration: 0.3,
                       animations: { previewView.alpha = 1 })
    }

    private func addExitButton() {
        guard let listingPreview = listingPreview else { return }

        exitButton = UIButton()
        exitButton.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
        exitButton.setTitle(L10n.CreateListing.Finish.Button.title.uppercased(), for: .normal)
        exitButton.setTitleColor(Asset.Colors.almostBlack.color, for: .normal)
        exitButton.backgroundColor = .clear
        exitButton.titleLabel?.font = FontFamily.SamsungSharpSans.bold.font(size: 12)
        exitButton.layerCornerRadius = 20.0
        exitButton.layerBorderWidth = 1.0
        exitButton.layerBorderColor = Asset.Colors.cloudyBlue.color

        listingPreview.addSubview(exitButton)
        exitButton.layout {
            $0.height.equal(to: 40)
            $0.width.equal(to: 92)
            $0.trailing.equal(to: listingPreview.trailingAnchor, offsetBy: -16)
            $0.bottom.equal(to: listingPreview.bottomAnchor, offsetBy: -48)
        }
    }

    private func showListingPreviewIfNeeded() {
        guard shouldShowListingOnAppear,
              let annotation = selectedAnnotation,
              let listingID = annotation.listingId,
              let listing = listing(by: listingID),
              let optionalWindow = UIApplication.shared.delegate?.window,
              let window = optionalWindow else { return }

        shouldShowListingOnAppear = false
        let listingPreviewView = buildListingPreviewContentView(by: listing, for: annotation)
        presentSlidingContainer(with: listingPreviewView, showingOn: window)
    }

    private func presentCameraAccessAlert() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsURL),
              viewModel.shouldShowCameraAlert else { return }

        SystemAlert.present(on: self,
                            message: L10n.Popups.CameraAccess.text,
                            confirmTitle: L10n.Buttons.Settings.title,
                            declineTitle: L10n.Buttons.Cancel.title,
                            confirm: {
                                UIApplication.shared.open(settingsURL)
                            })
    }

}

// MARK: - ARDataSouce

extension ARContainerViewController: ARDataSource {

    // swiftlint:disable all

    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        guard let listingId = viewForAnnotation.listingId,
            let listing = listing(by: listingId) else {
                fatalError("Attempt to create ARAnnotation without Listing object associated with it. It's meaningless.")
        }

        if isNavigationMode {
            let annotationView = AnnotationContainerView(isNavigationMode: true)
            annotationView.didSetDistanceFromUser = { [weak self] distanceFromUser in
                self?.metersView?.applyDistance(distanceFromUser)
            }

            return annotationView
        }

        let userID = listing.user.id
        let annotationView = AnnotationContainerView()
        let listingViewModel = ListingViewModel(listing: listing,
                                                configsService: viewModel.configsService,
                                                isUserOwnedListing: viewModel.isUserOwnedListing(with: userID))

        annotationView.apply(listingViewModel)
        annotationView.didSetDistanceFromUser = { [weak self] distanceFromUser in
            self?.metersView?.applyDistance(distanceFromUser)
        }

        annotationView.didSelectAnnotation = { [weak self] annotationView in
            guard let self = self, let annotation = annotationView.annotation, !self.isMapViewShown else {
                return
            }

            guard let listingId = annotation.listingId,
                let listing = self.listing(by: listingId) else {
                    fatalError("Attempt to access ARAnnotation without Listing object associated with it.")
            }

            annotationView.backgroundColor = .white
            
            // If user clicks on any AnnotationView, while ListingPreview is shown
            guard !self.isSlidingContainerPresenting else {
                let isSameAnnotationViewSelected = self.selectedAnnotationView?.annotation?.identifier ==
                    annotationView.annotation?.identifier
                
                // If user clicks on the same AnnotationView, while ListingPreview is shown
                if isSameAnnotationViewSelected {
                    self.hideSlidingContainer { [weak self] in
                        self?.applyDefaultAnnotationsState()
                    }
                    annotationView.backgroundColor = UIColor.white.withAlphaComponent(0.65)
                } else {
                    // If user clicks on different AnnotationView, while ListingPreview is shown
                    self.selectedAnnotationView = annotationView
                    self.selectedAnnotation = annotationView.annotation
                    self.applyLowerAlphaForUnselectedAnnotations()
                    let listingPreviewView = self.buildListingPreviewContentView(by: listing, for: annotation)
                    self.slidingContainerView.replaceContentView(with: listingPreviewView)

                    arViewController.getAnnotations().forEach {
                        $0.annotationView?.backgroundColor = UIColor.white.withAlphaComponent(0.65)
                    }
                    annotationView.backgroundColor = .white
                }

                return
            }

            self.selectedAnnotationView = annotationView
            self.selectedAnnotation = annotationView.annotation
            self.applyLowerAlphaForUnselectedAnnotations()
            let listingPreviewView = self.buildListingPreviewContentView(by: listing, for: annotation)

            guard let optionalWindow = UIApplication.shared.delegate?.window, let window = optionalWindow else { return }

            self.presentSlidingContainer(with: listingPreviewView, showingOn: window)
        }

        return annotationView
    }

}
