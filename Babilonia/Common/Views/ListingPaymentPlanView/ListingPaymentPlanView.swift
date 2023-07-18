//
//  ListingPaymentPlanView.swift
//  Babilonia
//
//  Created by Alya Filon  on 25.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class ListingPaymentPlanView: NiblessView {

    private let iconImageView: UIImageView = .init()
    private let planLabel: UILabel = .init()
    private let publishDateLabel: UILabel = .init()
    private let daysLeftLabel: UILabel = .init()
    private let backgroundView: UIView = .init()

    private var planLabelLeadingConstraint: NSLayoutConstraint?

    override init() {
        super.init()

        setupView()
    }

    func apply(_ viewModel: ListingPaymentPlanViewModel) {
        if viewModel.isStandardPlan {
            planLabel.isHidden = true
            backgroundView.isHidden = true
        } else {
            iconImageView.image = viewModel.icon
            planLabel.textColor = viewModel.color
            planLabel.text = viewModel.title
            backgroundView.backgroundColor = viewModel.backgroundColor
        }
        
        if viewModel.isUserOwnedListing {
            publishDateLabel.text = viewModel.purchaseDate
            daysLeftLabel.text = viewModel.daysLeft
        } else {
            publishDateLabel.isHidden = true
            daysLeftLabel.isHidden = true
        }

        let leading: CGFloat = viewModel.isStandardPlan ? -12 : 4
        planLabelLeadingConstraint?.constant = leading
    }

}

extension ListingPaymentPlanView {

    private func setupView() {
        backgroundView.layerCornerRadius = 4
        addSubview(backgroundView)
        backgroundView.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.top.equal(to: topAnchor, offsetBy: 12)
            $0.height.equal(to: 21)
            $0.width.equal(to: 21)
        }

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = Asset.Payments.premiumIcon.image

        backgroundView.addSubview(iconImageView)
        iconImageView.layout {
            $0.height.equal(to: 17)
            $0.width.equal(to: 17)
            $0.centerX.equal(to: backgroundView.centerXAnchor)
            $0.centerY.equal(to: backgroundView.centerYAnchor)
        }

        planLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 12)
        planLabel.textColor = Asset.Colors.biscay.color

        addSubview(planLabel)
        planLabel.layout {
            planLabelLeadingConstraint = $0.leading.equal(to: backgroundView.trailingAnchor, offsetBy: 4)
            $0.centerY.equal(to: iconImageView.centerYAnchor)
        }

        daysLeftLabel.textColor = Asset.Colors.bluishGrey.color
        daysLeftLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 12)

        addSubview(daysLeftLabel)
        daysLeftLabel.layout {
            $0.trailing.equal(to: trailingAnchor, offsetBy: -15)
            $0.centerY.equal(to: iconImageView.centerYAnchor)
        }

        publishDateLabel.textColor = Asset.Colors.bluishGrey.color
        publishDateLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 12)

        addSubview(publishDateLabel)
        publishDateLabel.layout {
            $0.trailing.equal(to: daysLeftLabel.leadingAnchor, offsetBy: -15)
            $0.centerY.equal(to: iconImageView.centerYAnchor)
        }
    }

}
