//
//  MyListingsFlowAssembly.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 6/26/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject
import Core

final class MyListingsFlowAssembly: Assembly {
    
    func assemble(container: Container) {
        assembleServices(container)
        assemblePhotoGallery(container)
        assembleListingMap(container)
        
        container.autoregister(MyListingsModel.self, argument: EventNode.self, initializer: MyListingsModel.init)
            .inObjectScope(.transient)

        container
            //swiftlint:disable:next line_length
            .register(CreateListingFlowCoordinator.self) { (_, parent: EventNode, container: Container, draftListing: Listing?, mode: ListingFillMode) in
                CreateListingFlowCoordinator(
                    container: container,
                    parent: parent,
                    draftListing: draftListing,
                    mode: mode
                )
            }
            .inObjectScope(.transient)

        container
            //swiftlint:disable:next line_length
            .register(CommonListingDetailsViewController.self) { (resolver, eventNode: EventNode, listing: Listing, state: RequestState?) in
                let model = CommonListingDetailsModel(parent: eventNode,
                                                      listing: listing,
                                                      listingsService: resolver.autoresolve(),
                                                      configsService: container.autoresolve(),
                                                      userService: container.autoresolve(),
                                                      viewState: .owned,
                                                      stateOnAppear: state)
                let viewModel = CommonListingDetailsViewModel(model: model)
                let controller = CommonListingDetailsViewController(viewModel: viewModel)

                return controller
            }
            .inObjectScope(.transient)

        container
            .autoregister(
                ListingDetailsDescriptionModel.self,
                arguments: EventNode.self, String.self,
                initializer: ListingDetailsDescriptionModel.init
            )
            .inObjectScope(.transient)
        container
            .register(
                ListingDetailsDescriptionViewController.self
            ) { (resolver, eventNode: EventNode, descriptionString: String) in
                ListingDetailsDescriptionViewController(
                    model: resolver.autoresolve(arguments: eventNode, descriptionString)
                )
            }
            .inObjectScope(.transient)
    }

    private func assemblePhotoGallery(_ container: Container) {
        container
            //swiftlint:disable:next line_length
            .register(PhotoGalleryExtendedViewController.self) { (_, eventNode: EventNode, photos: [PhotoType], index: Int) in
                let model = PhotoGalleryExtendedModel(parent: eventNode, photos: photos, index: index)
                let viewModel = PhotoGalleryExtendedViewModel(model: model)
                let controller = PhotoGalleryExtendedViewController(viewModel: viewModel)

                return controller
            }
            .inObjectScope(.transient)

        container
            .register(PhotoGalleryViewController.self) { (_, eventNode: EventNode, config: ListingDetailsModelConfig) in
                let model = PhotoGalleryModel(parent: eventNode, config: config)
                let viewModel = PhotoGalleryViewModel(model: model)
                let controller = PhotoGalleryViewController(viewModel: viewModel)

                return controller
            }
            .inObjectScope(.transient)
    }

    private func assembleListingMap(_ container: Container) {
        //swiftlint:disable line_length
        container
            .register(ListingLocationMapViewController.self) { (resolver, eventNode: EventNode, location: Location, propertyType: PropertyType?) in
                //swiftlint:enable line_length
                let model = ListingLocationMapModel(parent: eventNode,
                                                    location: location,
                                                    propertyType: propertyType,
                                                    locationManager: resolver.autoresolve())
                let viewModel = ListingLocationMapViewModel(model: model)
                let controller = ListingLocationMapViewController(viewModel: viewModel)

                return controller
            }
            .inObjectScope(.transient)
    }
    
    private func assembleServices(_ container: Container) {
        container
            .autoregister(ListingsService.self, initializer: ListingsService.init)
            .inObjectScope(.container)
        container
            .autoregister(UserService.self, initializer: UserService.init)
            .inObjectScope(.container)
        container
            .autoregister(LocationManager.self, initializer: LocationManager.init)
            .inObjectScope(.container)
    }
    
}
