//
//  FavoritesFlowCoordinator.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject
import Core

final class FavoritesFlowCoordinator: EventNode, FlowCoordinator {
    
    weak var containerViewController: UIViewController?
    var listingDetailsNavigationController: UINavigationController?
    
    private let container: Container
    
    init(container: Container, parent: EventNode) {
        self.container = Container(parent: container) { (container: Container) in
            FavoritesFlowAssembly().assemble(container: container)
        }
        
        super.init(parent: parent)

        addHandler { [weak self] (event: ListingDetailsPresentableEvent) in self?.handle(event) }
        addHandler { [weak self] (event: ListingDetailsEvent) in self?.handle(event) }
        addHandler { [weak self] (event: ListingDetailsDescriptionEvent) in self?.handle(event) }
        addHandler { [weak self] (event: PhotoGalleryEvent) in self?.handle(event) }
    }
    
    @discardableResult
    func createFlow() -> UIViewController {
        return container.autoresolve(argument: self) as FavoritesViewController
    }

    private func handle(_ event: ListingDetailsPresentableEvent) {
        switch event {
        case .presentListingDetails(let listing):
            presentListingDetail(for: listing)
        }
    }

    private func presentListingDetail(for listing: Listing) {
        let controller: CommonListingDetailsViewController = container.autoresolve(arguments: self, listing)
        listingDetailsNavigationController = UINavigationController(rootViewController: controller)
        listingDetailsNavigationController?.modalPresentationStyle = .fullScreen

        containerViewController?.present(listingDetailsNavigationController!, animated: true, completion: nil)
    }

    private func presentListingDescription(_ descriptionString: String) {
        let controller: ListingDetailsDescriptionViewController = container.autoresolve(arguments: self,
                                                                                        descriptionString)
        listingDetailsNavigationController?.pushViewController(controller, animated: true)
    }

    private func presentListingDetailsMap(with location: Location, propertyType: PropertyType?) {
        let controller: ListingLocationMapViewController = container.autoresolve(arguments: self,
                                                                                 location,
                                                                                 propertyType)

        listingDetailsNavigationController?.pushViewController(controller, animated: true)
    }

    private func presentPhotoGalleryController(config: ListingDetailsModelConfig) {
        let controller: PhotoGalleryViewController = container.autoresolve(arguments: self, config)

        listingDetailsNavigationController?.pushViewController(controller, animated: true)
    }

    private func presentPhotoGalleryExtendedController(photos: [PhotoType], index: Int) {
        let controller: PhotoGalleryExtendedViewController = container.autoresolve(arguments: self, photos, index)

        listingDetailsNavigationController?.pushViewController(controller, animated: true)
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

    private func handle(_ event: ListingDetailsDescriptionEvent) {
        switch event {
        case .back:
            listingDetailsNavigationController?.popViewController(animated: true)
        }
    }

    private func handle(_ event: PhotoGalleryEvent) {
        switch event {
        case .showDetailedGallery(let photos, let index):
            presentPhotoGalleryExtendedController(photos: photos, index: index)
        }
    }
    
}
