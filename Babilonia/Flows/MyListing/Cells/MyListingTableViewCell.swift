//
//  MyListingTableViewCell.swift
//  Babilonia
//
//  Created by Anna Sahaidak on 6/27/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MyListingTableViewCell: UITableViewCell {
    
    var optionsSelected: (() -> Void)?
    
    private var containerView: UIView!
    private var primaryImageView: UIImageView!
    private let planContentView: UIView = .init()
    private let planIconImageView: UIImageView = .init()
    private let publishedDateLabel: UILabel = .init()
    private var daysLeftView: UIView = .init()
    private var daysLeftLabel: UILabel = .init()
    private var typeView: UIView!
    private var typeIconImageView: UIImageView!
    private var propertyTypeLabel: UILabel!
    private var typeTitleLabel: UILabel!
    private var statusView: UIView!
    private var statusLabel: UILabel!
    private var moreButton: UIButton!
    private var priceLabel: UILabel!
    private var addressLabel: UILabel!
    private var inlinePropertiesView: InlinePropertiesView!
    private let statisticsView: ListingStatisticsView = .init()

    private var planIconViewWidthConstraint: NSLayoutConstraint?
    private var publishDateLeadingConstraint: NSLayoutConstraint?
    
    private var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        layout()
        setupStatusLayout()
        setupPlanView()
        setupStackView()
        setupViews()
        setupBindings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        clear()
    }
    
    func setup(with listingViewModel: ListingViewModel) {
        if let imageUrl = URL(string: listingViewModel.imagePath ?? "") {
            primaryImageView.setImage(with: imageUrl, placeholder: Asset.MyListings.myListingsDraft.image)
        }
        
        if listingViewModel.listingTypeSettings.title != nil && listingViewModel.propertyTypeSettings.title != nil {
            typeView.isHidden = false
            typeView.backgroundColor = listingViewModel.listingTypeSettings.color?
                .withAlphaComponent(0.8)
            typeTitleLabel.text = listingViewModel.listingTypeSettings.title
            typeIconImageView.image = listingViewModel.propertyTypeSettings.icon
            propertyTypeLabel.text = listingViewModel.propertyTypeSettings.title
        } else {
            typeView.isHidden = true
        }
        
        statusView.backgroundColor = listingViewModel.listingStatusColor
        statusLabel.text = listingViewModel.listingStatusTitleSettings.title
        statusLabel.textColor = listingViewModel.listingStatusTitleSettings.textColor
        
        listingViewModel.priceUpdated
            .drive(onNext: { [weak self] price in
                self?.priceLabel.text = price
            })
            .disposed(by: disposeBag)

        addressLabel.text = listingViewModel.address
        
        inlinePropertiesView.setup(with: listingViewModel.inlinePropertiesInfo)
        statisticsView.applyStatistics(listingViewModel.statistics)

        if let paymentPlanViewModel = listingViewModel.paymentPlanViewModel {
            setupPlanViewModel(paymentPlanViewModel: paymentPlanViewModel,
                               createdAt: listingViewModel.createdAt)
        } else {
            publishedDateLabel.text = listingViewModel.createdAt
        }
    }
    
    // MARK: - private

    private func setupPlanViewModel(paymentPlanViewModel: ListingPaymentPlanViewModel,
                                    createdAt: String) {
        let shouldHidePlanContent = !paymentPlanViewModel.isPlanPurchased || paymentPlanViewModel.isStandardPlan

        planContentView.isHidden = shouldHidePlanContent
        planContentView.backgroundColor = paymentPlanViewModel.backgroundColor

        planIconImageView.image = paymentPlanViewModel.icon

        var publishDate: String?
        if paymentPlanViewModel.isListingExpired {
            publishDate = createdAt
        } else {
            publishDate = paymentPlanViewModel.purchaseDate.isEmpty ? createdAt : paymentPlanViewModel.purchaseDate
        }
        publishedDateLabel.text = publishDate

        let planIconWidth: CGFloat = shouldHidePlanContent ? 0 : 20
        let dateLeading: CGFloat = shouldHidePlanContent ? 0 : 8
        planIconViewWidthConstraint?.constant = planIconWidth
        publishDateLeadingConstraint?.constant = dateLeading

        setStatusViewAppearance(isExpired: paymentPlanViewModel.isListingExpired,
                                daysLeft: paymentPlanViewModel.daysLeft)
    }

    private func setStatusViewAppearance(isExpired: Bool, daysLeft: String) {
        let backgroundColor = isExpired ? Asset.Colors.flamingo.color : Asset.Colors.antiFlashWhite.color
        let font = isExpired ? FontFamily.AvenirLTStd._85Heavy.font(size: 12.0)
                             : FontFamily.AvenirLTStd._65Medium.font(size: 12.0)
        let textColor = isExpired ? UIColor.white : Asset.Colors.gunmetal.color
        let text = isExpired ? L10n.Payments.Plan.Expired.status : daysLeft

        daysLeftView.backgroundColor = backgroundColor
        let isHide = isExpired ? false : daysLeft.isEmpty
        daysLeftView.isHidden = isHide
        daysLeftLabel.font = font
        daysLeftLabel.textColor = textColor
        daysLeftLabel.text = text
    }

    private func setupPlanView() {
        planContentView.layerCornerRadius = 4
        containerView.addSubview(planContentView)
        planContentView.layout {
            $0.leading.equal(to: primaryImageView.trailingAnchor, offsetBy: 16)
            $0.top.equal(to: statusView.bottomAnchor, offsetBy: 6)
            $0.height.equal(to: 20)
            planIconViewWidthConstraint = $0.width.equal(to: 0, priority: UILayoutPriority(rawValue: 999))
        }

        planIconImageView.contentMode = .scaleAspectFit
        planContentView.addSubview(planIconImageView)
        planIconImageView.pinEdges(to: planContentView)

        publishedDateLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 12)
        publishedDateLabel.textColor = Asset.Colors.bluishGrey.color
        containerView.addSubview(publishedDateLabel)
        publishedDateLabel.layout {
            publishDateLeadingConstraint = $0.leading.equal(to: planContentView.trailingAnchor, offsetBy: 0)
            $0.centerY.equal(to: planContentView.centerYAnchor)
        }
    }
    
    private func layout() {
        containerView = UIView()
        contentView.addSubview(containerView)
        containerView.layout {
            $0.top == contentView.topAnchor
            $0.leading == contentView.leadingAnchor
            $0.trailing == contentView.trailingAnchor
            $0.bottom == contentView.bottomAnchor - 8.0
        }
        
        primaryImageView = UIImageView()
        containerView.addSubview(primaryImageView)
        primaryImageView.layout {
            $0.top == containerView.topAnchor + 24.0
            $0.leading == containerView.leadingAnchor + 8.0
            $0.width == 128.0
            $0.height == 128.0
        }

        containerView.addSubview(daysLeftView)
        daysLeftView.layout {
            $0.leading.equal(to: primaryImageView.leadingAnchor)
            $0.trailing.equal(to: primaryImageView.trailingAnchor)
            $0.bottom.equal(to: primaryImageView.bottomAnchor)
            $0.height.equal(to: 24)
        }
        
        daysLeftView.addSubview(daysLeftLabel)
        daysLeftLabel.layout {
            $0.bottom.equal(to: daysLeftView.bottomAnchor)
            $0.leading.equal(to: daysLeftView.leadingAnchor)
            $0.trailing.equal(to: daysLeftView.trailingAnchor)
            $0.top.equal(to: daysLeftView.topAnchor)
        }
        
        setupTypeView()

        containerView.addSubview(statisticsView)
        statisticsView.layout {
            $0.leading.equal(to: containerView.leadingAnchor)
            $0.trailing.equal(to: containerView.trailingAnchor)
            $0.top.equal(to: primaryImageView.bottomAnchor, offsetBy: 8)
            $0.trailing.equal(to: containerView.trailingAnchor)
        }
    }
    
    private func setupStatusLayout() {
        statusView = UIView()
        containerView.addSubview(statusView)
        statusView.layout {
            $0.top == containerView.topAnchor + 24.0
            $0.leading == primaryImageView.trailingAnchor + 16.0
        }
        
        statusLabel = UILabel()
        statusView.addSubview(statusLabel)
        statusLabel.layout {
            $0.top == statusView.topAnchor + 7.0
            $0.leading == statusView.leadingAnchor + 10.0
            $0.trailing == statusView.trailingAnchor - 10.0
            $0.bottom == statusView.bottomAnchor - 5.0
        }
        
        moreButton = UIButton()
        containerView.addSubview(moreButton)
        moreButton.layout {
            $0.top == containerView.topAnchor + 32.0
            $0.trailing == containerView.trailingAnchor - 12.0
            $0.width == 32.0
            $0.height == 32.0
        }
        
        priceLabel = UILabel()
        containerView.addSubview(priceLabel)
        priceLabel.layout {
            $0.top == statusView.bottomAnchor + 33.0
            $0.leading == primaryImageView.trailingAnchor + 16.0
            $0.trailing <= containerView.trailingAnchor - 12.0
        }
        
        addressLabel = UILabel()
        containerView.addSubview(addressLabel)
        addressLabel.layout {
            $0.top == priceLabel.bottomAnchor + 6.0
            $0.leading == primaryImageView.trailingAnchor + 16.0
            $0.trailing <= containerView.trailingAnchor - 12.0
        }
    }

    private func setupTypeView() {
        typeView = UIView()
        containerView.addSubview(typeView)
        typeView.layout {
            $0.top == primaryImageView.topAnchor + 7.0
            $0.leading == primaryImageView.leadingAnchor + 8.0
            $0.trailing <= primaryImageView.trailingAnchor - 8.0
            $0.bottom <= primaryImageView.bottomAnchor - 7.0
        }

        typeIconImageView = UIImageView()
        typeView.addSubview(typeIconImageView)
        typeIconImageView.layout {
            $0.top == typeView.topAnchor + 8.0
            $0.leading == typeView.leadingAnchor + 4.0
            $0.height == 16.0
            $0.width == 16.0
        }

        propertyTypeLabel = UILabel()
        typeView.addSubview(propertyTypeLabel)
        propertyTypeLabel.layout {
            $0.top == typeView.topAnchor + 6.0
            $0.leading == typeIconImageView.trailingAnchor + 6.0
            $0.trailing <= typeView.trailingAnchor - 16.0
        }

        typeTitleLabel = UILabel()
        typeView.addSubview(typeTitleLabel)
        typeTitleLabel.layout {
            $0.top == propertyTypeLabel.bottomAnchor + 1.0
            $0.leading == typeIconImageView.trailingAnchor + 6.0
            $0.trailing <= typeView.trailingAnchor - 17.0
            $0.bottom == typeView.bottomAnchor - 3.0
        }
    }
    
    private func setupStackView() {
        inlinePropertiesView = InlinePropertiesView()
        containerView.addSubview(inlinePropertiesView)
        inlinePropertiesView.layout {
            $0.top == addressLabel.bottomAnchor + 11
            $0.leading == primaryImageView.trailingAnchor + 16.0
            $0.trailing <= containerView.trailingAnchor - 12.0
        }
    }
    
    private func setupViews() {
        contentView.backgroundColor = Asset.Colors.whiteLilac.color
        
        containerView.backgroundColor = .white
        
        primaryImageView.image = Asset.MyListings.myListingsDraft.image
        primaryImageView.backgroundColor = Asset.Colors.antiFlashWhite.color
        primaryImageView.layer.cornerRadius = 6.0
        primaryImageView.clipsToBounds = true
        primaryImageView.contentMode = .scaleAspectFill

        daysLeftView.backgroundColor = Asset.Colors.antiFlashWhite.color
        daysLeftView.addCornerRadius(5, corners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
        
        daysLeftLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 12.0)
        daysLeftLabel.textAlignment = .center
        daysLeftLabel.textColor = Asset.Colors.gunmetal.color

        typeView.layer.cornerRadius = 4.0
        
        propertyTypeLabel.numberOfLines = 0
        propertyTypeLabel.textColor = .white
        propertyTypeLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 10.0)
        
        typeTitleLabel.numberOfLines = 0
        typeTitleLabel.textColor = .white
        typeTitleLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12.0)
        
        statusView.layer.cornerRadius = 12.0
        
        statusLabel.numberOfLines = 0
        statusLabel.textColor = .white
        statusLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 12.0)
        
        moreButton.setImage(Asset.MyListings.myListingsMore.image, for: .normal)
        moreButton.backgroundColor = Asset.Colors.antiFlashWhite.color
        moreButton.layer.cornerRadius = 6.0
        
        priceLabel.textColor = Asset.Colors.vulcan.color
        priceLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 20.0)
        
        addressLabel.numberOfLines = 1 // due to design
        addressLabel.textColor = Asset.Colors.trout.color
        addressLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12.0)
    }
    
    private func clear() {
        primaryImageView.cancelImageFetching()
        primaryImageView.image = Asset.MyListings.myListingsDraft.image
        daysLeftLabel.text = nil
        propertyTypeLabel.text = nil
        typeTitleLabel.text = nil
        statusLabel.text = nil
        typeIconImageView.image = nil
        priceLabel.text = nil
        addressLabel.text = nil
    }
        
    private func setupBindings() {
        disposeBag = DisposeBag()
        
        moreButton.rx.tap
            .bind { [weak self] in
                self?.optionsSelected?()
            }
            .disposed(by: disposeBag)
    }
    
}

extension MyListingTableViewCell: Reusable { }
