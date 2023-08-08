//
//  CommonListingDetailsViewController.swift
//  Babilonia
//
//  Created by Alya Filon  on 24.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Core
import FBSDKCoreKit

final class CommonListingDetailsViewController: NiblessViewController, AlertApplicable, SpinnerApplicable {

    let alert = ApplicationAlert()
    let spinner = AppSpinner()
    private let containerView: UIView = .init()
    private let backButton: UIButton = .init()
    private let likeButton: UIButton = .init()
    private let editButton: UIButton = .init()
    private let titleLabel: UILabel = .init()
    private let statusLabel: UILabel = .init()
    private let gradientView: UIView = .init()
    private let contactButton: UIButton = .init()
    private let whatsAppButton: UIButton = .init()
    private let shareButton: UIButton = .init()
    private let publishButton = ConfirmationButton()
    private var gradientLayer: CALayer!
    
    private let viewModel: CommonListingDetailsViewModel
    private var litingDetailsViewController: ListingDetailsViewController?
    private var composerManager: ExternalDataComposerManager!

    private var stateOnAppearDidShow = false

    init(viewModel: CommonListingDetailsViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView() 
        setupBindings()
        viewModel.getListingDetails()
//        viewModel.triggerView()
        composerManager = ExternalDataComposerManager(controller: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)

        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let state = viewModel.stateOnAppear, !stateOnAppearDidShow {
            handle(state)
            stateOnAppearDidShow = true
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard gradientLayer == nil, gradientView.frame != .zero else { return }
        gradientLayer = gradientView.layer.addGradientLayer(
            colors: [
                Asset.Colors.vulcan.color.withAlphaComponent(0.8).cgColor,
                UIColor.clear.cgColor
            ],
            locations: [0.0, 1.0]
        )
    }
    
    // MARK: - Bindings
    
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

        viewModel.showWarning
            .subscribe(onNext: { [weak self] _ in
                self?.presentWarning()
            })
            .disposed(by: disposeBag)
            
        viewModel.listingUpdated
            .drive(onNext: { [weak self] in
                self?.setupButtonIfNeeded()
                self?.setupListingDetailsView()
            })
            .disposed(by: disposeBag)

        viewModel.listingIsFavoriteObservable
            .subscribe(onNext: { [weak self] isFavorite in
                self?.likeButton.isSelected = isFavorite
            })
            .disposed(by: disposeBag)

        setupViewBindings()
    }

