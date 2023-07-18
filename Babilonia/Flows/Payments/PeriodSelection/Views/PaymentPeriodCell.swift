//
//  PaymentPeriodCell.swift
//  Babilonia
//
//  Created by Alya Filon  on 02.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class PaymentPeriodCell: UITableViewCell, Reusable {

    private let titleLabel: UILabel = .init()
    private let descriptionLabel: UILabel = .init()
    private let priceLabel: UILabel = .init()
    private let radioButImageView: UIImageView = .init()
    private let separatorView: UIView = .init()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(_ model: PaymentPeriodContentModel) {
        titleLabel.text = model.period
        descriptionLabel.text = model.periodDescription
        priceLabel.text = model.price
    }

    func setHighlight(isHighlighted: Bool) {
        let image = isHighlighted ? Asset.Payments.radioButtonEnabled.image : Asset.Payments.radioButtonDisabled.image
        let color = isHighlighted ? Asset.Colors.watermelon.color : .black
        radioButImageView.image = image
        priceLabel.textColor = color
    }

}

extension PaymentPeriodCell {

    private func setupView() {
        radioButImageView.contentMode = .scaleAspectFit
        radioButImageView.image = Asset.Payments.radioButtonDisabled.image

        addSubview(radioButImageView)
        radioButImageView.layout {
            $0.trailing.equal(to: trailingAnchor, offsetBy: -24)
            $0.height.equal(to: 16)
            $0.width.equal(to: 16)
            $0.centerY.equal(to: centerYAnchor)
        }

        priceLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 16)
        priceLabel.textColor = .black

        addSubview(priceLabel)
        priceLabel.layout {
            $0.centerY.equal(to: centerYAnchor)
            $0.trailing.equal(to: radioButImageView.leadingAnchor, offsetBy: -16)
        }

        titleLabel.textColor = Asset.Colors.almostBlack.color
        titleLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 14)

        descriptionLabel.textColor = Asset.Colors.watermelon.color
        descriptionLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 12)

        let stackView = UIStackView()
        stackView.axis = .vertical

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)

        addSubview(stackView)
        stackView.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 24)
            $0.top.equal(to: topAnchor, offsetBy: 8)
            $0.bottom.equal(to: bottomAnchor, offsetBy: -8)
        }

        separatorView.backgroundColor = Asset.Colors.veryLightBlueTwo.color
        addSubview(separatorView)
        separatorView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.height.equal(to: 1)
        }
    }

}
