//
//  SearchFlowAssembly.swift
//  Babilonia
//
//  Created by Denis on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject
import Core

final class SearchFlowAssembly: Assembly {
    
    func assemble(container: Container) {
        assembleServices(container)
        
        container
            .autoregister(ARContainerModel.self, argument: EventNode.self, initializer: ARContainerModel.init)
            .inObjectScope(.transient)
        container
            .register(ARContainerViewController.self) { (resolver, eventNode: EventNode) in
                ARContainerViewController(
                    viewModel: ARContainerViewModel(model: resolver.autoresolve(argument: eventNode))
                )
            }
            .inObjectScope(.transient)

        assembleLocationSearch(container)
        assembleListingDetails(container)
        assembleListingsFilters(container)
    }

    // MARK: - Location search

    private func assembleLocationSearch(_ container: Container) {
        container
            //swiftlint:disable:next line_length
            .register(LocationSearchViewController.self) { (resolver, eventNode: EventNode, searchTerm: String, isCurrentLocationSearch: Bool) in
                let model = LocationSearchModel(parent: eventNode,
                                                searchTerm: searchTerm,
                                                locationManager: resolver.autoresolve(),
                                                userService: container.autoresolve(),
                                                isCurrentLocationSearch: isCurrentLocationSearch)
                let viewModel = LocationSearchViewModel(model: model)
                let controller = LocationSearchViewController(viewModel: viewModel)

                return controller
            }
            .inObjectScope(.transient)
    }

    // MARK: - Listing details

    private func assembleListingDetails(_ container: Container) {
        //swiftlint:disable line_length
        container
            .register(CommonListingDetailsViewController.self) { (resolver, eventNode: EventNode, listing: Listing, isModalPresentation: Bool) in
                //swiftlint:enable line_length
                let model = CommonListingDetailsModel(parent: eventNode,
                                                      listing: listing,
                                                      listingsService: resolver.autoresolve(),
                                                      configsService: container.autoresolve(),
                                                      userService: container.autoresolve(),
                                                      isModalPresentation: isModalPresentation)
                let viewModel = CommonListingDetailsViewModel(model: model)
                let controller = CommonListingDetailsViewController(viewModel: viewModel)

                return controller
            }
            .inObjectScope(.transient)

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

    // MARK: - Filters

    private func assembleListingsFilters(_ container: Container) {
        //swiftlint:disable line_length
        container
            .register(ListingsFiltersViewController.self) { (resolver, eventNode: EventNode, areaInfo: FetchListingsAreaInfo?, filtersModel: ListingFilterModel?) in
                //swiftlint:enable line_length
                let model = ListingsFiltersModel(parent: eventNode,
                                                 listingsService: resolver.autoresolve(),
                                                 facilitiesService: resolver.autoresolve(),
                                                 areaInfo: areaInfo,
                                                 filtersModel: filtersModel)
                let viewModel = ListingsFiltersViewModel(model: model)
                let controller = ListingsFiltersViewController(viewModel: viewModel)

                return controller
            }
            .inObjectScope(.transient)

        container
            .register(PickerPopupView.self) { (_, titles: [String], title: String, startingIndex: Int) in
                PickerPopupView(itemTitles: titles, title: title, startingIndex: startingIndex)
            }
            .inObjectScope(.transient)
    }

    // MARK: - Services
    
    private func assembleServices(_ container: Container) {
        container
            .autoregister(ListingsService.self, initializer: ListingsService.init)
            .inObjectScope(.container)

        container
            .autoregister(FacilitiesService.self, initializer: FacilitiesService.init)
            .inObjectScope(.container)
        
        container
            .autoregister(LocationManager.self, initializer: LocationManager.init)
            .inObjectScope(.container)

        container
            .autoregister(UserService.self, initializer: UserService.init)
            .inObjectScope(.container)
    }
    
}