    private func setupViewBindings() {
        editButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showEditOptionsPopup()
            })
            .disposed(by: disposeBag)

        publishButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                if self?.viewModel.isListingNotPurchased == true {
                    self?.viewModel.publishListing()
                } else {
                    self?.presentPublishActionAlert(isPublish: true)
                }
            })
            .disposed(by: disposeBag)

        contactButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.showPhoneCallAlert()
            })
            .disposed(by: disposeBag)
        
        whatsAppButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.showWhatsappContact()
            })
            .disposed(by: disposeBag)

        backButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                if self?.viewModel.isModalPresentation == true {
                    self?.dismiss(animated: true, completion: nil)
                } else {
                    self?.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)

        likeButton.rx.controlEvent(.touchUpInside)
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                if self?.likeButton.isSelected == true {
                    self?.viewModel.removeListingFromFavorites()
                } else {
                    self?.viewModel.addListingToFavorites()
                }
            })
            .disposed(by: disposeBag)
        
        shareButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.shareListingDetail()
            })
            .disposed(by: disposeBag)
    }

    private func setupView() {
        view.backgroundColor = .white
        
        setupNavigationBarViews()
        setupButtonIfNeeded()
    }

    private func setupNavigationBarViews() {
        backButton.setImage(Asset.Common.backIcon.image.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.tintColor = .white
        backButton.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 12.0, bottom: 10.0, right: 12.0)

        view.addSubview(backButton)
        backButton.layout {
            $0.top == view.safeAreaLayoutGuide.topAnchor
            $0.leading == view.leadingAnchor
        }
        
        if viewModel.viewState == .owned && !viewModel.shouldHideEditAction {
            editButton.setImage(Asset.Profile.edit.image.withRenderingMode(.alwaysTemplate), for: .normal)
            editButton.tintColor = .white
            editButton.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 12.0, bottom: 10.0, right: 12.0)
            view.addSubview(editButton)
            editButton.layout {
                $0.top == view.safeAreaLayoutGuide.topAnchor
                $0.trailing == view.trailingAnchor
            }
        } else if !viewModel.shouldHideEditAction {
            likeButton.setImage(Asset.ListingPreview.likeEmpty.image, for: .normal)
            likeButton.setImage(Asset.ListingPreview.likeFilled.image, for: .selected)
            likeButton.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 12.0, bottom: 10.0, right: 12.0)
            view.addSubview(likeButton)
            likeButton.layout {
                $0.top == view.safeAreaLayoutGuide.topAnchor
                $0.trailing.equal(to: view.trailingAnchor)
            }
        }
        
        shareButton.setImage(Asset.Common.shareIcon.image, for: .normal)
        shareButton.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 12.0, bottom: 10.0, right: 12.0)
        view.addSubview(shareButton)
        shareButton.layout {
            $0.top.equal(to: view.safeAreaLayoutGuide.topAnchor, offsetBy: 45)
            $0.trailing.equal(to: view.trailingAnchor)
        }
        shareButton.isHidden = !viewModel.isListingPublished

        titleLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 16.0)
        titleLabel.textColor = .white
        titleLabel.text = viewModel.title

        view.addSubview(titleLabel)
        titleLabel.layout {
            $0.leading >= backButton.trailingAnchor
            $0.top == view.safeAreaLayoutGuide.topAnchor + 11.0
            $0.height == 22.0
            $0.centerX == view.centerXAnchor
        }

        statusLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 12.0)
        statusLabel.textColor = .white
        statusLabel.text = viewModel.statusTitle

        view.addSubview(statusLabel)
        statusLabel.layout {
            $0.top.equal(to: titleLabel.bottomAnchor)
            $0.height == 22.0
            $0.centerX == view.centerXAnchor
        }

        view.insertSubview(gradientView, belowSubview: backButton)
        gradientView.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.top == view.topAnchor
            $0.bottom == backButton.bottomAnchor
        }
    }

    private func setupButtonIfNeeded() {
        if viewModel.viewState == .default {
            setupContactButtonIfNeeded()
            setupWhatsappButtonIfNeeded()
        } else {
            setupPublishButton()
            publishButton.isHidden = viewModel.isListingPublished
        }
    }

    private func setupContactButtonIfNeeded() {
        let buttonView = UIView()
        buttonView.backgroundColor = Asset.Colors.mandy.color
        buttonView.layerCornerRadius = 28
        buttonView.makeShadow(Asset.Colors.brickRed.color.withAlphaComponent(0.3), opacity: 1)

        view.addSubview(buttonView)
        buttonView.layout {
            $0.leading == view.leadingAnchor + 16.0
            $0.trailing == view.trailingAnchor - 88.0
            $0.bottom == view.safeAreaLayoutGuide.bottomAnchor - 24.0
            $0.height == 56.0
        }

        let buttonTitleLabel = UILabel()
        buttonTitleLabel.text = L10n.ListingDetails.ContactButton.title.uppercased()
        buttonTitleLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 16.0)
        buttonTitleLabel.textAlignment = .center
        buttonTitleLabel.textColor = .white

        buttonView.addSubview(buttonTitleLabel)
        buttonTitleLabel.layout {
            $0.centerX.equal(to: buttonView.centerXAnchor)
            $0.top.equal(to: buttonView.topAnchor, offsetBy: 20)
        }

        let buttonDescriptionLabel = UILabel()
