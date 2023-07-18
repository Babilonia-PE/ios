//
//  PaymentPlanCell.swift
//  Babilonia
//
//  Created by Alya Filon  on 02.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class PaymentPlanCell: UICollectionViewCell, Reusable {

    private let backgroundImageView: UIImageView = .init()
    private let iconImageView: UIImageView = .init()
    private let titleLabel: UILabel = .init()
    private let priceLabel: UILabel = .init()

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(_ planModel: PaymentPlanContentModel) {
        backgroundImageView.image = planModel.backgroundImage
        iconImageView.image = planModel.iconImage
        titleLabel.text = planModel.title
        priceLabel.text = planModel.fromPrice

        makeShadow(planModel.baseColor,
                               offset: CGSize(width: 0, height: 4),
                               radius: 8,
                               opacity: 0.45)
    }

    func setHighlight(isHighlighted: Bool) {
        clipsToBounds = !isHighlighted
    }

}

extension PaymentPlanCell {

    private func setupView() {
        backgroundImageView.clipsToBounds = true
        backgroundImageView.layerCornerRadius = 12
        backgroundImageView.contentMode = .scaleAspectFill

        addSubview(backgroundImageView)
        backgroundImageView.pinEdges(to: self)

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8

        addSubview(stackView)
        stackView.layout {
            $0.top.equal(to: topAnchor, offsetBy: 35)
            $0.centerX.equal(to: centerXAnchor)
            $0.height.equal(to: 40)
        }

        iconImageView.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(iconImageView)
        iconImageView.layout {
            $0.width.equal(to: 28)
        }

        titleLabel.textColor = .white
        titleLabel.font = FontFamily.SamsungSharpSans.bold.font(size: 34)
        stackView.addArrangedSubview(titleLabel)

        priceLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        priceLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 14)

        addSubview(priceLabel)
        priceLabel.layout {
            $0.top.equal(to: stackView.bottomAnchor, offsetBy: 6)
            $0.centerX.equal(to: centerXAnchor)
        }
    }

}
