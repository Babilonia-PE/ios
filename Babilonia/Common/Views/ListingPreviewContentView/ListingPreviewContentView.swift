//
//  ListingPreviewContentView.swift
//  Babilonia
//
//  Created by Vitaly Chernysh on 7/19/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingPreviewContentView: UIView {
    
    var didToggleFavorite: ((Bool) -> Void)?
    var didToggleDetails: ((ListingPreviewContentView) -> Void)?
    var didToggleNavigation: ((ListingPreviewContentView) -> Void)?
    var didToggleContact: ((ListingPreviewContentView) -> Void)?
    var didTogglePhotoTap: (() -> Void)?

    var listingID: Int {
        viewModel.listingID
    }
    
    private var photosView: ListingDetailsPhotosView!
    private var listingTypeView: ListingTypeView!
    private var likeButton: UIButton!
    private var priceLabel: UILabel!
    private var pricePerSquareMeterLabel: UILabel!
    private var addressLabel: UILabel!
    private var bottomContainer: UIView!
    private var detailsButton: UIButton!
    private var navigationButton: UIButton!
    private var navigationButtonTitleLabel: UILabel!
    private var navigationButtonImageView: UIImageView!
    private let contactButton: ConfirmationButton = .init()
    private var inlinePropertiesView: InlinePropertiesView!
    private let paymentPlanBackground: UIView = .init()
    private let paymentPlanImageView: UIImageView = .init()
    private var viewModel: ListingPreviewViewModel!
    private var disposeBag = DisposeBag()
    private var isSelectedLikeButton = false
    
    // MARK: - lifecycle
    
    init() {
        super.init(frame: .zero)
        
        layout()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with viewModel: ListingPreviewViewModel) {
        self.viewModel = viewModel
        
        listingTypeView.setup(with: viewModel.listingTypeViewModel)
        photosView.setup(photos: viewModel.photos)
        inlinePropertiesView.setup(with: viewModel.listingViewModel.inlinePropertiesInfo)
        addressLabel.text = viewModel.listingViewModel.fullAddress
        bottomContainer.isHidden = viewModel.isBottomButtonsHidden
        likeButton.isHidden = viewModel.listingViewModel.isUserOwnedListing

        isSelectedLikeButton = viewModel.listingViewModel.isMarkedFavorite
        toggleLikeButton()
        
        setupBinding(with: viewModel.listingViewModel)

        if let paymentPlanViewModel = viewModel.listingViewModel.paymentPlanViewModel {
            setupPaymentPlanView(paymentPlanViewModel: paymentPlanViewModel)
        }

        photosView.togglePhotoGalleryTap = { [weak self] in
            self?.didTogglePhotoTap?()
        }
    }

    func toggleLikeButton() {
        let image = isSelectedLikeButton ? Asset.ListingPreview.likeFilled.image : Asset.ListingPreview.likeEmpty.image
        likeButton.setImage(image, for: .normal)
    }

    func showContactButton() {
        contactButton.isHidden = false
    }
    
    // MARK: - private

    private func setupPaymentPlanView(paymentPlanViewModel: ListingPaymentPlanViewModel) {
        paymentPlanBackground.isHidden = paymentPlanViewModel.isStandardPlan
        paymentPlanBackground.backgroundColor = paymentPlanViewModel.backgroundColor
        paymentPlanImageView.image = paymentPlanViewModel.icon
    }

    @objc
    private func showDetails() {
        didToggleDetails?(self)
    }

    @objc
    private func likeButtonDidSelect() {
        self.isSelectedLikeButton = !self.isSelectedLikeButton
        self.didToggleFavorite?(self.isSelectedLikeButton)
    }

    // swiftlint:disable function_body_length
    private func layout() {
        photosView = ListingDetailsPhotosView()
        addSubview(photosView)
        photosView.layout {
            $0.top == topAnchor
            $0.height == 168.0
            $0.leading == leadingAnchor + 16.0
            $0.trailing == trailingAnchor - 16.0
        }
        
        listingTypeView = ListingTypeView()
        photosView.addSubview(listingTypeView)
        listingTypeView.layout {
            $0.leading == photosView.leadingAnchor + 8.0
            $0.top == photosView.topAnchor + 8.0
            $0.height.equal(to: 32)
        }

        likeButton = UIButton()
        photosView.addSubview(likeButton)
        likeButton.layout {
            $0.top == photosView.topAnchor + 8.0
            $0.trailing == photosView.trailingAnchor - 8.0
            $0.height == 24.0
            $0.width == 24.0
        }

        let detailsTap = UITapGestureRecognizer(target: self, action: #selector(showDetails))
        addGestureRecognizer(detailsTap)

        priceLabel = UILabel()
        addSubview(priceLabel)
        priceLabel.layout {
            $0.top == photosView.bottomAnchor + 11.0
            $0.leading == photosView.leadingAnchor
        }
        
        pricePerSquareMeterLabel = UILabel()
        addSubview(pricePerSquareMeterLabel)
        pricePerSquareMeterLabel.layout {
            $0.top == photosView.bottomAnchor + 22.0
            $0.leading == priceLabel.trailingAnchor + 11.0
        }
        
        inlinePropertiesView = InlinePropertiesView()
        addSubview(inlinePropertiesView)
        inlinePropertiesView.layout {
            $0.top == photosView.bottomAnchor + 20.0
            $0.trailing == trailingAnchor - 16.0
            $0.leading >= pricePerSquareMeterLabel.trailingAnchor + 16.0
        }

        paymentPlanBackground.layerCornerRadius = 4

        addSubview(paymentPlanBackground)
        paymentPlanBackground.layout {
            $0.top.equal(to: inlinePropertiesView.bottomAnchor, offsetBy: 9)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.height.equal(to: 20)
            $0.width.equal(to: 20)
        }

        paymentPlanImageView.contentMode = .scaleAspectFit
        paymentPlanBackground.addSubview(paymentPlanImageView)
        paymentPlanImageView.pinEdges(to: paymentPlanBackground)

        addressLabel = UILabel()
        addSubview(addressLabel)
        addressLabel.layout {
            $0.top == priceLabel.bottomAnchor + 10.0
            $0.leading == photosView.leadingAnchor
            $0.trailing.equal(to: paymentPlanBackground.leadingAnchor, offsetBy: -5)
        }
        
        bottomContainer = UIView()
        addSubview(bottomContainer)
        bottomContainer.layout {
            $0.top == addressLabel.bottomAnchor + 20.0
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
        }

        detailsButton = UIButton()
        bottomContainer.addSubview(detailsButton)
        detailsButton.layout {
            $0.top == bottomContainer.topAnchor
            $0.leading == bottomContainer.leadingAnchor + 16.0
            $0.height == 40.0
            $0.width == 160.0
        }
        
        navigationButton = UIButton()
        bottomContainer.addSubview(navigationButton)
        navigationButton.layout {
            $0.trailing == bottomContainer.trailingAnchor - 16.0
            $0.top == bottomContainer.topAnchor
            $0.height == 40.0
            $0.width == 160.0
            $0.bottom == bottomContainer.bottomAnchor
        }
        
        navigationButtonImageView = UIImageView()
        navigationButtonTitleLabel = UILabel()

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 7.0
        
        stackView.addArrangedSubview(navigationButtonImageView)
        stackView.addArrangedSubview(navigationButtonTitleLabel)
        
        navigationButtonImageView.isUserInteractionEnabled = false
        navigationButtonTitleLabel.isUserInteractionEnabled = false
        stackView.isUserInteractionEnabled = false

        navigationButtonImageView.layout {
            $0.width == 21.6
            $0.height == 21.0
        }
        
        navigationButton.addSubview(stackView)
        
        stackView.layout {
            $0.centerX == navigationButton.centerXAnchor
            $0.centerY == navigationButton.centerYAnchor
        }

        contactButton.setTitle(L10n.ListingDetails.ContactButton.title.uppercased(), for: .normal)
        contactButton.titleLabel?.font = FontFamily.SamsungSharpSans.bold.font(size: 12)
        contactButton.setTitleColor(.white, for: .normal)
        contactButton.isHidden = true

        bottomContainer.addSubview(contactButton)
        contactButton.layout {
            $0.centerY.equal(to: navigationButton.centerYAnchor)
            $0.centerX.equal(to: navigationButton.centerXAnchor)
            $0.height.equal(to: 40.0)
            $0.width.equal(to: 160.0)
        }
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        photosView.addCornerRadius(5.0)
        
        priceLabel.textColor = Asset.Colors.vulcan.color
        priceLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 20.0)
        
        pricePerSquareMeterLabel.textColor = Asset.Colors.osloGray.color
        pricePerSquareMeterLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 12.0)
        
        addressLabel.textColor = Asset.Colors.trout.color
        addressLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12.0)

        likeButton.addTarget(self, action: #selector(likeButtonDidSelect), for: .touchUpInside)

        [detailsButton, navigationButton].forEach { button in
            button?.addCornerRadius(20.0)
            button?.backgroundColor = .clear
            button?.layer.borderWidth = 1.0
            button?.layer.borderColor = Asset.Colors.pumice.color.cgColor
        }
        
        detailsButton.setAttributedTitle(
            L10n.ListingPreview.ShowDetails.title.toAttributed(
                with: FontFamily.SamsungSharpSans.bold.font(size: 12.0),
                color: Asset.Colors.vulcan.color,
                kern: 1.0
            ),
            for: .normal
        )
        
        navigationButtonImageView.image = Asset.ListingPreview.navigationButton.image
        navigationButtonTitleLabel.attributedText = L10n.ListingPreview.Navigate.title.toAttributed(
            with: FontFamily.SamsungSharpSans.bold.font(size: 12.0),
            color: Asset.Colors.hippieBlue.color,
            kern: 1.0
        )
    }
    
    private func setupBinding(with viewModel: ListingViewModel) {
        detailsButton?.rx.tap
            .doOnNext { [weak self] in
                guard let self = self else { return }
                
                self.didToggleDetails?(self)
            }.disposed(by: disposeBag)
        
        navigationButton?.rx.tap
            .doOnNext { [weak self] in
                guard let self = self else { return }
            
                self.didToggleNavigation?(self)
            }.disposed(by: disposeBag)

        contactButton.rx.tap
            .doOnNext { [weak self] in
                guard let self = self else { return }

                self.didToggleContact?(self)
            }.disposed(by: disposeBag)
        
        viewModel.priceUpdated
            .drive(onNext: { [weak priceLabel] price in
                priceLabel?.text = price
            })
            .disposed(by: disposeBag)
        
        viewModel.pricePerSquareMeterUpdated
            .drive(onNext: { [weak pricePerSquareMeterLabel] pricePerSquare in
                pricePerSquareMeterLabel?.text = pricePerSquare
            })
            .disposed(by: disposeBag)
    }

}
