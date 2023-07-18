//
//  CreateListingFlowAssembly.swift
//  Babilonia
//
//  Created by Denis on 5/31/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject
import Core

final class CreateListingFlowAssembly: Assembly {
    
    //swiftlint:disable:next function_body_length
    func assemble(container: Container) {
        assembleServices(container)
        
        container
            //swiftlint:disable:next line_length
            .register(CreateListingModel.self) { (resolver, parent: EventNode, steps: [CreateListingModel.Step], draftListing: Listing?, mode: ListingFillMode) in
                CreateListingModel(
                    parent: parent,
                    steps: steps,
                    draftListing: draftListing,
                    facilitiesService: resolver.autoresolve(),
                    listingsService: resolver.autoresolve(),
                    imagesService: resolver.autoresolve(),
                    mode: mode
                )
            }
            .inObjectScope(.transient)
        container
            .register(
                CreateListingViewController.self
                //swiftlint:disable:next line_length
            ) { (resolver, eventNode: EventNode, steps: [CreateListingModel.Step], draftListing: Listing?, mode: ListingFillMode) in
                CreateListingViewController(
                    viewModel: CreateListingViewModel(model: resolver.autoresolve(
                        arguments: eventNode, steps, draftListing, mode
                    ))
                )
            }
            .inObjectScope(.transient)
        
        container
            .register(PickerPopupView.self) { (_, titles: [String], title: String, startingIndex: Int) in
                PickerPopupView(itemTitles: titles, title: title, startingIndex: startingIndex)
            }
            .inObjectScope(.transient)
        
        container
            .register(
                CreateListingDescriptionModel.self
            ) { (_, parent: EventNode, handler: @escaping ((String) -> Void), text: String, count: Int) in
                return CreateListingDescriptionModel(
                    parent: parent,
                    textUpdateHandler: handler,
                    initialText: text,
                    maxSymbolsCount: count
                )
            }
            .inObjectScope(.transient)
        container
            .register(
                CreateListingDescriptionViewController.self
            ) { (resolver, parent: EventNode, handler: @escaping ((String) -> Void), text: String, count: Int) in
                CreateListingDescriptionViewController(
                    viewModel: CreateListingDescriptionViewModel(
                        model: resolver.autoresolve(arguments: parent, handler, text, count)
                    )
                )
            }
            .inObjectScope(.transient)
        
        container
            .autoregister(
                CreateListingAddressModel.self,
                arguments: EventNode.self, ((MapAddress) -> Void).self, (MapAddress?).self,
                initializer: CreateListingAddressModel.init
            )
            .inObjectScope(.transient)
        container
            .register(
                CreateListingAddressViewController.self
            ) { (resolver, parent: EventNode, handler: @escaping (MapAddress) -> Void, initial: MapAddress?) in
                let model: CreateListingAddressModel = resolver.autoresolve(arguments: parent, handler, initial)
                return CreateListingAddressViewController(viewModel: CreateListingAddressViewModel(model: model))
            }
            .inObjectScope(.transient)
        
        container
            //swiftlint:disable:next line_length
            .register(CreateListingPreviewModel.self) { (resolver, parent: EventNode, listing: Listing, photos: [CreateListingPhoto], mode: ListingFillMode) in
                CreateListingPreviewModel(
                    parent: parent,
                    listing: listing,
                    photos: photos,
                    listingsService: resolver.autoresolve(),
                    configsService: resolver.autoresolve(),
                    mode: mode
                )
            }
            .inObjectScope(.transient)
        container
            .register(
                CreateListingPreviewViewController.self
                //swiftlint:disable:next line_length
            ) { (resolver, eventNode: EventNode, listing: Listing, photos: [CreateListingPhoto], mode: ListingFillMode) in
                CreateListingPreviewViewController(
                    viewModel: CreateListingPreviewViewModel(model: resolver.autoresolve(
                        arguments: eventNode, listing, photos, mode
                    ))
                )
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
    
    private func assembleServices(_ container: Container) {
        container
            .autoregister(LocationManager.self, initializer: LocationManager.init)
            .inObjectScope(.transient)
        container
            .autoregister(FacilitiesService.self, initializer: FacilitiesService.init)
            .inObjectScope(.container)
        container
            .autoregister(ListingsService.self, initializer: ListingsService.init)
            .inObjectScope(.container)
        container
            .autoregister(ImagesService.self, initializer: ImagesService.init)
            .inObjectScope(.container)
    }
    
}
