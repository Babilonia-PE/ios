//
//  PaymentsPeriodView.swift
//  Babilonia
//
//  Created by Alya Filon  on 27.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class PaymentsPeriodView: NiblessView {

    let checkoutButton: ConfirmationButton = .init()
    let tableView: UITableView = .init()
    private let titleLabel: UILabel = .init()
    private let planContentView: UIView = .init()
    private let planImageView: UIImageView = .init()
    private let planIconImageView: UIImageView = .init()
    private let planTitleLabel: UILabel = .init()
    private let priceLabel: UILabel = .init()

    override init() {
        super.init()

        setupView()
    }

    func apply(_ planModel: PaymentPlanContentModel) {
        planImageView.image = planModel.backgroundImage
        planIconImageView.image = planModel.iconImage
        planTitleLabel.text = planModel.title
        priceLabel.text = planModel.fromPrice
    }

}

extension PaymentsPeriodView {

    private func setupView() {
        backgroundColor = .white

        titleLabel.text = L10n.Payments.PeriodSelection.description
        titleLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 14)
        titleLabel.textColor = Asset.Colors.gunmetal.color
        titleLabel.textAlignment = .center
        DispatchQueue.global(qos: .background)
        addSubview(titleLabel)
        titleLabel.layout {
            $0.top.equal(to: safeAreaLayoutGuide.topAnchor, offsetBy: 8)
            $0.leading.equal(to: leadingAnchor, offsetBy: 38)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -38)
        }

        setupPlanView()
        setupTableView()

        checkoutButton.setTitle(L10n.Payments.Checkout.title.uppercased(), for: .normal)
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.titleLabel?.font = FontFamily.SamsungSharpSans.bold.font(size: 16)

        addSubview(checkoutButton)
        checkoutButton.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.bottom.equal(to: safeAreaLayoutGuide.bottomAnchor, offsetBy: -24)
            $0.height.equal(to: 56)
        }
    }

    private func setupPlanView() {
        addSubview(planContentView)
        planContentView.layout {
            $0.top.equal(to: titleLabel.bottomAnchor, offsetBy: 28)
            $0.leading.equal(to: leadingAnchor, offsetBy: 23)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -23)
            $0.height.equal(to: planContentView.widthAnchor, multiplier: 0.468)
        }

        planImageView.layerCornerRadius = 12
        planImageView.clipsToBounds = true

        planContentView.addSubview(planImageView)
        planImageView.pinEdges(to: planContentView)

        planIconImageView.contentMode = .scaleAspectFit

        planTitleLabel.textColor = .white
        planTitleLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 34)

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 11

        stackView.addArrangedSubview(planIconImageView)
        stackView.addArrangedSubview(planTitleLabel)

        planContentView.addSubview(stackView)
        stackView.layout {
            $0.centerX.equal(to: planContentView.centerXAnchor)
            $0.height.equal(to: 40)
            $0.top.equal(to: planContentView.topAnchor, offsetBy: 42)
        }

        priceLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        priceLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 14)
        planContentView.addSubview(priceLabel)
        priceLabel.layout {
            $0.centerX.equal(to: planContentView.centerXAnchor)
            $0.top.equal(to: stackView.bottomAnchor, offsetBy: 6)
        }
    }

    private func setupTableView() {
        tableView.rowHeight = 56
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.registerReusableCell(cellType: PaymentPeriodCell.self)

        addSubview(tableView)
        tableView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.top.equal(to: planContentView.bottomAnchor, offsetBy: 18)
        }
    }

}
