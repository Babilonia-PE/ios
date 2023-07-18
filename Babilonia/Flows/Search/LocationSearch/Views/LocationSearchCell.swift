//
//  LocationSearchCell.swift
//  Babilonia
//
//  Created by Alya Filon  on 18.09.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

final class LocationSearchCell: UITableViewCell, Reusable {

    var locationLabel: UILabel = .init()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension LocationSearchCell {

    private func setupView() {
        locationLabel.textColor = .black
        locationLabel.font = FontFamily.AvenirLTStd._55Roman.font(size: 14)
        locationLabel.numberOfLines = 0

        addSubview(locationLabel)
        locationLabel.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: 48)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.top.equal(to: topAnchor, offsetBy: 13)
            $0.bottom.equal(to: bottomAnchor, offsetBy: -13)
        }
    }

}
