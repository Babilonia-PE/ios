//
//  SearchFlowCoordinator.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject
import Core

enum SearchFlowEvent: Event {
    case presentListingDetails(listingID: Int)
}

final class SearchFlowCoordinator: EventNode, FlowCoordinator {
    
    weak var containerViewController: UIViewController?
    weak var searchDelegate: SearchUpdatable?
    weak var arNavigationController: UINavigationController?
    
    private let container: Container
    
    init(container: Container, parent: EventNode) {
        self.container = Container(parent: container) { (container: Container) in
            SearchFlowAssembly().assemble(container: container)
        }
        
        super.init(parent: parent)
        
        addHandler { [weak self] (event: SearchEvent) in self?.handle(event) }
        addHandler { [weak self] (event: ARModelEvent) in self?.handle(event) }
        addHandler { [weak self] (event: LocationSearchEvent) in self?.handle(event) }
        addHandler { [weak self] (event: ListingDetailsPresentableEvent) in self?.handle(event) }
        addHandler { [weak self] (event: ListingDetailsEvent) in self?.handle(event) }
        addHandler { [weak self] (event: ListingDetailsDescriptionEvent) in self?.handle(event) }
        addHandler { [weak self] (event: CreateListingCommonEvent) in self?.handle(event) }
        addHandler { [weak self] (event: ListingsFiltersEvent) in self?.handle(event) }
        addHandler { [weak self] (event: SearchFlowEvent) in self?.handle(event) }
        addHandler { [weak self] (event: PhotoGalleryEvent) in self?.handle(event) }
    }
    
    @discardableResult
    func createFlow() -> UIViewController {
        let model = SearchModel(parent: self,
                                locationManager: container.autoresolve(),
                                configService: container.autoresolve(),
                                listingsService: container.autoresolve(),
                                userService: container.autoresolve(),
                                appSettingsStore: UserDefaults())
        searchDelegate = model
        let viewModel = SearchViewModel(model: model)
        let controller = SearchViewController(viewModel: viewModel)

        return controller
    }
    
    private func arContainerViewController() -> ARContainerViewController {
        return container.autoresolve(argument: self) as ARContainerViewController
    }

    private func presentListingDetail(for listing: Listing) {
        let isModalPresentation = arNavigationController == nil
        let controller: CommonListingDetailsViewController = container.autoresolve(arguments: self,
                                                                                   listing,
                                                                                   isModalPresentation)
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen

        if arNavigationController != nil {
            arNavigationController?.pushViewController(controller, animated: true)
        } else {
            containerViewController?.present(navigationController, animated: true, completion: nil)
        }
    }

    private func presentListingDescription(_ descriptionString: String) {
        let controller: ListingDetailsDescriptionViewController = container.autoresolve(arguments: self,
                                                                                        descriptionString)
        listingDetailsNavigationController()?.pushViewController(controller, animated: true)
    }

    private func presentListingDetailsMap(with location: Location, propertyType: PropertyType?) {
        let controller: ListingLocationMapViewController = container.autoresolve(arguments: self,
                                                                                 location,
                                                                                 propertyType)

        listingDetailsNavigationController()?.pushViewController(controller, animated: true)
    }

    private func presentPhotoGalleryController(config: ListingDetailsModelConfig) {
        let controller: PhotoGalleryViewController = container.autoresolve(arguments: self, config)

        listingDetailsNavigationController()?.pushViewController(controller, animated: true)
    }

    private func presentPhotoGalleryExtendedController(photos: [PhotoType], index: Int) {
        let controller: PhotoGalleryExtendedViewController = container.autoresolve(arguments: self, photos, index)
        
        listingDetailsNavigationController()?.pushViewController(controller, animated: true)
    }

    private func presentListingsFilters(areaInfo: FetchListingsAreaInfo?, filtersModel: ListingFilterModel?) {
        let controller: ListingsFiltersViewController = container.autoresolve(arguments: self,
                                                                              areaInfo,
                                                                              filtersModel)
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen

        containerViewController?.present(navigationController, animated: true, completion: nil)
    }
    
