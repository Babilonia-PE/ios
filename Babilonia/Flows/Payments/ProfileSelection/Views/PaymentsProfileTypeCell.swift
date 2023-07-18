//
//  PaymentsProfileTypeCell.swift
//  Babilonia
//
//  Created by Alya Filon  on 30.10.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class PaymentsProfileTypeCell: UICollectionViewCell, Reusable {

    private let placeholderView: UIView = .init()
    let iconImageView: UIImageView = .init()
    let titleLabel: UILabel = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setHighlight(isHighlighted: Bool) {
        placeholderView.clipsToBounds = !isHighlighted
        placeholderView.layerBorderWidth = isHighlighted ? 2 : 0
    }
    
}

extension PaymentsProfileTypeCell {

    private func setupView() {
        placeholderView.backgroundColor = Asset.Colors.hintOfRed.color
        placeholderView.layerBorderColor = Asset.Colors.watermelon.color
        placeholderView.layerBorderWidth = 2
        placeholderView.layerCornerRadius = 8
        placeholderView.makeShadow(Asset.Colors.watermelon.color)
        placeholderView.clipsToBounds = true

        addSubview(placeholderView)
        placeholderView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.height.equal(to: placeholderView.widthAnchor)
            $0.top.equal(to: topAnchor)
        }

        iconImageView.contentMode = .scaleAspectFit

        placeholderView.addSubview(iconImageView)
        iconImageView.pinEdges(to: placeholderView)

        titleLabel.textColor = Asset.Colors.almostBlack.color
        titleLabel.font = FontFamily.AvenirLTStd._85Heavy.font(size: 14)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        addSubview(titleLabel)
        titleLabel.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.top.equal(to: placeholderView.bottomAnchor, offsetBy: 14)
        }
    }

}