//        buttonDescriptionLabel.text = L10n.ListingDetails.ContactButton.description
//        buttonDescriptionLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 12)
//        buttonDescriptionLabel.textAlignment = .center
//        buttonDescriptionLabel.textColor = .white

        buttonView.addSubview(buttonDescriptionLabel)
        buttonDescriptionLabel.layout {
            $0.centerX.equal(to: buttonView.centerXAnchor)
            $0.top.equal(to: buttonTitleLabel.bottomAnchor, offsetBy: 1)
        }

        buttonView.addSubview(contactButton)
        contactButton.pinEdges(to: buttonView)
    }
    
    private func setupWhatsappButtonIfNeeded() {
        view.addSubview(whatsAppButton)
        whatsAppButton.layout {
            $0.trailing == view.trailingAnchor - 16
            $0.bottom == view.safeAreaLayoutGuide.bottomAnchor - 24
            $0.height == 56
            $0.width == 56
        }
        whatsAppButton.makeShadow(Asset.Colors.almostBlack.color.withAlphaComponent(0.3), opacity: 1)
        whatsAppButton.setImage(Asset.ListingDetails.iconWhatsapp.image, for: .normal)
    }

    private func setupPublishButton() {
        publishButton.setTitle(L10n.CreateListing.ListingPreview.Publish.title, for: .normal)
        publishButton.setTitleColor(.white, for: .normal)
        publishButton.titleLabel?.font = FontFamily.SamsungSharpSans.bold.font(size: 16.0)
        publishButton.isHidden = true

        view.addSubview(publishButton)
        publishButton.layout {
            $0.leading == view.leadingAnchor + 16.0
            $0.trailing == view.trailingAnchor - 16.0
            $0.bottom == view.safeAreaLayoutGuide.bottomAnchor - 24.0
            $0.height == 56.0
        }
    }

    private func setupListingDetailsView() {
        guard let listingDetailsViewModel = viewModel.listingDetailsViewModel else { return }

        if litingDetailsViewController != nil {
            litingDetailsViewController = nil
        }

        litingDetailsViewController = ListingDetailsViewController(viewModel: listingDetailsViewModel)
        litingDetailsViewController?.toggleMapViewTap = { [weak self] in
            self?.viewModel.openMap()
        }
        litingDetailsViewController?.togglePhotoGalleryTap = { [weak self] in
            self?.viewModel.openPhotoGallery()
        }

        view.insertSubview(containerView, belowSubview: gradientView)
        containerView.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
        }

        let detailsController = litingDetailsViewController!
        addChild(detailsController)
        containerView.addSubview(detailsController.view)
        detailsController.didMove(toParent: self)
        detailsController.view.layout {
            $0.leading == containerView.leadingAnchor
            $0.trailing == containerView.trailingAnchor
            $0.top == containerView.topAnchor
            $0.bottom == containerView.bottomAnchor
        }

        likeButton.isHidden = listingDetailsViewModel.isUserOwnedListing
    }

    private func showPhoneCallAlert() {
        AppEvents.logEvent(AppEvents.Name("Contactenme"))
        if self.viewModel.triggerContact() {
            let phone = viewModel.phoneNumber
            SystemAlert.present(on: self,
                                message: phone,
                                confirmTitle: L10n.ListingDetails.Call.actionsTitle,
                                confirm: { [weak self] in
                                    if self?.viewModel.triggerContact() ?? false {
                                        self?.composerManager.proceedPhone(phone)
                                    }
                                })
        }
    }

    private func showWhatsappContact() {
        AppEvents.logEvent(AppEvents.Name("Whatsapp"))
        if self.viewModel.triggerWhatsapp() {
            let phoneNumber = viewModel.phoneNumber
            let text = "Hola! Estoy muy interesado en tu propiedad publicada en Babilonia y me gustaría más información. \(Environment.default.webSiteURL ?? "")\(viewModel.listingURL)"
            let escapedString = text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

            let urlWhats = "whatsapp://send?phone=\(phoneNumber)&text=\(text)"
            if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                if let whatsappURL = URL(string: urlString) {
                    if UIApplication.shared.canOpenURL(whatsappURL) {
                        UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
                    } else {
                        let urlBase = "https://api.whatsapp.com"
                        let whatsappURL = URL(string: "\(urlBase)/send?phone=\(phoneNumber)&text=\(escapedString)")
                        print("whatsappURL = \(String(describing: whatsappURL))")
                        if UIApplication.shared.canOpenURL(whatsappURL!) {
                            UIApplication.shared.open(whatsappURL!, options: [:], completionHandler: nil)
                        } else {
                            print("Install Whatsapp")
                        }
                        
                    }
                }
            }
        }
    }
    
    private func shareListingDetail() {
        let text = L10n.Common.share
        let url = URL(string: "\(Environment.default.webSiteURL ?? "")\(viewModel.listingURL)")!
        let items: [Any] = [text, url]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.airDrop
        ]

        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func showEditOptionsPopup() {
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: L10n.EditListing.title, style: .default) { [weak self] _ in
            self?.viewModel.editListing()
        }
        alert.addAction(editAction)
        
        if viewModel.isListingPublished {
            let unpublishAction = UIAlertAction(title: L10n.MyListings.Options.Unpublish.title,
                                                style: .destructive) { [weak self] _ in
                self?.presentPublishActionAlert(isPublish: false)
            }
            alert.addAction(unpublishAction)
        } else {
            let publishAction = UIAlertAction(title: L10n.MyListings.Options.Publish.title,
                                              style: .default) { [weak self] _ in
                if self?.viewModel.isListingNotPurchased == true {
                    self?.viewModel.publishListing()
                } else {
                    self?.presentPublishActionAlert(isPublish: true)
                }
            }
            alert.addAction(publishAction)
        }

        alert.addAction(UIAlertAction(title: L10n.Buttons.Cancel.title, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func presentPublishActionAlert(isPublish: Bool) {
        if viewModel.role == .realtor && isPublish {
            presentWarning()
        } else {
            let title = isPublish ? nil : L10n.Popups.UnpublishListing.title
            let message = isPublish ?
                L10n.Popups.PublishListing.text :
                L10n.Popups.UnpublishListing.text
            let actionTitle = isPublish ? L10n.MyListings.Options.Publish.title : L10n.MyListings.Options.Unpublish.title

            SystemAlert.present(on: self,
                                title: title,
                                message: message,
                                confirmTitle: actionTitle,
                                confirm: { [weak self] in
                                    if isPublish {
                                        self?.viewModel.publishListing()
                                    } else {
                                        self?.viewModel.unpublishListing()
                                    }
                                  })
        }
    }
    
    private func presentWarning() {
        let message = L10n.Errors.actionMustBeDoneFromWeb
        SystemAlert.present(on: self,
                            message: message)
    }
}
