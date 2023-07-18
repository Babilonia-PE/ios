//
//  CreateListingFlowCoordinator.swift
//  Babilonia
//
//  Created by Denis on 5/31/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import Foundation
import Swinject
import Core

enum CreateListingFlowEvent: Event {
    case listingCreated
    case close(alertMessage: String?)
    case published(listing: Listing?, state: RequestState?)
}

enum ListingFillMode {
    case create, edit
}

final class CreateListingFlowCoordinator: EventNode, FlowCoordinator {
    
    weak var containerViewController: UIViewController?
    
    private let container: Container
    
    private let draftListing: Listing?
    private let mode: ListingFillMode
    
    init(container: Container, parent: EventNode, draftListing: Listing?, mode: ListingFillMode) {
        self.container = Container(parent: container) { (container: Container) in
            CreateListingFlowAssembly().assemble(container: container)
        }
        self.draftListing = draftListing
        self.mode = mode
        
        super.init(parent: parent)
        
        addHandlers()
    }
    
    @discardableResult
    func createFlow() -> UIViewController {
        return container.autoresolve(
            arguments: self, CreateListingModel.Step.allCases, draftListing, mode
        ) as CreateListingViewController
    }
    
    // MARK: - private
    
    private func addHandlers() {
        addHandler { [weak self] (event: CreateListingEvent) in
            self?.handle(event)
        }
        addHandler { [weak self] (event: CreateListingCommonEvent) in
            self?.handle(event)
        }
        addHandler { [weak self] (event: CreateListingDescriptionEvent) in
            self?.handle(event)
        }
        addHandler { [weak self] (event: CreateListingAddressEvent) in
            self?.handle(event)
        }
        addHandler { [weak self] (event: CreateListingPreviewEvent) in
            self?.handle(event)
        }
        addHandler { [weak self] (event: ListingDetailsEvent) in
            self?.handle(event)
        }
        addHandler { [weak self] (event: ListingDetailsDescriptionEvent) in
            self?.handle(event)
        }
    }
    
    private func handle(_ event: CreateListingEvent) {
        switch event {
        case .finishCreation(let listing, let photos):
            presentPreview(listing: listing, photos: photos)
        case .close(let alertMessage):
            raise(event: CreateListingFlowEvent.close(alertMessage: alertMessage))
        }
    }
    
    private func handle(_ event: CreateListingCommonEvent) {
        switch event {
        case .pickPropertyType(let titles, let handler, let title, let startingIndex):
            presentPickerPopup(with: titles, updateHandler: handler, title: title, startingIndex: startingIndex)
        case .editDescription(let updateHandler, let initialText, let maxSymbolsCount):
            presentEditDescription(
                updateHandler: updateHandler,
                initialText: initialText,
                maxSymbolsCount: maxSymbolsCount
            )
        case .selectAddress(let updateHandler, let initialAddress):
            presentSelectAddress(updateHandler: updateHandler, initialAddress: initialAddress)
        }
    }
    
    private func handle(_ event: CreateListingDescriptionEvent) {
        switch event {
        case .back:
            navigationController?.popViewController(animated: true)
        case .done:
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func handle(_ event: CreateListingAddressEvent) {
        switch event {
        case .close:
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
        
    private func handle(_ event: CreateListingPreviewEvent) {
        switch event {
        case .listingCreated(let listing):
            presentPaymentFlow(listing: listing)
        case .back:
            navigationController?.popViewController(animated: true)
        case .closeFlow:
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func handle(_ event: ListingDetailsEvent) {
        switch event {
        case .showDescription(let string):
            presentListingDescription(string)

        case .showMap:
            break

        case .showPhotoGallery:
            break
        }
    }
    
    private func handle(_ event: ListingDetailsDescriptionEvent) {
        switch event {
        case .back:
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func presentPickerPopup(
        with titles: [String],
        updateHandler: @escaping ((Int) -> Void),
        title: String,
        startingIndex: Int
    ) {
        guard
            let presentingView = containerViewController?.view,
            let popupView = container.resolve(PickerPopupView.self, arguments: titles, title, startingIndex)
            else { return }
        
        let hideAction = { [unowned popupView] in
            popupView.hide()
        }
        
        popupView.setup(with: hideAction, selectionUpdated: updateHandler)
        
        popupView.show(in: presentingView)
    }
    
    private func presentEditDescription(
        updateHandler: @escaping ((String) -> Void),
        initialText: String,
        maxSymbolsCount: Int
    ) {
        let controller: CreateListingDescriptionViewController = container.autoresolve(
            arguments: self, updateHandler, initialText, maxSymbolsCount
        )
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func presentSelectAddress(updateHandler: @escaping (MapAddress) -> Void, initialAddress: MapAddress?) {
        let controller: CreateListingAddressViewController = container.autoresolve(
            arguments: self, updateHandler, initialAddress
        )
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    private func presentPreview(listing: Listing, photos: [CreateListingPhoto]) {
        let controller: CreateListingPreviewViewController = container.autoresolve(
            arguments: self, listing, photos, mode
        )
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func presentListingDescription(_ descriptionString: String) {
        let controller: ListingDetailsDescriptionViewController = container.autoresolve(
            arguments: self, descriptionString
        )
        navigationController?.pushViewController(controller, animated: true)
    }

    private func presentPaymentFlow(listing: Listing?) {
        let controller = PaymentsFlowCoordinator(container: container, parent: self, listing: listing).createFlow()

        containerViewController?.navigationItem.backButtonTitle = ""
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