    private func handle(_ event: SearchEvent) {
        switch event {
        case .didRequestAugmentedReality:
            let arContainerController = arContainerViewController()
            let navigationController = UINavigationController(rootViewController: arContainerController)
            navigationController.modalPresentationStyle = .fullScreen

            arNavigationController = navigationController
            containerViewController?.present(navigationController, animated: true, completion: nil)

        case .locationSearch(let searchTerm, let isCurrentLocationSearch):
            let controller: LocationSearchViewController = container.autoresolve(arguments: self,
                                                                                 searchTerm,
                                                                                 isCurrentLocationSearch)
            controller.modalPresentationStyle = .overCurrentContext
            controller.modalTransitionStyle = .crossDissolve

            containerViewController?.present(controller, animated: true, completion: nil)

        case .listingsFilters(let areaInfo, let filtersModel):
            presentListingsFilters(areaInfo: areaInfo, filtersModel: filtersModel)
        }
    }
    
    private func handle(_ event: ARModelEvent) {
        switch event {
        case .didRequestClosing:
            containerViewController?.dismiss(animated: true, completion: nil)
        }
    }

    private func handle(_ event: ListingDetailsEvent) {
        switch event {
        case .showDescription(let string):
            presentListingDescription(string)

        case .showMap(let location, let propertyType):
            presentListingDetailsMap(with: location, propertyType: propertyType)

        case .showPhotoGallery(let config):
            presentPhotoGalleryController(config: config)
        }
    }

    private func handle(_ event: LocationSearchEvent) {
        switch event {
        case .updateListings(let areaInfo, let placeInfo, let isCurrentLocation):
            searchDelegate?.updateListings(areaInfo: areaInfo,
                                           placeInfo: placeInfo,
                                           isCurrentLocation: isCurrentLocation)
            containerViewController?.dismiss(animated: true, completion: nil)
        }
    }

    private func handle(_ event: PhotoGalleryEvent) {
        switch event {
        case .showDetailedGallery(let photos, let index):
            presentPhotoGalleryExtendedController(photos: photos, index: index)
        }
    }

    private func handle(_ event: ListingDetailsPresentableEvent) {
        switch event {
        case .presentListingDetails(let listing):
            presentListingDetail(for: listing)
        }
    }

    private func handle(_ event: ListingDetailsDescriptionEvent) {
        switch event {
        case .back:
            listingDetailsNavigationController()?.popViewController(animated: true)
        }
    }

    private func handle(_ event: CreateListingCommonEvent) {
        switch event {
        case .pickPropertyType(let titles, let handler, let title, let startingIndex):
            presentPickerPopup(with: titles, updateHandler: handler, title: title, startingIndex: startingIndex)
        default:
            break
        }
    }

    private func handle(_ event: ListingsFiltersEvent) {
        switch event {
        case .applyFilters(let filters):
            searchDelegate?.updateListings(filters: filters)
        }
    }

    private func handle(_ event: SearchFlowEvent) {
        switch event {
        case .presentListingDetails(let listingID):
            procceedListingDetails(with: listingID)
        }
    }

    private func presentPickerPopup(
        with titles: [String],
        updateHandler: @escaping ((Int) -> Void),
        title: String,
        startingIndex: Int
    ) {
        guard let navigationController = containerViewController?.presentedViewController as? UINavigationController,
            let presentingView = navigationController.viewControllers.first?.view,
            let popupView = container.resolve(PickerPopupView.self, arguments: titles, title, startingIndex)
            else { return }

        let hideAction = { [unowned popupView] in
            popupView.hide()
        }

        popupView.setup(with: hideAction, selectionUpdated: updateHandler)
        popupView.show(in: presentingView)
    }

    private func listingDetailsNavigationController() -> UINavigationController? {
        if let rootNavigation = containerViewController as? UINavigationController,
            let targetNavigation = rootNavigation.presentedViewController as? UINavigationController {
            return targetNavigation
        }
        return nil
    }

    private func procceedListingDetails(with listingID: Int) {
        let listingService: ListingsService = container.autoresolve()
        listingService.getListingDetails(for: "\(listingID)") { [weak self] result in
            switch result {
            case .success(let listing):
                guard let listing = listing else { return }
                self?.presentListingDetail(for: listing)
            case .failure: break
            }
        }
    }

}
