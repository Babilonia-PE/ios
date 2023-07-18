//
//  PaymentPlanItemCell.swift
//  Babilonia
//
//  Created by Alya Filon  on 27.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class PaymentPlanItemCell: UITableViewCell, Reusable {

    private let titleLabel: UILabel = .init()
    private let tickImageView: UIImageView = .init()
    private let separatorView: UIView = .init()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(_ item: String) {
        titleLabel.text = item
    }

}

extension PaymentPlanItemCell {

    private func setupView() {
        backgroundColor = Asset.Colors.hintOfRed.color

        tickImageView.contentMode = .scaleAspectFit
        tickImageView.image = Asset.Payments.planItemTickIcon.image

        addSubview(tickImageView)
        tickImageView.layout {
            $0.height.equal(to: 16)
            $0.width.equal(to: 16)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -32)
            $0.centerY.equal(to: centerYAnchor)
        }

        titleLabel.font = FontFamily.AvenirLTStd._65Medium.font(size: 16)
        titleLabel.textColor = Asset.Colors.almostBlack.color

        addSubview(titleLabel)
        titleLabel.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 32)
            $0.centerY.equal(to: centerYAnchor)
            $0.trailing.equal(to: tickImageView.leadingAnchor, offsetBy: -10)
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
